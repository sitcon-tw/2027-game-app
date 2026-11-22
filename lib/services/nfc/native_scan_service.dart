import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';

import 'package:sitcon_backend/game/game_service.dart';

import 'ntag_reader.dart';

class _NfcManagerDriver implements NtagSessionDriver {
  _NfcManagerDriver(this.promptProvider);
  final String Function()? promptProvider;
  @override
  bool get opensSystemSheet => defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Future<bool> checkEnabled() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.android)) {
      throw GameStateError(const GameMessage('nfcUnsupported'));
    }
    return await NfcManager.instance.checkAvailability() ==
        NfcAvailability.enabled;
  }

  @override
  Future<void> start({
    required void Function(List<int>? bytes) onTag,
    required void Function(Object? error) onError,
  }) => NfcManager.instance.startSession(
    pollingOptions: {NfcPollingOption.iso14443},
    alertMessageIos: promptProvider?.call(),
    onSessionErrorIos: (error) {
      onError(
        error.code ==
                NfcReaderErrorCodeIos.readerSessionInvalidationErrorUserCanceled
            ? null
            : GameStateError(const GameMessage('nfcInterrupted')),
      );
    },
    onDiscovered: (tag) {
      try {
        onTag(
          defaultTargetPlatform == TargetPlatform.android
              ? NfcTagAndroid.from(tag)?.id
              : MiFareIos.from(tag)?.identifier,
        );
      } catch (_) {
        onError(GameStateError(const GameMessage('nfcReadFailed')));
      }
    },
  );

  @override
  Future<void> stop() => NfcManager.instance.stopSession();
}

class _ReadOutcome {
  const _ReadOutcome({this.uid, this.error});
  final String? uid;
  final Object? error;
}

class _NativeRead {
  final outcome = Completer<_ReadOutcome>();
  final closed = Completer<Object?>();
  bool cancelled = false;
  bool nativeInvalidated = false;
  Timer? timeout;

  void finish(_ReadOutcome value) {
    if (!outcome.isCompleted) outcome.complete(value);
  }
}

/// Reads only the immutable seven-byte NTAG UID; no tag data is written.
class NativeScanService implements NtagReader {
  NativeScanService({
    NtagSessionDriver? driver,
    this.sessionTimeout,
    String Function()? promptProvider,
  }) : _driver = driver ?? _NfcManagerDriver(promptProvider);

  final NtagSessionDriver _driver;

  /// Android normally waits indefinitely. iOS uses a 30-second sheet timeout.
  final Duration? sessionTimeout;
  static _NativeRead? _owner;
  _NativeRead? _session;
  bool _disposed = false;

  bool _accepts(_NativeRead session) =>
      identical(_owner, session) &&
      identical(_session, session) &&
      !session.cancelled &&
      !session.outcome.isCompleted;

  @override
  Future<String?> readUid({VoidCallback? onReady}) async {
    if (_disposed) throw GameStateError(const GameMessage('nfcDisposed'));
    if (_session != null) throw GameStateError(const GameMessage('nfcBusy'));
    final session = _NativeRead();
    _session = session;
    var startAttempted = false;
    Object? closeError;
    try {
      final previous = _owner;
      if (previous != null && previous.cancelled) {
        final error = await previous.closed.future;
        if (error != null) {
          throw GameStateError(const GameMessage('nfcStopFailed'));
        }
      }
      if (!session.cancelled) {
        if (_owner != null) throw GameStateError(const GameMessage('nfcBusy'));
        _owner = session;
      }
      if (_accepts(session) && !await _driver.checkEnabled()) {
        throw GameStateError(const GameMessage('nfcDisabled'));
      }
      if (_accepts(session)) {
        // Mark before awaiting: cancel during start must still stop the session
        // after native acknowledgement, before releasing global ownership.
        startAttempted = true;
        await _driver.start(
          onTag: (bytes) {
            if (!_accepts(session)) return;
            if (bytes == null || bytes.length != 7) {
              session.finish(
                _ReadOutcome(
                  error: GameStateError(const GameMessage('nfcInvalidTag')),
                ),
              );
              return;
            }
            session.finish(
              _ReadOutcome(
                uid: bytes
                    .map((b) => b.toRadixString(16).padLeft(2, '0'))
                    .join()
                    .toUpperCase(),
              ),
            );
          },
          onError: (error) {
            if (!_accepts(session)) return;
            session.nativeInvalidated = true;
            session.finish(
              _ReadOutcome(
                error: error == null
                    ? null
                    : error is GameLocalizedError
                    ? error
                    : GameStateError(const GameMessage('nfcInterrupted')),
              ),
            );
          },
        );
        if (_accepts(session)) {
          final timeout =
              sessionTimeout ??
              (_driver.opensSystemSheet ? const Duration(seconds: 30) : null);
          if (timeout != null) {
            session.timeout = Timer(timeout, () {
              session.finish(
                _ReadOutcome(
                  error: GameStateError(const GameMessage('nfcTimeout')),
                ),
              );
            });
          }
          onReady?.call();
        }
      }
    } on PlatformException {
      session.finish(
        _ReadOutcome(
          error: GameStateError(const GameMessage('nfcStartFailed')),
        ),
      );
    } catch (error) {
      session.finish(
        _ReadOutcome(
          error: error is GameLocalizedError
              ? error
              : GameStateError(const GameMessage('nfcStartFailed')),
        ),
      );
    }

    final outcome = await session.outcome.future;
    session.timeout?.cancel();
    try {
      if (startAttempted && !session.nativeInvalidated) await _driver.stop();
    } catch (error) {
      closeError = error;
    } finally {
      if (identical(_owner, session)) _owner = null;
      if (identical(_session, session)) _session = null;
      session.closed.complete(closeError);
    }
    if (session.cancelled) return null;
    if (outcome.error != null) throw outcome.error!;
    if (closeError != null) {
      throw GameStateError(const GameMessage('nfcStopFailed'));
    }
    return outcome.uid;
  }

  @override
  Future<void> cancel() async {
    final session = _session;
    if (session == null) return;
    session.cancelled = true;
    session.finish(const _ReadOutcome());
    final error = await session.closed.future;
    if (error != null) throw GameStateError(const GameMessage('nfcStopFailed'));
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await cancel();
  }
}
