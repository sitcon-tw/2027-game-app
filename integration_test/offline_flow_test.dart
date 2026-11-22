import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sitcon_backend/game/game_service.dart';
import 'package:sitcon_app/main.dart';
import 'package:sitcon_app/l10n/localization.dart';
import 'package:sitcon_app/services/preferences/app_locale_settings.dart';
import 'package:sitcon_app/services/game/mock_game_service.dart';
import 'package:sitcon_backend/testing/test_tag_ids.dart';

import 'flow_support.dart';

class _NoNetwork extends HttpOverrides {
  int attempts = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw StateError('Offline gameplay must not create an HTTP client');
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;
  testWidgets('Offline app plays and restores progress with HTTP prohibited', (
    tester,
  ) async {
    final directory = await (await getTemporaryDirectory()).createTemp(
      'sitcon-offline-journey-',
    );
    final previous = HttpOverrides.current;
    final noNetwork = _NoNetwork();
    HttpOverrides.global = noNetwork;
    AppLanguage? previousLanguage;
    late MockGameService game;
    Future<GameService> open(AppMode mode) async {
      if (mode != AppMode.demo) {
        throw StateError('Expected explicit offline selection');
      }
      game = await MockGameService.open(
        directory: directory,
        random: Random(7),
      );
      return game;
    }

    Future<void> shot(String name) async {
      await tester.pump(const Duration(milliseconds: 300));
      await binding.takeScreenshot('${Platform.operatingSystem}-offline-$name');
    }

    Future<void> tools({bool scenarios = false}) async {
      await tapKey(tester, 'tab-more');
      await tapKey(tester, 'more-demo-tools');
      if (scenarios) await tapKey(tester, 'demo-scenarios');
    }

    Future<void> language(AppLanguage value) async {
      await tapKey(tester, 'tab-more');
      await tapKey(tester, 'more-language');
      await tapKey(tester, 'language-${value.name}');
      await waitFor(
        tester,
        find.text(value == AppLanguage.zhTw ? '語言' : 'Language'),
      );
      expect(appLocaleSettings.value, value);
      await back(tester);
    }

    try {
      await appLocaleSettings.load();
      previousLanguage = appLocaleSettings.value;
      await appLocaleSettings.setLanguage(AppLanguage.en);
      await tester.pumpWidget(
        AppStartup(initialMode: '', serviceFactory: open),
      );
      await tester.pumpAndSettle();
      if (Platform.isAndroid) {
        await binding.convertFlutterSurfaceToImage();
        await tester.pump();
      }
      await shot('mode-picker');
      await tapKey(tester, 'mode-demo');
      expect(game.phase, EventPhase.active);
      expect(game.checkedIn, false);
      await tools(scenarios: true);
      await tapKey(tester, 'demo-phase-before');
      expect(game.phase, EventPhase.before);
      await tapKey(tester, 'demo-phase-active');
      await back(tester);
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
      expect(game.checkedIn, true);
      await tools();
      final pointsBeforeCheats = game.points;
      final coinsBeforeCheats = game.coins;
      await tester.enterText(keyed('cheat-coins-amount'), '0');
      await tapKey(tester, 'cheat-coins-add');
      expect(game.coins, coinsBeforeCheats);
      expect(
        tester.widget<Text>(keyed('demo-error')).data,
        AppLocalizations.of(tester.element(keyed('demo-error')))
            .domainInvalidGrant,
      );
      await tester.enterText(keyed('cheat-coins-amount'), '333');
      await tapKey(tester, 'cheat-coins-add');
      await tapKey(tester, 'cheat-coins-add');
      expect(game.coins, coinsBeforeCheats + 666);
      expect(game.points, pointsBeforeCheats);
      await tester.enterText(keyed('cheat-packs-amount'), '2');
      await tapKey(tester, 'cheat-packs-add');
      await tapKey(tester, 'cheat-packs-add');
      expect(game.packs, 4);
      await tapKey(tester, 'demo-scenarios');
      await tester.enterText(keyed('demo-pack-amount'), '2');
      await tapKey(tester, 'demo-remote-packs');
      await dismissRewards(tester);
      expect(game.packs, 6);
      await tapKey(tester, 'demo-remote-packs');
      await dismissRewards(tester);
      expect(
        game.packs,
        6,
        reason: 'Repeating the same local delivery must not duplicate rewards',
      );
      await shot('controls');
      await back(tester);
      await language(AppLanguage.zhTw);
      await tools();
      await tester.enterText(keyed('cheat-packs-amount'), '0');
      await tapKey(tester, 'cheat-packs-add');
      expect(game.packs, 6);
      expect(
        tester.widget<Text>(keyed('demo-error')).data,
        AppLocalizations.of(tester.element(keyed('demo-error')))
            .domainInvalidGrant,
      );
      await shot('cheats-zh-TW');
      await back(tester);
      await language(AppLanguage.en);
      await tapKey(tester, 'tab-more');
      await tapKey(tester, 'more-packs');
      await tapKey(tester, 'pack-tear');
      await tapKey(tester, 'pack-skip');
      await tapKey(tester, 'pack-done');
      expect(game.packs, 5);
      expect(game.hand.fold<int>(0, (sum, count) => sum + count), 15);
      await tapKey(tester, 'scan-open');
      await tester.enterText(keyed('scan-uid'), TestTagIds.checkpointUid(1));
      await tapKey(tester, 'scan-submit');
      await dismissRewards(tester);
      expect(game.checkpoints.first.collectedAt, isNotNull);
      await shot('scanner');
      await back(tester);
      final mission = game.missions.first;
      final partners = game.demoPlayers
          .where((player) => player.tags.contains(mission.tag))
          .take(3)
          .toList();
      expect(partners, hasLength(3));
      for (final partner in partners) {
        await game.scan(partner.id, 'offline-friend-${partner.id}');
        await game.requestFriend(partner.id);
        await game.simulateReciprocalScan(partner.id);
      }
      await tester.pump();
      await dismissRewards(tester);
      expect(game.missions.first.completedAt, isNotNull);
      expect(game.coins, greaterThanOrEqualTo(game.randomEggPrice));
      await tapKey(tester, 'tab-more');
      await tapKey(tester, 'more-shop');
      await tapKey(tester, 'egg-random');
      await tapKey(tester, 'egg-confirm');
      await tapKey(tester, 'hatch-reveal');
      expect(game.planets, hasLength(1));
      await back(tester);
      await back(tester);
      await tools(scenarios: true);
      await tapKey(tester, 'demo-phase-ended');
      await back(tester);
      await tapKey(tester, 'tab-more');
      await tapKey(tester, 'recap-open');
      expect(
        tester.getSize(keyed('recap-story')).aspectRatio,
        closeTo(9 / 16, .001),
      );
      await shot('recap');
      final coins = game.coins;
      final hand = List<int>.of(game.hand);
      final planets = Set<int>.of(game.planets);
      final badge = game.me.id;
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      appLocaleSettings.value = AppLanguage.system;
      await appLocaleSettings.load();
      expect(appLocaleSettings.value, AppLanguage.en);
      await tester.pumpWidget(
        AppStartup(initialMode: 'demo', serviceFactory: open),
      );
      await tester.pumpAndSettle();
      await waitFor(tester, keyed('player-navigation'));
      expect(keyed('startup-error'), findsNothing);
      expect(game.phase, EventPhase.ended);
      expect(game.checkedIn, true);
      expect(game.me.id, badge);
      expect(game.hand, hand);
      expect(game.coins, coins);
      expect(game.planets, planets);
      expect(game.friends, hasLength(3));
      expect(game.checkpoints.first.collectedAt, isNotNull);
      expect(game.packs, 5);
      expect(noNetwork.attempts, 0);
      await shot('restored');
      expect(tester.takeException(), isNull);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      HttpOverrides.global = previous;
      if (previousLanguage != null) {
        await appLocaleSettings.setLanguage(previousLanguage);
      }
      await directory.delete(recursive: true);
    }
  });
}
