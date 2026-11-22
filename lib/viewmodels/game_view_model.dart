import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:sitcon_backend/game/game_service.dart';

import '../services/game/demo_controls.dart';
import '../services/game/multiplayer.dart';

class GameViewModel extends ChangeNotifier {
  GameViewModel(GameService service) : _service = service {
    _ledgerCount = service.ledger.length;
    _scannerRole = service.role;
    _scannerBoothId = service.boothId;
    _scannerMode = _defaultScannerMode(service.role);
    _service.addListener(_changed);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => resume());
  }
  final GameService _service;
  bool get isOfflineDemo => _service is DemoControls;
  bool get testToolsEnabled =>
      isOfflineDemo || const bool.fromEnvironment('TEST_GAMEPLAY');
  DemoControls? get demoControls =>
      _service is DemoControls ? _service as DemoControls : null;
  Multiplayer? get _multiplayerService =>
      _service is Multiplayer ? _service as Multiplayer : null;
  MultiplayerState? get _multiplayer => _multiplayerService?.multiplayer;
  bool canInteractWithRemotePlayer(String id) =>
      id.startsWith('p-') && _multiplayer != null;
  List<PlayerCard> get incomingFriends =>
      _multiplayer?.incomingFriends ?? const [];
  bool friendRequestSent(String id) =>
      _multiplayer?.outgoingFriends.contains(id) ?? false;
  MultiplayerBattle? get liveBattle {
    final live = _multiplayer?.battle;
    return live != null && live.id == battle?.id ? live : null;
  }
  String? _seenLiveBattleResult;
  Battle? get unreadLiveBattleResult {
    if (_multiplayer == null) return null;
    for (final record in history) {
      final result = record.battle;
      if (result.opponent.id.startsWith('p-')) {
        return result.id == _seenLiveBattleResult ? null : result;
      }
    }
    return null;
  }

  void markLiveBattleResultSeen(String id) {
    if (unreadLiveBattleResult?.id != id) return;
    _seenLiveBattleResult = id;
    notifyListeners();
  }

  late final Timer _timer;
  bool busy = false;
  bool _ticking = false;
  bool _disposed = false;
  Object? error;
  int _ledgerCount = 0;
  int _scanSequence = 0;
  late AccountRole _scannerRole;
  String? _scannerBoothId;
  late ScannerMode _scannerMode;
  int _scannerRevision = 0;
  static ScannerMode _defaultScannerMode(AccountRole role) => switch (role) {
    AccountRole.user => ScannerMode.user,
    AccountRole.staff => ScannerMode.staff,
    AccountRole.booth => ScannerMode.booth,
  };
  AccountRole get role => _service.role;
  String? get boothId => _service.boothId;
  ScannerMode get scannerMode => _scannerMode;
  int get scannerRevision => _scannerRevision;
  List<ScannerMode> get scannerModes => [
    ScannerMode.user,
    if (role == AccountRole.staff) ScannerMode.staff,
    if (role == AccountRole.booth) ScannerMode.booth,
  ];
  bool get canOpenScanner => checkedIn || role != AccountRole.user;
  bool get canScan =>
      scannerModes.contains(scannerMode) &&
      (scannerMode != ScannerMode.user || checkedIn) &&
      (scannerMode != ScannerMode.booth || boothId != null);
  bool setScannerMode(ScannerMode mode) {
    if (busy || !scannerModes.contains(mode)) return false;
    if (_scannerMode == mode) return true;
    _scannerMode = mode;
    _scannerRevision++;
    notifyListeners();
    return true;
  }

  final List<LedgerEntry> rewards = [];
  void _changed() {
    if (_scannerRole != role || _scannerBoothId != boothId) {
      _scannerRole = role;
      _scannerBoothId = boothId;
      _scannerMode = _defaultScannerMode(role);
      _scannerRevision++;
    }
    final entries = _service.ledger;
    if (entries.length > _ledgerCount) {
      rewards.addAll(
        entries.take(entries.length - _ledgerCount).toList().reversed,
      );
    }
    _ledgerCount = entries.length;
    if (!_disposed) notifyListeners();
  }

  Future<void> resume() async {
    if (_ticking || _disposed || busy) return;
    _ticking = true;
    try {
      await _service.tick();
    } catch (e) {
      error = e;
    } finally {
      _ticking = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<T?> run<T>(Future<T> Function() action) async {
    if (busy) return null;
    busy = true;
    error = null;
    notifyListeners();
    try {
      return await action();
    } catch (e) {
      error = e;
      return null;
    } finally {
      busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  void reportError(Object e) {
    error = e;
    notifyListeners();
  }

  PlayerCard get me => _service.me;
  bool get checkedIn => _service.checkedIn;
  String? get badgeUid => _service.badgeUid;
  bool get earlyClaimed => _service.earlyClaimed;
  bool get tutorialSeen => _service.tutorialSeen;
  EventPhase get phase => _service.phase;
  List<int> get hand => _service.hand;
  int get handTotal => hand.fold(0, (a, b) => a + b);
  int get coins => _service.coins;
  int get points => _service.points;
  int get packs => _service.packs;
  int get peekCards => _service.peekCards;
  Set<int> get planets => _service.planets;
  Map<int, DateTime> get planetDates => _service.planetDates;
  List<Mission> get missions => _service.missions;
  List<Checkpoint> get checkpoints => _service.checkpoints;
  List<PlayerCard> get friends => _service.friends;
  Map<String, String> get friendMethods => _service.friendMethods;
  List<PlayerCard> get demoPlayers => _service.demoPlayers;
  List<Booth> get booths => _service.booths;
  List<Station> get stations => _service.stations;
  List<LedgerEntry> get ledger => _service.ledger;
  List<BattleRecord> get history => _service.history;
  Battle? get battle => _service.battle;
  int get hintCredits => _service.hintCredits;
  int get hintRemainder => _service.hintRemainder;
  int get randomEggPrice => _service.randomEggPrice;
  int get seriesEggPrice => _service.seriesEggPrice;
  Map<String, int> get parameters => _service.parameters;
  int get cooldown => secondsUntil(_service.cooldownUntil);
  DateTime get now => _service.now;
  int secondsUntil(DateTime? at) => at == null
      ? 0
      : ((at.difference(now).inMilliseconds / 1000).ceil()).clamp(0, 99999);
  int seriesCount(int series) => planets.where((p) => p ~/ 7 == series).length;
  int get completeSeries =>
      List.generate(6, seriesCount).where((n) => n == 7).length;
  int get collected => checkpoints.where((p) => p.collectedAt != null).length;
  int get completedMissions =>
      missions.where((m) => m.completedAt != null).length;
  int get wins => history.where((r) => r.battle.result > 0).length;
  GameMessage? battleBlocked(PlayerCard p) {
    if (!canInteractWithRemotePlayer(p.id)) return _service.battleBlocked(p);
    // The legacy eligibility table only knows demo opponents. The server
    // checks the remote opponent's eligibility when an invitation is sent.
    if (phase != EventPhase.active) {
      return GameMessage(
        phase == EventPhase.before ? 'eventBefore' : 'eventEnded',
      );
    }
    if (!checkedIn) return const GameMessage('checkInRequired');
    if (battle case Battle(finished: false)) {
      return const GameMessage('battleBusy');
    }
    if (cooldown > 0) return const GameMessage('battleCooldown');
    if (handTotal < 3) return const GameMessage('cardsLow');
    return null;
  }
  List<RankEntry> ranking(String metric) => _service.ranking(metric);
  Future<void> bind(String uid) async {
    await run(() => _service.bindBadge(uid));
  }

  Future<bool> saveProfile(
    List<String> tags,
    String contact,
    String nickname,
  ) async {
    final result = await run(() async {
      await _service.saveProfile(tags, contact, nickname: nickname);
      return true;
    });
    return result ?? false;
  }

  Future<void> finishTutorial() async {
    await run(_service.finishTutorial);
  }

  Future<void> claimEarly() async {
    await run(_service.claimEarly);
  }

  final Set<String> _scannedPlayers = {};
  bool hasScanned(String playerId) => canInteractWithRemotePlayer(playerId)
      ? _multiplayer!.scanned.contains(playerId)
      : _scannedPlayers.contains(playerId);
  Future<ScanResult?> scan(String uid) async {
    if (!canScan) return null;
    final mode = scannerMode;
    final revision = scannerRevision;
    final result = await run(() async {
      final result = await _service.scan(
        uid,
        'scan-${DateTime.now().microsecondsSinceEpoch}-${_scanSequence++}',
        mode: mode,
      );
      if (revision != scannerRevision || _disposed) return null;
      if (mode == ScannerMode.user &&
          result.kind == 'player' &&
          result.player != null) {
        _scannedPlayers.add(result.player!.id);
      }
      return result;
    });
    return revision == scannerRevision && !_disposed ? result : null;
  }

  Future<void> requestFriend(String id) async {
    await run(() => _service.requestFriend(id));
  }

  Future<void> respondFriend(String id, bool accept) async {
    final service = _multiplayerService;
    if (service == null || !incomingFriends.any((p) => p.id == id)) return;
    await run(() => service.respondFriend(id, accept));
  }

  Future<void> reciprocal(String id) async {
    if (canInteractWithRemotePlayer(id)) return;
    await run(() => _service.simulateReciprocalScan(id));
  }

  Future<void> inviteBattle(String id) async {
    await run(() => _service.inviteBattle(id));
  }

  Future<void> respondBattle(String id, bool accept) async {
    final service = _multiplayerService;
    final live = liveBattle;
    if (service == null ||
        live == null ||
        live.id != id ||
        !live.incoming ||
        battle?.accepted != false) {
      return;
    }
    await run(() => service.respondBattle(id, accept));
  }

  Future<void> readyBattle(Battle shown) async {
    final service = _multiplayerService;
    final live = liveBattle;
    if (service == null ||
        live == null ||
        !live.waitingReady ||
        live.ready ||
        !_isCurrentRound(shown)) {
      return;
    }
    await run(() => service.readyBattle(shown.id, shown.rounds.length));
  }

  Future<void> cancelBattle(Battle shown) async {
    if (!_isCurrentRound(shown) ||
        (shown.accepted &&
            !(liveBattle?.waitingReady == true && shown.rounds.isEmpty))) {
      return;
    }
    await run(_service.cancelBattle);
  }

  bool _isCurrentRound(Battle shown) {
    final current = battle;
    return current != null &&
        !current.finished &&
        current.id == shown.id &&
        current.rounds.length == shown.rounds.length;
  }

  bool _canPlayRound(Battle shown) =>
      _isCurrentRound(shown) && battle!.accepted &&
      liveBattle?.waitingReady != true && liveBattle?.played != true;

  Future<void> play(Battle shown, HandCard card, HandCard? asCard) async {
    if (!_canPlayRound(shown)) return;
    await run(() => _service.playCard(card, asCard: asCard));
  }

  Future<void> peek(Battle shown) async {
    if (!_canPlayRound(shown)) return;
    await run(_service.usePeek);
  }

  Future<List<HandCard>?> openPacks({bool all = false}) =>
      run(() => _service.openPacks(all: all));
  Future<HatchResult?> buyEgg({int? series}) =>
      run(() => _service.buyEgg(series: series));
  Future<void> appearance(int? planet, int style) async {
    await run(() => _service.selectAppearance(planet, style));
  }

  Future<GameMessage?> hint() => run(_service.redeemHint);
  Future<bool> bindStation(String uid, String station) async {
    if (role != AccountRole.staff || scannerMode != ScannerMode.staff) {
      return false;
    }
    final revision = scannerRevision;
    final saved = await run(() async {
      await _service.bindStation(uid, station);
      return true;
    });
    return saved == true && scannerRevision == revision;
  }

  @override
  void dispose() {
    _disposed = true;
    _timer.cancel();
    _service.removeListener(_changed);
    super.dispose();
  }
}
