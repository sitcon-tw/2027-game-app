import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitcon_backend/game/game_service.dart';
import 'package:sitcon_app/main.dart';
import 'package:sitcon_app/services/game/mock_game_service.dart';
import 'package:sitcon_backend/game/game_engine.dart';
import 'package:sitcon_app/views/collection_view.dart';
import 'package:sitcon_app/views/profile_view.dart';
import 'package:sitcon_app/views/social_view.dart';
import 'package:sitcon_app/views/tasks_view.dart';
import 'package:sitcon_app/views/demo_controls_view.dart';
import 'package:sitcon_app/views/utility_views.dart';
import 'package:sitcon_app/widgets/cosmic_widgets.dart';

class _Storage implements GameStorage {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String value) async {
    this.value = value;
  }
}

class _InventoryNoticeGame extends GameEngine {
  _InventoryNoticeGame() : super(storage: _Storage());
  final _serverEntries = <LedgerEntry>[];

  @override
  List<LedgerEntry> get ledger => [..._serverEntries, ...super.ledger];

  void publishAdjustments() {
    _serverEntries.insertAll(0, [
      LedgerEntry(now, 'admin.inventory', '', args: {
        'resource': 'packs', 'delta': -2, 'reason': 'Duplicate reward',
      }),
      LedgerEntry(now, 'admin.inventory', '', args: {
        'resource': 'coins', 'delta': 12, 'reason': 'Event bonus',
      }),
    ]);
    notifyListeners();
  }
}

Future<GameEngine> launch(
  WidgetTester tester, {
  bool checkedIn = true,
  AccountRole role = AccountRole.user,
  GameEngine? game,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(402, 874);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final service = game ?? GameEngine(storage: _Storage());
  await service.initialize();
  await service.configureRole(
    role,
    boothId: role == AccountRole.booth ? service.booths.first.id : null,
  );
  if (checkedIn) {
    await service.setMockPhase(EventPhase.active);
    await service.bindBadge(GameEngine.selfUid);
    await service.saveProfile(['AI', 'Vim派', '夜貓族'], '');
    await service.finishTutorial();
  }
  await tester.pumpWidget(SitconApp(service: service));
  await tester.pumpAndSettle();
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    service.dispose();
  });
  return service;
}

Finder keyed(String key) => find.byKey(ValueKey(key));

void main() {
  testWidgets('bottom navigation stays reachable on phones and tablets', (
    tester,
  ) async {
    await launch(tester);
    for (final size in [const Size(320, 740), const Size(1000, 1100)]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      final nav = keyed('player-navigation');
      expect(tester.getRect(nav).bottom, size.height);
      expect(find.byType(Drawer), findsNothing);
      expect(find.byKey(const ValueKey('mock-controls')), findsNothing);
      expect(
        find.byKey(const ValueKey('mock-controls-shortcut')),
        findsNothing,
      );
      await tester.tap(keyed('tab-tasks'));
      await tester.pumpAndSettle();
      expect(find.byType(TasksView), findsOneWidget);
      expect(tester.widget<NavigationBar>(nav).selectedIndex, 2);
      await tester.tap(keyed('scan-open'));
      await tester.pumpAndSettle();
      expect(find.byType(ScanView), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(tester.widget<NavigationBar>(nav).selectedIndex, 2);
      await tester.tap(keyed('tab-mycard'));
      await tester.pumpAndSettle();
      expect(tester.widget<NavigationBar>(nav).selectedIndex, 1);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('server changes show signed amounts and reasons in order', (
    tester,
  ) async {
    final game = _InventoryNoticeGame();
    await launch(tester, game: game);
    await game.simulateRemotePacks('remote-1', 3, 'Check-in bonus');
    await tester.pumpAndSettle();
    expect(find.text('Packs +3\n\nCheck-in bonus'), findsOneWidget);
    await tester.tap(keyed('reward-dismiss'));
    await tester.pumpAndSettle();
    game.publishAdjustments();
    await tester.pumpAndSettle();
    expect(find.text('Inventory added'), findsOneWidget);
    expect(find.text('Coins +12\n\nEvent bonus'), findsOneWidget);
    await tester.tap(keyed('reward-dismiss'));
    await tester.pumpAndSettle();
    expect(find.text('Inventory removed'), findsOneWidget);
    expect(find.text('Packs −2\n\nDuplicate reward'), findsOneWidget);
    await tester.tap(keyed('reward-dismiss'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('back from repeated egg reveals returns directly to home', (
    tester,
  ) async {
    final game = GameEngine(storage: _Storage());
    await game.grantLocalResources(resource: 'coins', amount: 50);
    await launch(tester, game: game);
    await tester.tap(keyed('tab-more'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      keyed('more-shop'),
      200,
      scrollable: find.descendant(
        of: keyed('more-actions'),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(keyed('more-shop'));
    await tester.pumpAndSettle();
    await tester.tap(keyed('egg-random'));
    for (var purchase = 0; purchase < 3; purchase++) {
      await tester.pumpAndSettle();
      await tester.tap(keyed('egg-confirm'));
      await tester.pumpAndSettle();
      await tester.tap(keyed('hatch-reveal'));
      await tester.pumpAndSettle();
      if (purchase < 2) {
        await tester.scrollUntilVisible(
          keyed('hatch-again'),
          160,
          scrollable: find.descendant(
            of: find.byType(HatchView),
            matching: find.byType(Scrollable),
          ),
        );
        await tester.tap(keyed('hatch-again'));
      }
    }
    expect(game.planets, hasLength(3));
    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(find.byType(HatchView), findsNothing);
    expect(keyed('player-navigation'), findsOneWidget);
  });

  testWidgets('system Back dismisses More and keeps the current tab', (
    tester,
  ) async {
    await launch(tester);
    await tester.tap(keyed('tab-more'));
    await tester.pumpAndSettle();
    expect(keyed('more-actions'), findsOneWidget);
    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(keyed('more-actions'), findsNothing);
    expect(
      tester.widget<NavigationBar>(keyed('player-navigation')).selectedIndex,
      1,
    );
  });

  testWidgets(
    'More opens every secondary player feature and preserves the current tab',
    (tester) async {
      await launch(tester);
      final destinations = <(String, Type)>[
        ('more-packs', PackView),
        ('more-shop', CosmicPage),
        ('more-collection', CollectionView),
        ('more-friends', FriendsView),
        ('more-rankings', RankingView),
        ('more-profile', ProfileEditor),
        ('more-appearance', CollectionView),
        ('more-ledger', LedgerView),
        ('more-history', LedgerView),
        ('recap-open', RecapView),
        ('early-open', CosmicPage),
        ('tutorial-open', TutorialView),
      ];
      for (final (key, type) in destinations) {
        await tester.tap(keyed('tab-more'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          keyed(key),
          280,
          scrollable: find.descendant(
            of: keyed('more-actions'),
            matching: find.byType(Scrollable),
          ),
        );
        await Scrollable.ensureVisible(
          tester.element(keyed(key)),
          alignment: .5,
        );
        await tester.pumpAndSettle();
        await tester.tap(keyed(key));
        await tester.pumpAndSettle();
        expect(
          find.byType(type),
          findsOneWidget,
          reason: '$key opens its feature',
        );
        expect(keyed('more-actions'), findsNothing);
        if (key == 'more-history') {
          expect(
            tester.widget<LedgerView>(find.byType(LedgerView)).battles,
            true,
          );
        }
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<NavigationBar>(keyed('player-navigation'))
              .selectedIndex,
          1,
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'No render errors after $key',
        );
      }
    },
  );

  testWidgets(
    'before check-in only onboarding and public help are accessible',
    (tester) async {
      await launch(tester, checkedIn: false);
      for (final key in ['tab-game', 'tab-tasks', 'scan-open']) {
        expect(tester.widget<NavigationDestination>(keyed(key)).enabled, false);
      }
      await tester.tap(keyed('tab-more'));
      await tester.pumpAndSettle();
      expect(keyed('early-open'), findsOneWidget);
      expect(keyed('tutorial-open'), findsOneWidget);
      expect(keyed('more-profile'), findsNothing);
      expect(keyed('more-friends'), findsNothing);
      await tester.tap(keyed('early-open'));
      await tester.pumpAndSettle();
      expect(find.byType(CosmicPage), findsOneWidget);
      expect(find.byType(EarlyBirdCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final role in [AccountRole.staff, AccountRole.booth]) {
    testWidgets(
      '${role.name} can open its operator scanner before personal check-in',
      (tester) async {
        await launch(tester, role: role, checkedIn: false);
        expect(
          tester.widget<NavigationDestination>(keyed('scan-open')).enabled,
          isTrue,
        );
        expect(
          tester.widget<NavigationDestination>(keyed('tab-game')).enabled,
          isFalse,
        );
        expect(
          tester.widget<NavigationDestination>(keyed('tab-tasks')).enabled,
          isFalse,
        );
        expect(keyed('home-account-role'), findsOneWidget);
        await tester.tap(keyed('scan-open'));
        await tester.pumpAndSettle();
        final vm = tester.widget<ScanView>(find.byType(ScanView)).vm;
        expect(vm.scannerMode.name, role.name);
        expect(find.byType(DropdownMenu<AccountRole>), findsNothing);
        expect(keyed('scan-mode-user'), findsOneWidget);
        expect(keyed('scan-mode-${role.name}'), findsOneWidget);
        expect(
          keyed('scan-mode-${role == AccountRole.staff ? 'booth' : 'staff'}'),
          findsNothing,
        );
        if (role == AccountRole.booth) {
          expect(keyed('operator-assigned-booth'), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('role revocation removes pre-check-in operator scanner access', (
    tester,
  ) async {
    final game = await launch(
      tester,
      role: AccountRole.staff,
      checkedIn: false,
    );
    expect(
      tester.widget<NavigationDestination>(keyed('scan-open')).enabled,
      isTrue,
    );
    await game.configureRole(AccountRole.user);
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationDestination>(keyed('scan-open')).enabled,
      isFalse,
    );
    expect(keyed('checkin-native'), findsOneWidget);
    expect(find.byType(DropdownMenu<AccountRole>), findsNothing);
  });

  testWidgets(
    'offline scenarios change service roles and assigned booth, not profile tags',
    (tester) async {
      final game = MockGameService(storage: _Storage());
      await launch(tester, checkedIn: false, game: game);
      final tags = List.of(game.me.tags);
      await tester.tap(keyed('tab-more'));
      await tester.pumpAndSettle();
      await tester.tap(keyed('more-demo-tools'));
      await tester.pumpAndSettle();
      expect(find.byType(DemoControlsView), findsOneWidget);
      await tester.tap(keyed('demo-scenarios'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        keyed('demo-role-user'),
        400,
        scrollable: find
            .descendant(
              of: keyed('demo-controls-list'),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      final roleMenu = tester.widget<DropdownMenu<AccountRole>>(
        keyed('demo-role-user'),
      );
      roleMenu.onSelected!(AccountRole.staff);
      await tester.pumpAndSettle();
      expect(game.role, AccountRole.staff);
      expect(game.boothId, isNull);
      tester
          .widget<DropdownMenu<AccountRole>>(keyed('demo-role-staff'))
          .onSelected!(AccountRole.booth);
      await tester.pumpAndSettle();
      expect(game.role, AccountRole.booth);
      expect(game.boothId, game.booths.first.id);
      final boothMenu = keyed('demo-assigned-booth-${game.boothId}');
      await tester.ensureVisible(boothMenu);
      tester.widget<DropdownMenu<String>>(boothMenu).onSelected!(
        game.booths[1].id,
      );
      await tester.pumpAndSettle();
      expect(game.boothId, game.booths[1].id);
      tester
          .widget<DropdownMenu<AccountRole>>(keyed('demo-role-booth'))
          .onSelected!(AccountRole.user);
      await tester.pumpAndSettle();
      expect(game.role, AccountRole.user);
      expect(game.boothId, isNull);
      expect(game.me.tags, tags);
      expect(find.byType(DropdownMenu<String>), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'test check-in binds the editable UID and keeps the offline default',
    (tester) async {
      final game = MockGameService(storage: _Storage());
      await launch(tester, checkedIn: false, game: game);
      final field = keyed('checkin-test-uid');
      expect(
        tester.widget<TextField>(field).controller!.text,
        GameEngine.selfUid,
      );
      const uid = '04A1B2C3D4E5F7';
      await tester.enterText(field, uid);
      await tester.ensureVisible(keyed('checkin-mock-bind'));
      await tester.tap(keyed('checkin-mock-bind'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileEditor), findsOneWidget);
      await game.bindBadge(
        uid,
      ); // The entered UID is already bound (idempotent).
      await expectLater(
        game.bindBadge(GameEngine.selfUid),
        throwsA(isA<GameStateError>()),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
