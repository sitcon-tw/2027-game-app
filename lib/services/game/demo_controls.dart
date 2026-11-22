import 'package:sitcon_backend/game/game_service.dart';

/// Explicit local-only capability; never implemented by network adapters.
abstract interface class DemoControls {
  Future<void> addCoins(int amount);
  Future<void> addPacks(int amount);
  Future<void> setMockPhase(EventPhase value);
  Future<void> setRole(AccountRole role, {String? boothId});
  Future<void> simulateAgenda(String slot);
  Future<void> simulateRemotePacks(
    String deliveryId,
    int amount,
    String reason,
  );
  Future<void> simulatePhotoReward();
  Future<void> simulateBoothCompletion(String boothId);
  Future<ScanResult> scanDemoStation(String stationId, String scanId, ScannerMode mode);
}

abstract interface class RemoteStationFixtures {
  Map<String, String>? get stationFixtureUids;
}
