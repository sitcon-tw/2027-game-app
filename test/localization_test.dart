import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitcon_app/main.dart';
import 'package:sitcon_app/services/preferences/app_locale_settings.dart';
import 'package:sitcon_app/services/game/mock_game_service.dart';
import 'package:sitcon_backend/game/game_engine.dart';
import 'package:sitcon_backend/testing/test_tag_ids.dart';

import '../integration_test/flow_support.dart';

class _MemoryStorage implements GameStorage {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String value) async {
    this.value = value;
  }
}

void main() {
  test(
    'language preferences and offline progress restore independently',
    () async {
      final directory = await Directory.systemTemp.createTemp('sitcon-locale-');
      addTearDown(() => directory.delete(recursive: true));
      final game = await MockGameService.open(directory: directory);
      await game.addCoins(39);
      await game.addPacks(4);
      final settings = AppLocaleSettings(directory: directory);
      await settings.setLanguage(AppLanguage.zhTw);
      game.dispose();

      final restoredSettings = AppLocaleSettings(directory: directory);
      await restoredSettings.load();
      expect(restoredSettings.value, AppLanguage.zhTw);
      expect(restoredSettings.locale, const Locale('zh', 'TW'));
      final restoredGame = await MockGameService.open(directory: directory);
      addTearDown(restoredGame.dispose);
      expect(restoredGame.coins, 39);
      expect(restoredGame.packs, 4);
      expect(restoredGame.points, 0);

      await restoredSettings.setLanguage(AppLanguage.system);
      final systemSettings = AppLocaleSettings(directory: directory);
      await systemSettings.load();
      expect(systemSettings.locale, isNull);
    },
  );

  testWidgets(
    'language switching preserves unsaved profile edits and gameplay',
    (tester) async {
      final game = MockGameService(storage: _MemoryStorage());
      await game.initialize();
      await game.bindBadge(TestTagIds.selfUid);
      await game.saveProfile(['AI', 'Vim派', '夜貓族'], 'contact@example.test');
      await game.finishTutorial();
      await game.addCoins(41);
      await game.addPacks(2);
      final previousLanguage = appLocaleSettings.value;
      appLocaleSettings.value = AppLanguage.en;
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 740);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        game.dispose();
        appLocaleSettings.value = previousLanguage;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });
      await tester.pumpWidget(SitconApp(service: game));
      await tester.pumpAndSettle();
      await tapKey(tester, 'tab-more');
      await tapKey(tester, 'more-profile');
      final nickname = keyed('profile-nickname');
      final cjk = RegExp(r'[\u3400-\u9FFF]');
      expect(
        tester.widget<TextField>(nickname).decoration!.labelText,
        isNot(matches(cjk)),
      );
      await tester.enterText(nickname, 'Edited 選名');
      final originalName = game.me.name;
      final points = game.points;
      appLocaleSettings.value = AppLanguage.zhTw;
      await tester.pumpAndSettle();
      expect(
        Localizations.localeOf(tester.element(nickname)),
        const Locale('zh', 'TW'),
      );
      expect(
        tester.widget<TextField>(nickname).decoration!.labelText,
        matches(cjk),
      );
      expect(find.text('Edited 選名'), findsOneWidget);
      expect(game.me.name, originalName);
      expect(game.me.contact, 'contact@example.test');
      expect(game.coins, 41);
      expect(game.packs, 2);
      expect(game.points, points);
      appLocaleSettings.value = AppLanguage.en;
      await tester.pumpAndSettle();
      expect(find.text('Edited 選名'), findsOneWidget);
      expect(
        tester.widget<TextField>(nickname).decoration!.labelText,
        isNot(matches(cjk)),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
