import 'package:flutter/foundation.dart';

import 'native_scan_service.dart';

/// A cancellable, instance-owned NTAG reader. Await cancel before another read.
abstract interface class NtagReader {
  Future<String?> readUid({VoidCallback? onReady});
  Future<void> cancel();
  Future<void> dispose();
}

/// Injectable OS boundary for deterministic native-session race tests.
abstract interface class NtagSessionDriver {
  bool get opensSystemSheet;
  Future<bool> checkEnabled();
  Future<void> start({
    required void Function(List<int>? bytes) onTag,
    required void Function(Object? error) onError,
  });
  Future<void> stop();
}

NtagReader createNtagReader({String Function()? promptProvider}) =>
    NativeScanService(promptProvider: promptProvider);
