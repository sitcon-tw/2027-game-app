import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sitcon_backend/game/game_service.dart';
import 'package:sitcon_backend/game/game_engine.dart';
import 'package:sitcon_app/viewmodels/game_view_model.dart';

class _Memory implements GameStorage {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String value) async {
    this.value = value;
  }
}

class _First implements Random {
  @override
  int nextInt(int max) => 0;
  @override
  double nextDouble() => 0;
  @override
  bool nextBool() => false;
}

void main() {
  test(
    'visible invitation and cooldown countdowns use the service clock',
    () async {
      var now = DateTime.utc(2040, 1, 1);
      final service = GameEngine(
        storage: _Memory(),
        clock: () => now,
        random: _First(),
      );
      await service.initialize();
      await service.setMockPhase(EventPhase.active);
      await service.bindBadge(GameEngine.selfUid);
      await service.saveProfile(['AI', 'Vim派', '夜貓族'], '');
      final model = GameViewModel(service);
      try {
        final opponent = service.demoPlayers.first;
        await model.scan(opponent.id);
        await model.inviteBattle(opponent.id);
        expect(model.secondsUntil(model.battle!.deadline), 30);
        now = now.add(const Duration(seconds: 7));
        expect(model.secondsUntil(model.battle!.deadline), 23);
        await model.reciprocal(opponent.id);
        expect(model.secondsUntil(model.battle!.deadline), 10);
        now = now.add(const Duration(seconds: 31));
        await model.resume();
        expect(model.battle!.finished, isTrue);
        expect(model.cooldown, 59);
        now = now.add(const Duration(seconds: 60));
        expect(model.cooldown, 0);
      } finally {
        model.dispose();
        service.dispose();
      }
    },
  );
}
