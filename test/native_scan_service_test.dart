import 'package:sitcon_app/services/nfc/ntag_reader.dart';

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sitcon_backend/game/game_service.dart';
import 'package:sitcon_app/services/nfc/native_scan_service.dart';

class _Driver implements NtagSessionDriver {
  _Driver({this.opensSystemSheet = false});
  @override
  final bool opensSystemSheet;
  bool enabled = true;
  Completer<bool>? availabilityGate;
  Completer<void>? startGate;
  Completer<void>? stopGate;
  void Function(List<int>?)? onTag;
  void Function(Object?)? onError;
  int starts = 0;
  int stops = 0;

  @override
  Future<bool> checkEnabled() async =>
      availabilityGate == null ? enabled : await availabilityGate!.future;

  @override
  Future<void> start({
    required void Function(List<int>?) onTag,
    required void Function(Object?) onError,
  }) async {
    starts++;
    this.onTag = onTag;
    this.onError = onError;
    await startGate?.future;
  }

  @override
  Future<void> stop() async {
    stops++;
    await stopGate?.future;
  }
}

const _uidBytes = [4, 161, 178, 195, 212, 229, 246];

void main() {
  testWidgets('a queued owner cancelled before handoff never starts', (
    tester,
  ) async {
    final firstDriver = _Driver()..startGate = Completer<void>();
    final first = NativeScanService(driver: firstDriver);
    final nextDriver = _Driver();
    final next = NativeScanService(driver: nextDriver);
    addTearDown(first.dispose);
    addTearDown(next.dispose);
    final firstRead = first.readUid();
    await tester.pump();
    final firstCancel = first.cancel();
    final nextRead = next.readUid();
    final nextCancel = next.cancel();
    firstDriver.startGate!.complete();
    await firstCancel;
    await nextCancel;
    expect(await firstRead, isNull);
    expect(await nextRead, isNull);
    expect(nextDriver.starts, 0);
    expect(nextDriver.stops, 0);
  });

  testWidgets('reads only strict seven-byte UID and closes before delivery', (
    tester,
  ) async {
    final driver = _Driver();
    final reader = NativeScanService(driver: driver);
    addTearDown(reader.dispose);
    var ready = false;
    final result = reader.readUid(onReady: () => ready = true);
    await tester.pump();
    expect(ready, isTrue);
    driver.stopGate = Completer<void>();
    driver.onTag!(_uidBytes);
    // A second platform discovery cannot replace the first immutable UID.
    driver.onTag!([4, 0, 0, 0, 0, 0, 1]);
    await tester.pump();
    expect(driver.stops, 1);
    var delivered = false;
    unawaited(result.then((_) => delivered = true));
    await tester.pump();
    expect(delivered, isFalse);
    driver.stopGate!.complete();
    expect(await result, '04A1B2C3D4E5F6');

    final invalid = reader.readUid();
    final invalidExpectation = expectLater(
      invalid,
      throwsA(
        isA<GameStateError>().having(
          (e) => e.localizedMessage.code,
          'code',
          'nfcInvalidTag',
        ),
      ),
    );
    await tester.pump();
    driver.onTag!([4, 1, 2, 3]);
    await invalidExpectation;
    expect(driver.stops, 2);
  });

  testWidgets('cancel during availability never starts a native session', (
    tester,
  ) async {
    final driver = _Driver()..availabilityGate = Completer<bool>();
    final reader = NativeScanService(driver: driver);
    addTearDown(reader.dispose);
    final read = reader.readUid();
    final cancelling = reader.cancel();
    driver.availabilityGate!.complete(true);
    await cancelling;
    expect(await read, isNull);
    expect(driver.starts, 0);
    expect(driver.stops, 0);
  });

  testWidgets(
    'cancel during start retains ownership until native stop finishes',
    (tester) async {
      final driver = _Driver()..startGate = Completer<void>();
      final reader = NativeScanService(driver: driver);
      final otherDriver = _Driver();
      final other = NativeScanService(driver: otherDriver);
      addTearDown(reader.dispose);
      addTearDown(other.dispose);
      var ready = false;
      final read = reader.readUid(onReady: () => ready = true);
      await tester.pump();
      expect(driver.starts, 1);
      await expectLater(
        other.readUid(),
        throwsA(
          isA<GameStateError>().having(
            (e) => e.localizedMessage.code,
            'code',
            'nfcBusy',
          ),
        ),
      );
      final cancelling = reader.cancel();
      await other.cancel();
      expect(driver.stops, 0);
      final newRead = other.readUid();
      await tester.pump();
      expect(otherDriver.starts, 0);
      driver.onTag!(_uidBytes);
      driver.startGate!.complete();
      await cancelling;
      expect(await read, isNull);
      expect(ready, isFalse);
      expect(driver.stops, 1);
      expect(otherDriver.stops, 0);

      await tester.pump();
      // Old callbacks cannot complete or stop the newer owner's session.
      driver.onTag!(_uidBytes);
      driver.onError!(StateError('late native failure'));
      expect(otherDriver.stops, 0);
      otherDriver.onTag!([4, 0, 0, 0, 0, 0, 2]);
      expect(await newRead, '04000000000002');
      expect(otherDriver.stops, 1);
    },
  );

  testWidgets(
    'iOS native cancel is null and never stops invalidated sheet twice',
    (tester) async {
      final driver = _Driver(opensSystemSheet: true);
      final reader = NativeScanService(driver: driver);
      addTearDown(reader.dispose);
      final read = reader.readUid();
      await tester.pump();
      driver.onError!(null);
      expect(await read, isNull);
      expect(driver.stops, 0);
      expect(driver.starts, 1);
      await tester.pump(const Duration(seconds: 31));
      expect(driver.starts, 1);
    },
  );

  testWidgets(
    'iOS failures and timeout remain errors rather than cancellations',
    (tester) async {
      final driver = _Driver(opensSystemSheet: true);
      final reader = NativeScanService(driver: driver);
      addTearDown(reader.dispose);
      final failed = reader.readUid();
      final failureExpectation = expectLater(
        failed,
        throwsA(
          isA<GameStateError>().having(
            (e) => e.localizedMessage.code,
            'code',
            'nfcInterrupted',
          ),
        ),
      );
      await tester.pump();
      driver.onError!(StateError('system busy'));
      await failureExpectation;

      final timedOut = reader.readUid();
      final timeoutExpectation = expectLater(
        timedOut,
        throwsA(
          isA<GameStateError>().having(
            (e) => e.localizedMessage.code,
            'code',
            'nfcTimeout',
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 30));
      await timeoutExpectation;
      expect(driver.stops, 1);
    },
  );

  testWidgets(
    'Android waits continuously and disposal rejects late discovery',
    (tester) async {
      final driver = _Driver();
      final reader = NativeScanService(driver: driver);
      final read = reader.readUid();
      await tester.pump();
      await tester.pump(const Duration(minutes: 2));
      expect(driver.stops, 0);
      final disposing = reader.dispose();
      driver.onTag!(_uidBytes);
      await disposing;
      expect(await read, isNull);
      expect(driver.stops, 1);
      await expectLater(reader.readUid(), throwsA(isA<GameStateError>()));
    },
  );

  testWidgets('disabled hardware surfaces an error without opening a session', (
    tester,
  ) async {
    final driver = _Driver()..enabled = false;
    final reader = NativeScanService(driver: driver);
    addTearDown(reader.dispose);
    await expectLater(reader.readUid(), throwsA(isA<GameStateError>()));
    expect(driver.starts, 0);
    expect(driver.stops, 0);
    driver.enabled = true;
    final retry = reader.readUid();
    await tester.pump();
    driver.onTag!(_uidBytes);
    expect(await retry, '04A1B2C3D4E5F6');
  });
}
