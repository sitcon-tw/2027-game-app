import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitcon_backend/game/game_service.dart';
import 'package:sitcon_app/l10n/localization.dart';
import 'package:sitcon_backend/game/game_engine.dart';
import 'package:sitcon_app/viewmodels/game_view_model.dart';
import 'package:sitcon_app/views/collection_view.dart';

class _Storage implements GameStorage {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String value) async {
    this.value = value;
  }
}

void main() {
  testWidgets(
    'bulk pack overview scrolls through cards to the completion action',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(440, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final service = GameEngine(storage: _Storage());
      await service.initialize();
      await service.setMockPhase(EventPhase.active);
      await service.bindBadge(GameEngine.selfUid);
      await service.saveProfile(['AI', 'Vim派', '夜貓族'], '');
      await service.simulateRemotePacks('bulk', 5, 'bulk scroll regression');
      final vm = GameViewModel(service);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute(builder: (_) => PackView(vm: vm)),
                ),
                child: const Text('開補給'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('開補給'));
      await tester.pumpAndSettle();
      final all = find.byKey(const ValueKey('pack-open-all'));
      await tester.ensureVisible(all);
      await tester.tap(all);
      await tester.pumpAndSettle();
      expect(service.packs, 0);
      expect(service.hand.fold<int>(0, (sum, n) => sum + n), 27);
      final done = find.byKey(const ValueKey('pack-done'));
      await tester.scrollUntilVisible(
        done,
        300,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 20,
      );
      await tester.pumpAndSettle();
      expect(done.hitTestable(), findsOneWidget);
      await tester.tap(done);
      await tester.pumpAndSettle();
      expect(find.text('開補給').hitTestable(), findsOneWidget);
      expect(find.byType(PackView), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      vm.dispose();
      service.dispose();
    },
  );
}
