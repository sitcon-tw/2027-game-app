import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sitcon_backend/game/game_service.dart';
import 'package:sitcon_app/main.dart';

import 'flow_support.dart';
import 'test_server_support.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Present server-backed recap chooser without publishing', (
    tester,
  ) async {
    final badgeUid = createTestBadgeUid();
    final service = await testInstallation().open(testApiBase);
    await service.initialize();
    await adminAction('phase', {'phase': 'active'});
    await Future<void>.delayed(const Duration(seconds: 2));
    await service.tick();
    if (!service.checkedIn) {
      await service.bindBadge(badgeUid);
      await service.saveProfile(['AI', 'Vim派', '夜貓族'], '');
      await service.finishTutorial();
    }
    await adminAction('phase', {'phase': 'ended'});
    await tester.pumpWidget(SitconApp(service: service));
    await until(tester, () => service.phase == EventPhase.ended);
    await tester.pumpAndSettle();
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pump();
    }
    await tapKey(tester, 'recap-open-card');
    await tapKey(tester, 'recap-share');
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(seconds: 3));
    });
    await tester.pump();
    await binding.takeScreenshot('${Platform.operatingSystem}-share-sheet');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    service.dispose();
  });
}
