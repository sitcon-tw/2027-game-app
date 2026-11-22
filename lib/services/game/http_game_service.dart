import 'dart:async';

import 'package:sitcon_backend/game/game_service.dart';
import 'package:sitcon_backend/game/game_wire.dart';
import 'package:sitcon_backend/game/observable_game_service.dart';

import 'game_api_client.dart';
import 'multiplayer.dart';

export 'game_api_client.dart' show GameApiException;

/// Native player adapter. All rules, rewards and mutations run on the server.
/// This deliberately has no admin methods and no offline/mock fallback.
class HttpGameService extends ObservableGameService implements Multiplayer {
  HttpGameService({
    required String baseUrl,
    required this.playerId,
    this._bearer,
  }) : _api = GameApiClient(baseUrl);

  final String playerId;
  final String? _bearer;
  final GameApiClient _api;
  void Function(GameApiException)? onSessionRevoked;
  GameApiException? _revoked;
  Future<void> _tail = Future<void>.value();
  Future<void>? _initializing;
  GameSnapshot? _snapshot;
  @override
  MultiplayerState? get multiplayer => _multiplayer;
  MultiplayerState? _multiplayer;
  Duration _clockOffset = Duration.zero;
  DateTime? _lastPoll;
  bool _polling = false, _disposed = false;
  int _issued = 0, _applied = -1, _sequence = -1;
  String? _instance;
  GameSnapshot get _s =>
      _snapshot ?? (throw GameStateError(const GameMessage('notConnected')));
  String get _path => '/api/players/${Uri.encodeComponent(playerId)}';

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final result = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        if (_disposed) {
          throw GameStateError(const GameMessage('serviceDisposed'));
        }
        result.complete(await operation());
      } catch (error, stack) {
        result.completeError(error, stack);
      }
    });
    return result.future;
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final ticket = _issued++;
    final sent = DateTime.now().toUtc();
    final data = await _requestApi(method, path, body);
    final received = DateTime.now().toUtc();
    try {
      final sequence = data['sequence'] as int;
      final instance = data['instance'] as String;
      if (!_disposed &&
          ticket > _applied &&
          (_instance != instance || sequence >= _sequence)) {
        final state = (data['state'] as Map).cast<String, dynamic>();
        final snapshot = GameSnapshot.fromJson(state);
        final live = state['multiplayer'] as Map?;
        final multiplayer = live == null
            ? null
            : MultiplayerState.fromJson(live.cast<String, dynamic>());
        final serverTime = DateTime.parse(data['serverTime'] as String).toUtc();
        final midpoint = sent.add(received.difference(sent) ~/ 2);
        _clockOffset = serverTime.difference(midpoint);
        _snapshot = snapshot;
        _multiplayer = multiplayer;
        _applied = ticket;
        _sequence = sequence;
        _instance = instance;
        notifyListeners();
      }
      return data;
    } on FormatException {
      throw GameStateError(const GameMessage('invalidResponse'));
    } on TypeError {
      throw GameStateError(const GameMessage('invalidResponse'));
    } on ArgumentError catch (error) {
      if (error is GameLocalizedError) rethrow;
      throw GameStateError(const GameMessage('invalidResponse'));
    }
  }

  Future<Map<String, dynamic>> _requestApi(
    String method, String path, Map<String, dynamic>? body,
  ) async {
    if (_revoked case final revoked?) throw revoked;
    try {
      return await _api.request(method, path, bearer: _bearer, body: body);
    } on GameApiException catch (error) {
      if (_bearer != null && error.status == 401) {
        _revoked = error;
        onSessionRevoked?.call(error);
      }
      rethrow;
    }
  }

  Future<String> issueTransferCode() => _enqueue(() async {
    if (_bearer == null) {
      throw GameStateError(const GameMessage('deviceSessionRequired'));
    }
    final data = await _requestApi('POST', '$_path/transfer-code', const {});
    return requireApiString(data, 'code');
  });

  bool get supportsDeviceTransfer => _bearer != null;

  Future<void> _fetchState() => _enqueue(() async {
    await _request('GET', '$_path/state');
  });
  @override
  Future<void> initialize() => _initializing ??= _initialize();
  Future<void> _initialize() async {
    try {
      await _fetchState();
    } catch (_) {
      _initializing = null;
      rethrow;
    }
  }

  Future<dynamic> _action(
    String action, [
    Map<String, dynamic> args = const {},
  ]) async {
    await initialize();
    return _enqueue(
      () async => (await _request('POST', '$_path/actions', {
        'action': action,
        'args': args,
      }))['result'],
    );
  }

  Future<void> _voidAction(
    String action, [
    Map<String, dynamic> args = const {},
  ]) async {
    await _action(action, args);
  }

  @override
  Future<void> tick() async {
    await initialize();
    final at = DateTime.now();
    if (_polling ||
        (_lastPoll != null &&
            at.difference(_lastPoll!) < const Duration(seconds: 2))) {
      return;
    }
    _lastPoll = at;
    _polling = true;
    try {
      await _fetchState();
    } finally {
      _polling = false;
    }
  }

  @override
  DateTime get now => DateTime.now().toUtc().add(_clockOffset);
  @override
  PlayerCard get me => _s.me;
  @override
  bool get checkedIn => _s.checkedIn;
  @override
  String? get badgeUid => _s.badgeUid;
  @override
  bool get earlyClaimed => _s.earlyClaimed;
  @override
  bool get tutorialSeen => _s.tutorialSeen;
  @override
  AccountRole get role => _s.role;
  @override
  String? get boothId => _s.boothId;
  @override
  EventPhase get phase => _s.phase;
  @override
  List<int> get hand => _s.hand;
  @override
  int get coins => _s.coins;
  @override
  int get points => _s.points;
  @override
  int get packs => _s.packs;
  @override
  int get peekCards => _s.peekCards;
  @override
  Set<int> get planets => _s.planets;
  @override
  Map<int, DateTime> get planetDates => _s.planetDates;
  @override
  List<Mission> get missions => _s.missions;
  @override
  List<Checkpoint> get checkpoints => _s.checkpoints;
  @override
  List<PlayerCard> get friends => _s.friends;
  @override
  Map<String, String> get friendMethods => _s.friendMethods;
  @override
  List<PlayerCard> get demoPlayers => _s.demoPlayers;
  @override
  List<Booth> get booths => _s.booths;
  @override
  List<Station> get stations => _s.stations;
  @override
  List<LedgerEntry> get ledger => _s.ledger;
  @override
  List<BattleRecord> get history => _s.history;
  @override
  Battle? get battle => _s.battle;
  @override
  DateTime? get cooldownUntil => _s.cooldownUntil;
  @override
  int get hintCredits => _s.hintCredits;
  @override
  int get hintRemainder => _s.hintRemainder;
  @override
  int get randomEggPrice => _s.randomEggPrice;
  @override
  int get seriesEggPrice => _s.seriesEggPrice;
  @override
  Map<String, int> get parameters => _s.parameters;
  @override
  GameMessage? battleBlocked(PlayerCard opponent) => _s.battleBlocked(opponent);
  @override
  List<RankEntry> ranking(String metric) => _s.ranking(metric);
  @override
  Future<void> bindBadge(String uid) => _voidAction('bindBadge', {'uid': uid});
  @override
  Future<void> saveProfile(
    List<String> tags,
    String contact, {
    String? nickname,
  }) => _voidAction('saveProfile', {
    'tags': tags,
    'contact': contact,
    'nickname': nickname,
  });
  @override
  Future<void> finishTutorial() => _voidAction('finishTutorial');
  @override
  Future<void> claimEarly() => _voidAction('claimEarly');
  @override
  Future<ScanResult> scan(
    String uid,
    String scanId, {
    ScannerMode mode = ScannerMode.user,
  }) async => scanFromWire(
    (await _action('scan', {
      'uid': uid,
      'scanId': scanId,
      'mode': mode.name,
    }) as Map).cast<String, dynamic>(),
  );
  @override
  Future<void> requestFriend(String playerId) =>
      _voidAction('requestFriend', {'playerId': playerId});
  @override
  Future<void> respondFriend(String playerId, bool accept) =>
      _voidAction('respondFriend', {'playerId': playerId, 'accept': accept});
  @override
  Future<void> simulateReciprocalScan(String playerId) =>
      _voidAction('simulateReciprocalScan', {'playerId': playerId});
  @override
  Future<void> inviteBattle(String playerId) =>
      _voidAction('inviteBattle', {'playerId': playerId});
  @override
  Future<void> respondBattle(String battleId, bool accept) =>
      _voidAction('respondBattle', {'battleId': battleId, 'accept': accept});
  @override
  Future<void> readyBattle(String battleId, int round) =>
      _voidAction('readyBattle', {'battleId': battleId, 'round': round});

  Map<String, dynamic> _liveBattleArgs({bool includeRound = false}) {
    final live = _multiplayer?.battle;
    if (live == null) return const {};
    final battle = _s.battle;
    if (battle == null || live.id != battle.id) return const {};
    return {
      'battleId': live.id,
      if (includeRound) 'round': battle.rounds.length,
    };
  }

  @override
  Future<void> cancelBattle() =>
      _voidAction('cancelBattle', _liveBattleArgs());
  @override
  Future<void> playCard(HandCard card, {HandCard? asCard}) =>
      _voidAction('playCard', {
        'card': card.index,
        'asCard': asCard?.index,
        ..._liveBattleArgs(includeRound: true),
      });
  @override
  Future<void> usePeek() =>
      _voidAction('usePeek', _liveBattleArgs(includeRound: true));
  @override
  Future<List<HandCard>> openPacks({bool all = false}) async =>
      List<HandCard>.unmodifiable(
        (await _action('openPacks', {'all': all}) as List).map(
          (v) => HandCard.values[v as int],
        ),
      );
  @override
  Future<HatchResult> buyEgg({int? series}) async => hatchFromWire(
    (await _action('buyEgg', {'series': series}) as Map)
        .cast<String, dynamic>(),
  );
  @override
  Future<void> selectAppearance(int? planet, int style) =>
      _voidAction('selectAppearance', {'planet': planet, 'style': style});
  @override
  Future<GameMessage> redeemHint() async => GameMessage.fromJson(
    (await _action('redeemHint') as Map).cast<String, dynamic>(),
  );
  @override
  Future<void> bindStation(String uid, String stationId) =>
      _voidAction('bindStation', {'uid': uid, 'stationId': stationId});
  @override
  void dispose() {
    _disposed = true;
    _api.close();
    super.dispose();
  }
}
