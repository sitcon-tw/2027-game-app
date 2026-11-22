import 'dart:async';

import 'package:flutter/foundation.dart';

import 'ntag_reader.dart';

enum AutomaticScanStatus {
  paused,
  idle,
  starting,
  waiting,
  processing,
  cancelled,
  error,
}

/// Serializes native reads and result handling while route/app visibility changes.
/// A consumed UID stays suppressed until a different tag or a new controller;
/// removing and holding the same tag cannot repeatedly reopen result dialogs.
class AutomaticScanController extends ChangeNotifier {
  AutomaticScanController({
    required this._reader,
    required this._onUid,
    this.rearmDelay = const Duration(milliseconds: 400),
    this.opensSystemSheet = false,
  });

  final NtagReader _reader;
  final Future<void> Function(String uid) _onUid;
  final Duration rearmDelay;
  final bool opensSystemSheet;
  bool _sheetRequested = false;
  bool _routeVisible = false;
  bool _resumed = false;
  bool _blocked = false;
  bool _handling = false;
  bool _disposed = false;
  bool _ready = false;
  bool _userCancelled = false;
  String? _lastUid;
  Object? _error;
  Object? _readToken;
  Future<void>? _cancelling;
  Timer? _rearmTimer;
  int _contextRevision = 0;

  bool get canPresent => !_disposed && _routeVisible && _resumed;
  bool get processing => _handling;
  bool get _eligible => canPresent && !_blocked && !_handling;
  Object? get error => _error;
  bool get needsRetry => _error != null || _userCancelled;
  AutomaticScanStatus get status {
    if (!canPresent) return AutomaticScanStatus.paused;
    if (_handling || _blocked) return AutomaticScanStatus.processing;
    if (_error != null) return AutomaticScanStatus.error;
    if (_userCancelled) return AutomaticScanStatus.cancelled;
    if (opensSystemSheet && _readToken == null) return AutomaticScanStatus.idle;
    return _ready ? AutomaticScanStatus.waiting : AutomaticScanStatus.starting;
  }

  void setRouteVisible(bool value) {
    if (_disposed || _routeVisible == value) return;
    _routeVisible = value;
    _visibilityChanged();
  }

  void setResumed(bool value) {
    if (_disposed || _resumed == value) return;
    _resumed = value;
    _visibilityChanged();
  }

  void setBlocked(bool value) {
    if (_disposed || _blocked == value) return;
    _blocked = value;
    _visibilityChanged();
  }

  /// A mode/permission change invalidates pending native and fixture callbacks.
  /// Deduplication belongs to the mode, so the same badge can be read anew.
  void resetContext() {
    if (_disposed) return;
    _contextRevision++;
    _lastUid = null;
    _disarm();
    _notify();
    _reconcile();
  }

  void _visibilityChanged() {
    if (!_eligible) _disarm();
    _notify();
    _reconcile();
  }

  void startScan() {
    if (status != AutomaticScanStatus.idle) return;
    _sheetRequested = true;
    _lastUid = null;
    _reconcile();
  }

  void retry() {
    if (!_eligible || !needsRetry) return;
    _error = null;
    _userCancelled = false;
    if (opensSystemSheet) {
      startScan();
      return;
    }
    _notify();
    _reconcile();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _reportCancellationError(Object error, StackTrace stack) {
    if (_disposed) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'automatic NTAG scanner',
          context: ErrorDescription('while closing a native NFC session'),
        ),
      );
    } else {
      _error = error;
      _notify();
    }
  }

  void _disarm() {
    _sheetRequested = false;
    _rearmTimer?.cancel();
    _rearmTimer = null;
    _ready = false;
    if (_readToken == null) return;
    // Invalidate before calling the reader. Even a synchronous/late discovery
    // from the native cancellation handshake cannot submit anything now.
    _readToken = null;
    _cancelReader();
  }

  void _cancelReader() {
    if (_cancelling != null) return;
    final future = Future<void>.sync(_reader.cancel);
    _cancelling = future;
    unawaited(
      future.then<void>(
        (_) => _cancelFinished(future),
        onError: (Object error, StackTrace stack) {
          _reportCancellationError(error, stack);
          _cancelFinished(future);
        },
      ),
    );
  }

  void _cancelFinished(Future<void> future) {
    if (identical(_cancelling, future)) _cancelling = null;
    _reconcile();
  }

  void _reconcile() {
    if (!_eligible ||
        needsRetry ||
        (opensSystemSheet && !_sheetRequested) ||
        _readToken != null ||
        _cancelling != null ||
        _rearmTimer != null) {
      return;
    }
    _sheetRequested = false;
    final token = Object();
    _readToken = token;
    _ready = false;
    _notify();
    unawaited(_read(token));
  }

  bool _owns(Object token) =>
      !_disposed && identical(_readToken, token) && _eligible;

  Future<void> _read(Object token) async {
    try {
      final value = await _reader.readUid(
        onReady: () {
          if (!_owns(token)) return;
          _ready = true;
          _notify();
        },
      );
      if (!_owns(token)) return;
      _readToken = null;
      _ready = false;
      if (value == null) {
        // In particular, iOS Cancel must never immediately reopen its sheet.
        _userCancelled = true;
        _notify();
        return;
      }
      if (value != _lastUid) {
        _lastUid = value;
        await _handle(value);
      }
      _scheduleRearm();
    } catch (error) {
      if (!_owns(token)) return;
      _readToken = null;
      _ready = false;
      _error = error;
      _notify();
    }
  }

  Future<void> _handle(String value) async {
    _handling = true;
    _notify();
    try {
      await _onUid(value);
    } catch (error) {
      if (!_disposed) _error = error;
    } finally {
      _handling = false;
      _notify();
    }
  }

  void _scheduleRearm() {
    if (opensSystemSheet) return;
    if (!_eligible || needsRetry) {
      _reconcile();
      return;
    }
    _rearmTimer = Timer(rearmDelay, () {
      _rearmTimer = null;
      _reconcile();
    });
    _notify();
  }

  /// Fixtures share the same serialization/visibility gate, but intentionally
  /// bypass physical-tag deduplication so test scenarios can repeat a UID.
  Future<void> submitFixture(String value) async {
    if (!_eligible) return;
    final revision = _contextRevision;
    _handling = true;
    _disarm();
    _notify();
    final cancelling = _cancelling;
    if (cancelling != null) {
      try {
        await cancelling;
      } catch (_) {
        // The cancellation handler already exposes the error in scanner state.
      }
    }
    if (!canPresent || _blocked || revision != _contextRevision) {
      _handling = false;
      _notify();
      _reconcile();
      return;
    }
    await _handle(value);
    _scheduleRearm();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _disarm();
    unawaited(
      Future<void>.sync(_reader.dispose)
          .catchError((Object error, StackTrace stack) {
            _reportCancellationError(error, stack);
          }),
    );
    super.dispose();
  }
}
