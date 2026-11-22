import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitcon_backend/game/game_service.dart';
import 'package:sitcon_app/main.dart';
import 'package:sitcon_app/l10n/localization.dart';
import 'package:sitcon_app/services/game/demo_controls.dart';
import 'package:sitcon_app/services/game/mock_game_service.dart';
import 'package:sitcon_app/services/game/demo_game_storage.dart';
import 'package:sitcon_app/services/game/http_game_service.dart';
import 'package:sitcon_backend/game/game_engine.dart';
import 'package:sitcon_app/viewmodels/game_view_model.dart';
import 'package:sitcon_app/views/demo_controls_view.dart';

const _tags = ['AI', 'Vim派', '夜貓族'];
final _now = DateTime.utc(2026, 3, 28, 9);

/// Fail the real HTTP adapter at its transport boundary, not its game contract.
class _UnavailableHttpClient implements HttpClient {
  int requests = 0;
  @override
  set connectionTimeout(Duration? value) {}
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    requests++;
    throw const SocketException('Network forbidden');
  }

  @override
  void close({bool force = false}) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MemoryStorage implements GameStorage {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String value) async {
    this.value = value;
  }
}

class _FailingStorage extends DemoGameStorage {
  _FailingStorage(super.file);
  bool failNext = false;
  @override
  Future<void> write(String value) async {
    if (failNext) {
      failNext = false;
      await File('${file.path}.pending').writeAsString(value, flush: true);
      throw const FileSystemException('simulated commit failure');
    }
    await super.write(value);
  }
}

class _CapabilityService extends GameEngine implements DemoControls {
  _CapabilityService() : super(storage: _MemoryStorage());
  @override
  Future<void> addCoins(int amount) =>
      grantLocalResources(resource: 'coins', amount: amount);
  @override
  Future<void> addPacks(int amount) =>
      grantLocalResources(resource: 'packs', amount: amount);
  @override
  Future<void> setRole(AccountRole role, {String? boothId}) =>
      configureRole(role, boothId: boothId);
}

Future<void> _checkIn(GameService game) async {
  await game.bindBadge(GameEngine.selfUid);
  await game.saveProfile(_tags, 'local only', nickname: '離線玩家');
}

void main() {
  late Directory root;
  File stateFile() => File('${root.path}/offline_demo/state-v1.json');

  setUp(() async {
    root = await Directory.systemTemp.createTemp('sitcon-offline-');
  });
  tearDown(() async {
    await root.delete(recursive: true);
  });

  test('a custom offline station can be scanned without a physical tag', () async {
    final game = await MockGameService.open(directory: root);
    addTearDown(game.dispose);
    await _checkIn(game);
    const id = 'station-custom';
    await game.configureStation(
      Station(id: id, name: 'Custom', packs: 2, limit: 1, remaining: 10, open: true),
    );
    final before = game.packs;
    final first = await game.scanDemoStation(id, 'demo-1', ScannerMode.user);
    expect(first.message.code, 'stationPacks');
    expect(game.packs, before + 2);
    final repeated = await game.scanDemoStation(id, 'demo-2', ScannerMode.user);
    expect(repeated.message.code, 'stationLimit');
    expect(game.packs, before + 2);
  });

  test(
    'factory is server-free, active and unregistered on a fresh install',
    () async {
      var attempts = 0;
      await HttpOverrides.runZoned(
        () async {
          final game = await MockGameService.open(directory: root);
          addTearDown(game.dispose);
          final GameService player = game;
          expect(player.phase, EventPhase.active);
          expect(player.checkedIn, false);
          expect(player.me.tags, isEmpty);
          expect(player.hand, [0, 0, 0, 0]);
          await expectLater(player.openPacks(), throwsA(isA<GameStateError>()));
          await _checkIn(player);
          await game.simulateRemotePacks('local-only', 2, 'offline reward');
          await player.openPacks();
          expect(player.hand.fold<int>(0, (a, b) => a + b), 15);
          expect(await stateFile().exists(), true);
        },
        createHttpClient: (_) {
          attempts++;
          throw StateError('Network forbidden');
        },
      );
      expect(attempts, 0);
    },
  );

  test(
    'whole engine transaction restores phase, inventory, rewards and history',
    () async {
      final game = await MockGameService.open(
        directory: root,
        clock: () => _now,
        random: Random(7),
      );
      await game.setMockPhase(EventPhase.before);
      await game.claimEarly();
      await game.setMockPhase(EventPhase.active);
      await _checkIn(game);
      await game.finishTutorial();
      await game.setRole(AccountRole.staff);
      await game.bindStation('04112233445566', 'station-1');
      await game.scan('04112233445566', 'bound-station');
      await game.scan(GameEngine.checkpointUid(1), 'checkpoint-1');
      await game.simulateAgenda('morning');
      await game.simulateRemotePacks('delivery-1', 3, 'local scenario');
      await game.simulatePhotoReward();
      await game.simulateBoothCompletion('booth-1');
      await game.simulateBoothCompletion('booth-2');
      await game.redeemHint();
      await game.openPacks();
      final opponent = game.demoPlayers.first.id;
      await game.scan(opponent, 'friend');
      await game.requestFriend(opponent);
      await game.simulateReciprocalScan(opponent);
      await game.inviteBattle(opponent);
      await game.simulateReciprocalScan(opponent);
      while (!game.battle!.finished) {
        final other = game.battle!.opponentHand.indexWhere((n) => n > 0);
        await game.playCard(HandCard.values[(other + 1) % 3]);
      }
      await game.buyEgg();
      await game.setMockPhase(EventPhase.ended);
      final committed = game.exportState();
      expect(await stateFile().readAsString(), committed);
      game.dispose();

      final restored = await MockGameService.open(
        directory: root,
        clock: () => _now,
      );
      addTearDown(restored.dispose);
      expect(restored.exportState(), committed);
      expect(restored.phase, EventPhase.ended);
      expect(restored.checkedIn, true);
      expect(restored.me.name, '離線玩家');
      expect(restored.history, hasLength(1));
      expect(restored.friends, hasLength(1));
      expect(restored.role, AccountRole.staff);
      expect(restored.planets.length, 2);
      expect(restored.checkpoints.first.collectedAt, _now);
      final packs = restored.packs;
      final hintProgress = restored.hintRemainder;
      await restored.setMockPhase(EventPhase.active);
      await restored.simulateAgenda('morning');
      await restored.simulateRemotePacks('delivery-1', 3, 'local scenario');
      await restored.simulatePhotoReward();
      await restored.simulateBoothCompletion('booth-1');
      expect(restored.packs, packs);
      expect(restored.hintRemainder, hintProgress);
      await expectLater(
        restored.simulateRemotePacks('delivery-1', 4, 'local scenario'),
        throwsA(isA<GameStateError>()),
      );
      expect(
        (await restored.scan('04112233445566', 'bound-station')).openPacks,
        true,
      );
      expect(restored.packs, packs);
    },
  );

  test('saved pre-event phase is restored rather than forced active', () async {
    final game = await MockGameService.open(directory: root);
    await game.setMockPhase(EventPhase.before);
    await game.claimEarly();
    game.dispose();
    final restored = await MockGameService.open(directory: root);
    addTearDown(restored.dispose);
    expect(restored.phase, EventPhase.before);
    expect(restored.earlyClaimed, true);
    expect(restored.checkedIn, false);
  });

  test('malformed, partial and unsupported documents are never reset or overwritten', () async {
    final game = await MockGameService.open(directory: root);
    await _checkIn(game);
    final valid = game.exportState();
    game.dispose();
    final missingField = (jsonDecode(valid) as Map<String, dynamic>)
      ..remove('coins');
    final badNested = (jsonDecode(valid) as Map<String, dynamic>)
      ..['ledger'] = [
        {
          'at': 'not-a-date',
          'reason': 'reward',
          'detail': 'invalid',
          'coins': 1,
        },
      ];
    final badVersion = (jsonDecode(valid) as Map<String, dynamic>)
      ..['version'] = 99;
    final badHand = (jsonDecode(valid) as Map<String, dynamic>)
      ..['hand'] = [1, 2];
    for (final raw in [
      '{',
      jsonEncode(missingField),
      jsonEncode(badNested),
      jsonEncode(badVersion),
      jsonEncode(badHand),
    ]) {
      await stateFile().writeAsString(raw);
      await expectLater(
        MockGameService.open(directory: root),
        throwsA(isA<GameStateError>()),
      );
      expect(await stateFile().readAsString(), raw);
    }
  });

  test(
    'failed commit rolls back memory and leaves last complete file readable',
    () async {
      final storage = _FailingStorage(stateFile());
      final game = MockGameService(storage: storage, clock: () => _now);
      await game.initialize();
      await _checkIn(game);
      final committed = game.exportState();
      storage.failNext = true;
      await expectLater(
        game.simulateRemotePacks('retry-safe', 5, 'disk test'),
        throwsA(
          isA<GameStateError>().having(
            (e) => e.localizedMessage.code,
            'code',
            'storageFailure',
          ),
        ),
      );
      expect(game.exportState(), committed);
      expect(await stateFile().readAsString(), committed);
      expect(await File('${stateFile().path}.pending').exists(), true);
      game.dispose();
      final restored = await MockGameService.open(
        directory: root,
        clock: () => _now,
      );
      addTearDown(restored.dispose);
      expect(restored.exportState(), committed);
      await restored.simulateRemotePacks('retry-safe', 5, 'disk test');
      expect(restored.packs, 5);
      expect(
        restored.ledger.where((e) => e.reason == 'mock.remote'),
        hasLength(1),
      );
    },
  );

  test(
    'connected transport failure never opens or mutates offline state',
    () async {
      final local = await MockGameService.open(directory: root);
      await _checkIn(local);
      final committed = await stateFile().readAsString();
      local.dispose();
      final transport = _UnavailableHttpClient();
      await HttpOverrides.runZoned(() async {
        final server = HttpGameService(
          baseUrl: 'http://127.0.0.1:1',
          playerId: 'offline-isolation-fixture',
        );
        try {
          expect(server, isNot(isA<DemoControls>()));
          await expectLater(
            server.initialize(),
            throwsA(
              isA<GameStateError>().having(
                (e) => e.localizedMessage.code,
                'code',
                'networkUnavailable',
              ),
            ),
          );
          expect(await stateFile().readAsString(), committed);
        } finally {
          server.dispose();
        }
      }, createHttpClient: (_) => transport);
      expect(transport.requests, 1);
    },
  );

  test(
    'ordinary adapters do not gain the explicit local scenario capability',
    () async {
      final game = GameEngine(storage: _MemoryStorage());
      await game.initialize();
      final vm = GameViewModel(game);
      expect(vm.isOfflineDemo, false);
      expect(vm.demoControls, isNull);
      expect(vm.testToolsEnabled, const bool.fromEnvironment('TEST_GAMEPLAY'));
      vm.dispose();
      game.dispose();
    },
  );

  test('local grants repeat, serialize and persist in every phase without ranking effects', () async {
    final game = await MockGameService.open(directory: root);
    final DemoControls controls = game;
    for (final phase in EventPhase.values) {
      await controls.setMockPhase(phase);
      await Future.wait([
        controls.addCoins(100),
        controls.addCoins(100),
        controls.addPacks(2),
        controls.addPacks(2),
      ]);
      expect(game.checkedIn, false);
      expect(game.points, 0);
    }
    expect(game.coins, 600);
    expect(game.packs, 12);
    expect(game.ledger.where((e) => e.reason == 'cheat.coins'), hasLength(6));
    expect(game.ledger.where((e) => e.reason == 'cheat.packs'), hasLength(6));
    expect(game.ledger.fold<int>(0, (sum, e) => sum + e.coins), game.coins);
    expect(game.ranking('points').single.value, 0);
    game.dispose();
    final restored = await MockGameService.open(directory: root);
    addTearDown(restored.dispose);
    expect(restored.coins, 600);
    expect(restored.packs, 12);
    expect(restored.phase, EventPhase.ended);
    await restored.setMockPhase(EventPhase.active);
    await _checkIn(restored);
    await restored.openPacks();
    final planet = await restored.buyEgg();
    expect(restored.packs, 11);
    expect(restored.hand.fold<int>(0, (sum, count) => sum + count), 15);
    expect(restored.planets, contains(planet.planet));
    expect(restored.coins, 590);
    expect(restored.points, 0);
  });

  test('bad grants and failed writes roll back both resources and their ledger entries', () async {
    final storage = _FailingStorage(stateFile());
    final game = MockGameService(storage: storage);
    await game.initialize();
    addTearDown(game.dispose);
    var notifications = 0;
    game.addListener(() => notifications++);
    await game.addCoins(100);
    await game.addPacks(2);
    final committed = game.exportState();
    expect(notifications, 2);
    final badAmount = throwsA(
      isA<GameArgumentError>().having(
        (e) => e.localizedMessage.code,
        'code',
        'invalidGrant',
      ),
    );
    for (final amount in [0, -1]) {
      await expectLater(game.addCoins(amount), badAmount);
      await expectLater(game.addPacks(amount), badAmount);
      expect(game.exportState(), committed);
    }
    for (final grant in [game.addCoins, game.addPacks]) {
      await expectLater(
        grant(0x7fffffffffffffff),
        throwsA(
          isA<GameArgumentError>().having(
            (e) => e.localizedMessage.code,
            'code',
            'grantTooLarge',
          ),
        ),
      );
      expect(game.exportState(), committed);
      storage.failNext = true;
      await expectLater(
        grant(7),
        throwsA(
          isA<GameStateError>().having(
            (e) => e.localizedMessage.code,
            'code',
            'storageFailure',
          ),
        ),
      );
      expect(game.exportState(), committed);
      expect(await stateFile().readAsString(), committed);
    }
    expect(notifications, 2);
    final other = await MockGameService.open(
      directory: Directory('${root.path}/other'),
    );
    addTearDown(other.dispose);
    expect(other.coins, 0);
    expect(other.packs, 0);
    await other.addCoins(5);
    expect(game.coins, 100);
    expect(game.packs, 2);
  });

  test(
    'view model depends on the local capability rather than a concrete adapter',
    () async {
      final game = _CapabilityService();
      await game.initialize();
      final vm = GameViewModel(game);
      expect(vm.isOfflineDemo, true);
      expect(vm.demoControls, same(game));
      await vm.run(() => vm.demoControls!.addCoins(5));
      expect(vm.coins, 5);
      final failure = GameArgumentError(const GameMessage('invalidGrant'));
      await vm.run<void>(() async => throw failure);
      expect(vm.error, same(failure));
      vm.dispose();
      game.dispose();
    },
  );
  testWidgets('default build shows a test server preset without an env file', (
    tester,
  ) async {
    await tester.pumpWidget(const AppStartup(initialMode: '', serverUrls: ''));
    final field = find.byKey(const ValueKey('test-server-url'));
    final initial = tester.widget<TextFormField>(field).controller!.text;
    await tester.enterText(field, 'https://custom.test');
    await tester.tap(find.widgetWithText(ActionChip, initial));
    expect(tester.widget<TextFormField>(field).controller!.text, initial);
  });

  testWidgets(
    'startup selects explicitly and server errors have no automatic fallback',
    (tester) async {
      final selected = <AppMode>[];
      await tester.pumpWidget(
        AppStartup(
          initialMode: '',
          serverUrls: 'https://first.test,https://example.test:8443',
          serviceFactory: (mode) async {
            selected.add(mode);
            throw StateError('Server unavailable');
          },
        ),
      );
      expect(find.byKey(const ValueKey('mode-demo')), findsOneWidget);
      expect(find.byKey(const ValueKey('mode-server')), findsOneWidget);
      expect(selected, isEmpty);
      final field = find.byKey(const ValueKey('test-server-url'));
      await tester.enterText(field, 'https://user:password@example.test');
      await tester.tap(find.byKey(const ValueKey('mode-server')));
      await tester.pumpAndSettle();
      expect(selected, isEmpty);
      await tester.tap(find.text('https://example.test:8443'));
      expect(
        tester.widget<TextFormField>(field).controller!.text,
        'https://example.test:8443',
      );
      await tester.tap(find.byKey(const ValueKey('mode-server')));
      await tester.pumpAndSettle();
      expect(selected, [AppMode.server]);
      expect(find.byKey(const ValueKey('startup-error')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('startup-retry')));
      await tester.pumpAndSettle();
      expect(selected, [AppMode.server, AppMode.server]);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('explicit server build reports failure without trying demo', (
    tester,
  ) async {
    final selected = <AppMode>[];
    await tester.pumpWidget(
      AppStartup(
        initialMode: 'server',
        serviceFactory: (mode) async {
          selected.add(mode);
          throw StateError('Transport unavailable');
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(selected, [AppMode.server]);
    expect(find.byKey(const ValueKey('startup-error')), findsOneWidget);
    expect(find.byKey(const ValueKey('mode-demo')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'explicit demo build opens only demo factory and exposes local capability',
    (tester) async {
      final game = MockGameService(storage: _MemoryStorage());
      await game.initialize();
      final selected = <AppMode>[];
      await tester.pumpWidget(
        AppStartup(
          initialMode: 'demo',
          serviceFactory: (mode) async {
            selected.add(mode);
            return game;
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(selected, [AppMode.demo]);
      expect(find.byKey(const ValueKey('mode-demo')), findsNothing);
      final vm = GameViewModel(game);
      expect(vm.isOfflineDemo, true);
      expect(vm.testToolsEnabled, true);
      expect(vm.demoControls, same(game));
      vm.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('cheat controls grant resources repeatedly before check-in', (
    tester,
  ) async {
    final game = MockGameService(storage: _MemoryStorage());
    await game.initialize();
    final vm = GameViewModel(game);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: expressiveTheme(Brightness.light),
        home: DemoControlsView(vm: vm),
      ),
    );
    final coinAmount = find.byKey(const ValueKey('cheat-coins-amount'));
    final coinAdd = find.byKey(const ValueKey('cheat-coins-add'));
    await tester.enterText(coinAmount, '100');
    await tester.ensureVisible(coinAdd);
    await tester.tap(coinAdd);
    await tester.pumpAndSettle();
    await tester.tap(coinAdd);
    await tester.pumpAndSettle();
    expect(game.coins, 200);
    expect(game.points, 0);
    final packAmount = find.byKey(const ValueKey('cheat-packs-amount'));
    final packAdd = find.byKey(const ValueKey('cheat-packs-add'));
    await tester.ensureVisible(packAmount);
    await tester.enterText(packAmount, '2');
    await tester.ensureVisible(packAdd);
    await tester.tap(packAdd);
    await tester.pumpAndSettle();
    expect(game.packs, 2);
    expect(game.checkedIn, false);
    await tester.pumpWidget(const SizedBox.shrink());
    vm.dispose();
    game.dispose();
  });
}
