import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sitcon_backend/game/game_service.dart';
import 'package:sitcon_app/main.dart';
import 'package:sitcon_backend/game/game_engine.dart';

import 'flow_support.dart';
import 'test_server_support.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;
  testWidgets('Expressive player app receives separate dashboard changes', (
    tester,
  ) async {
    final badgeUid = createTestBadgeUid();
    final game = await testInstallation().open(testApiBase);
    final playerId = game.playerId;
    await game.initialize();
    await adminAction('phase', {'phase': 'active'});
    await game.tick();
    await tester.pumpWidget(SitconApp(service: game));
    await tester.pumpAndSettle();
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pump();
    }
    Future<void> shot(String name) async {
      await tester.pump(const Duration(milliseconds: 300));
      await binding.takeScreenshot(
        '${Platform.operatingSystem}-expressive-$name',
      );
    }

    if (!game.checkedIn) {
      await tester.enterText(
        await findControl(tester, 'checkin-test-uid'),
        badgeUid,
      );
      await tapKey(tester, 'checkin-mock-bind');
      for (final tag in ['AI', 'Vim派', '夜貓族']) {
        final chip = tester.widget<FilterChip>(
          await findControl(tester, 'tag-$tag'),
        );
        if (!chip.selected) await tapKey(tester, 'tag-$tag');
      }
      await tapKey(tester, 'profile-save');
      await dismissRewards(tester);
      await tapKey(tester, 'tutorial-skip');
    }
    expect(game.checkedIn, true);
    expect(keyed('mock-controls-shortcut'), findsNothing);
    expect(keyed('mock-controls'), findsNothing);
    await shot('my-card');
    final previousPacks = game.packs;
    final deliveryId = 'device-${DateTime.now().microsecondsSinceEpoch}';
    await adminAction('remotePacks', {
      'playerId': playerId,
      'deliveryId': deliveryId,
      'amount': 2,
      'reason': '獨立 Dashboard 補給驗證',
    });
    await until(
      tester,
      () => game.packs == previousPacks + 2,
      reason: 'dashboard pack grant reaches running player',
    );
    await dismissRewards(tester);
    await tapKey(tester, 'tab-more');
    await shot('more-actions');
    await tapKey(tester, 'more-packs');
    await tapKey(tester, 'pack-tear');
    await tapKey(tester, 'pack-skip');
    await tapKey(tester, 'pack-done');
    expect(game.packs, previousPacks + 1);

    await tapKey(tester, 'profile-edit');
    await tester.enterText(keyed('profile-contact'), '@expressive-test');
    await tapKey(tester, 'profile-save');
    expect(game.me.contact, '@expressive-test');

    Future<void> scanUid(String uid) async {
      await tapKey(tester, 'scan-open');
      await tester.enterText(keyed('scan-uid'), uid);
      await tapKey(tester, 'scan-submit');
      await dismissRewards(tester);
    }

    await scanUid(GameEngine.checkpointUid(1));
    expect(game.checkpoints.first.collectedAt, isNotNull);
    await back(tester);
    await scanUid(GameEngine.playerUid(1));
    if (!game.friends.any((p) => p.id == GameEngine.playerUid(1))) {
      await tapKey(tester, 'player-friend');
      await tapKey(tester, 'player-reciprocal');
      await dismissRewards(tester);
    }
    expect(game.friends.any((p) => p.id == GameEngine.playerUid(1)), true);
    await back(tester);
    await back(tester);
    await tapKey(tester, 'tab-tasks');
    await shot('missions');
    await tapKey(tester, 'tasks-checkpoint');
    await tapKey(tester, 'checkpoint-1');
    await back(tester);
    await tapKey(tester, 'tab-mycard');
    await tapKey(tester, 'tab-more');
    await tapKey(tester, 'more-friends');
    expect(find.text(game.friends.first.name), findsWidgets);
    await back(tester);
    await tapKey(tester, 'tab-more');
    await tapKey(tester, 'more-rankings');
    await shot('rankings');
    await back(tester);
    await tapKey(tester, 'tab-game');
    await shot('game');

    await adminAction('parameters', {'randomEggPrice': 7});
    await until(
      tester,
      () => game.randomEggPrice == 7,
      reason: 'live economy config reaches app',
    );
    await adminAction('phase', {'phase': 'ended'});
    await until(
      tester,
      () => game.phase == EventPhase.ended,
      reason: 'dashboard closes player gameplay',
    );
    expect(game.battleBlocked(game.demoPlayers.first), isNotNull);
    await tapKey(tester, 'tab-mycard');
    await tapKey(tester, 'tab-more');
    await tapKey(tester, 'recap-open');
    expect(
      tester.getSize(keyed('recap-story')).aspectRatio,
      closeTo(9 / 16, .001),
    );
    await shot('recap');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    game.dispose();
  });
}
