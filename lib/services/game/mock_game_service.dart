import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

import 'package:sitcon_backend/game/game_service.dart';

import 'demo_controls.dart';
import 'demo_game_storage.dart';

import 'package:sitcon_backend/game/game_engine.dart';

/// Uses exactly the server's rules engine with isolated, app-private persistence.
/// There is no transport, remote configuration, or online-to-offline fallback.
class MockGameService extends GameEngine implements DemoControls {
  MockGameService({required super.storage, super.clock, super.random})
    : super(importedNickname: '離線示範會眾', initialPhase: EventPhase.active);

  @override
  Future<void> addCoins(int amount) =>
      grantLocalResources(resource: 'coins', amount: amount);

  @override
  Future<void> addPacks(int amount) =>
      grantLocalResources(resource: 'packs', amount: amount);

  @override
  Future<void> setRole(AccountRole role, {String? boothId}) =>
      configureRole(role, boothId: boothId);

  /// [directory] is an optional app-support root for isolated test installations.
  static Future<MockGameService> open({
    Directory? directory,
    DateTime Function()? clock,
    Random? random,
  }) async {
    final root = directory ?? await getApplicationSupportDirectory();
    final service = MockGameService(
      storage: DemoGameStorage(File('${root.path}/offline_demo/state-v1.json')),
      clock: clock,
      random: random,
    );
    try {
      await service.initialize();
      return service;
    } catch (_) {
      service.dispose();
      rethrow;
    }
  }
}
