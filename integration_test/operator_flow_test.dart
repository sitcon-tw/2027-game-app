import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sitcon_app/main.dart';
import 'package:sitcon_app/services/game/http_game_service.dart';
import 'package:sitcon_app/services/preferences/app_locale_settings.dart';
import 'package:sitcon_app/views/social_view.dart';
import 'package:sitcon_backend/game/game_service.dart';

import 'flow_support.dart';
import 'test_server_support.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;
  testWidgets('Server roles drive staff and recipient-scoped booth scanning', (
    tester,
  ) async {
    final targetBadge = createTestBadgeUid();
    final stationBadge = createTestBadgeUid();
    final targetInstallation = testInstallation();
    final actor = await testInstallation().open(testApiBase);
    final target = await targetInstallation.open(testApiBase);
    final services = [actor, target];
    final previousLanguage = appLocaleSettings.value;
    appLocaleSettings.value = AppLanguage.en;

    Future<HttpGameService> targetSnapshot() async {
      final snapshot = await targetInstallation.open(testApiBase);
      services.add(snapshot);
      await snapshot.initialize();
      return snapshot;
    }

    Future<void> assign(AccountRole role, {String? boothId}) async {
      await adminAction('role', {
        'playerId': actor.playerId,
        'role': role.name,
        'boothId': ?boothId,
      });
      await actor.tick();
      await until(
        tester,
        () => actor.role == role && actor.boothId == boothId,
        reason: 'server scanner assignment reaches the open app',
      );
      await tester.pumpAndSettle();
    }

    Future<void> scan(String value) async {
      await tester.enterText(await findControl(tester, 'scan-uid'), value);
      await tapKey(tester, 'scan-submit');
    }

    Future<void> shot(String name) async {
      await binding.takeScreenshot(
        '${Platform.operatingSystem}-operators-$name',
      );
    }

    try {
      await actor.initialize();
      await target.initialize();
      await adminAction('phase', {'phase': 'active'});
      await target.bindBadge(targetBadge);
      await target.saveProfile(
        ['AI', 'Vim派', '夜貓族'],
        '',
        nickname: 'Scanner target',
      );
      await target.finishTutorial();
      await adminAction('role', {
        'playerId': actor.playerId,
        'role': 'staff',
      });
      await actor.tick();
      expect(actor.role, AccountRole.staff);
      expect(actor.checkedIn, false);
      await tester.pumpWidget(SitconApp(service: actor));
      await tester.pumpAndSettle();
      if (Platform.isAndroid) {
        await binding.convertFlutterSurfaceToImage();
        await tester.pump();
      }

      await tapKey(tester, 'scan-open');
      expect(
        tester
            .widget<SegmentedButton<ScannerMode>>(
              find.byType(SegmentedButton<ScannerMode>),
            )
            .selected,
        {ScannerMode.staff},
      );
      await scan(stationBadge);
      await waitFor(tester, find.byType(StationBindingView));
      await shot('staff-binding');
      await tapKey(tester, 'station-option-station-1');
      await tapKey(tester, 'station-bind');
      await dismissRewards(tester);
      await waitFor(tester, find.byType(ScanView));
      final packs = target.packs;
      await target.scan(
        stationBadge,
        'global-binding-${actor.playerId}',
      );
      expect(
        target.packs,
        packs + target.stations.first.packs,
        reason: 'staff binding is usable by another actual account',
      );
      expect(actor.packs, 0);

      await assign(AccountRole.booth, boothId: 'booth-1');
      await findControl(tester, 'scan-mode-booth');
      expect(
        tester
            .widget<SegmentedButton<ScannerMode>>(
              find.byType(SegmentedButton<ScannerMode>),
            )
            .selected,
        {ScannerMode.booth},
      );
      await scan(targetBadge);
      await waitFor(tester, keyed('operator-result'));
      expect(find.byType(PlayerView), findsNothing);
      expect(find.text('Scanner target'), findsWidgets);
      await shot('booth-receipt');
      final first = await targetSnapshot();
      expect(first.booths.first.completed, true);
      expect(first.hintRemainder, 1);
      expect(actor.booths.first.completed, false);
      expect(actor.hintCredits, 0);
      expect(actor.points, 0);
      await tapKey(tester, 'operator-result-dismiss');

      // A new scan-page session represents a deliberate new physical encounter.
      await back(tester);
      await tapKey(tester, 'scan-open');
      await scan(targetBadge);
      await waitFor(tester, keyed('operator-result'));
      final repeated = await targetSnapshot();
      expect(repeated.hintRemainder, first.hintRemainder);
      expect(repeated.hintCredits, first.hintCredits);
      await tapKey(tester, 'operator-result-dismiss');

      // Same role, different booth: the open scanner must reset its UID scope.
      await assign(AccountRole.booth, boothId: 'booth-2');
      await scan(targetBadge);
      await waitFor(tester, keyed('operator-result'));
      final secondBooth = await targetSnapshot();
      expect(
        secondBooth.booths.take(2).every((booth) => booth.completed),
        true,
      );
      expect(secondBooth.hintCredits, 1);
      expect(secondBooth.hintRemainder, 0);
      expect(actor.hintCredits, 0);
      await shot('booth-reassignment');
      await tapKey(tester, 'operator-result-dismiss');

      await assign(AccountRole.user);
      expect(keyed('scan-mode-staff'), findsNothing);
      expect(keyed('scan-mode-booth'), findsNothing);
      await expectLater(
        actor.scan(
          targetBadge,
          'revoked-${actor.playerId}',
          mode: ScannerMode.booth,
        ),
        throwsA(
          isA<GameApiException>().having(
            (error) => error.status,
            'status',
            403,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      for (final service in services) {
        service.dispose();
      }
      appLocaleSettings.value = previousLanguage;
    }
  }, timeout: const Timeout(Duration(minutes: 4)));
}
