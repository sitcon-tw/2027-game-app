import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:sitcon_backend/game/game_service.dart';
import 'package:sitcon_backend/game/observable_game_service.dart';

/// A single JSON document is the commit boundary for every mock transaction.
abstract interface class GameStorage {
  Future<String?> read();
  Future<void> write(String value);
}

class GameEngine extends ObservableGameService {
  GameEngine({
    required this.storage,
    DateTime Function()? clock,
    Random? random,
    this.importedNickname = 'OPass 模擬會眾',
    this.initialPhase = EventPhase.before,
  }) : _clock = clock ?? DateTime.now,
       _random = random ?? Random();

  static const defaultParameters = <String, int>{
    'randomEggPrice': 10,
    'seriesEggPrice': 40,
    'hintThreshold': 2,
    'missionCoins': 12,
    'agendaPacks': 1,
    'battleWinCoins': 30,
    'battleDrawCoins': 10,
    'battleCooldownSeconds': 60,
  };
  @override
  Map<String, int> get parameters => Map<String, int>.unmodifiable(
    (_s['parameters'] as Map? ?? defaultParameters).cast<String, int>(),
  );
  String exportState() => jsonEncode(_s);
  Future<void> configureParameters(Map<String, int> values) => _change(() {
    if (values.keys.any((key) => !defaultParameters.containsKey(key))) {
      throw GameArgumentError(const GameMessage('unknownParameter'));
    }
    for (final entry in values.entries) {
      final minimum =
          {
            'battleWinCoins',
            'battleDrawCoins',
            'missionCoins',
          }.contains(entry.key)
          ? 0
          : 1;
      final maximum = entry.key == 'agendaPacks' ? 3 : 3600;
      if (entry.value < minimum || entry.value > maximum) {
        throw GameArgumentError(
          GameMessage('parameterRange', {'parameter': entry.key}),
        );
      }
    }
    _s['parameters'] = {...parameters, ...values};
    _log('admin.parameters', '調整參數 ${jsonEncode(values)}');
  });
  Future<void> configureStation(Station station) => _change(() {
    if (!RegExp(r'^station-[a-zA-Z0-9-]{1,40}$').hasMatch(station.id) ||
        station.name.trim().isEmpty ||
        station.name.length > 120 ||
        station.packs < 1 ||
        station.packs > 100 ||
        station.limit < 1 ||
        station.limit > 100 ||
        station.remaining < 0 ||
        station.remaining > 100000) {
      throw GameArgumentError(const GameMessage('invalidStation'));
    }
    _map('stationConfigs')[station.id] = {
      'name': station.name.trim(),
      'packs': station.packs,
      'limit': station.limit,
      'open': station.open,
    };
    _map('stationStock')[station.id] = station.remaining;
    _log(
      'admin.station',
      '${station.id} ${station.name} 每次${station.packs}包 限${station.limit}次 剩${station.remaining} 開放${station.open}',
    );
  });
  static const selfUid = '04A1B2C3D4E5F6';
  static const unknownUid = '04F00000000001';
  static String playerUid(int index) => _fixtureUid('B', index, 18);
  static String checkpointUid(int number) => _fixtureUid('C', number, 42);
  static String boothUid(int number) => _fixtureUid('D', number, 3);
  static String stationUid(int number) => _fixtureUid('E', number, 4);
  static String _fixtureUid(String type, int number, int max) {
    if (number < 1 || number > max) throw RangeError.range(number, 1, max);
    return '04${type}000000000${number.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  static String normalizeUid(String value) {
    final uid = value.replaceAll(RegExp(r'[\s:\-]'), '').toUpperCase();
    if (!RegExp(r'^[0-9A-F]{14}$').hasMatch(uid)) {
      throw GameArgumentError(const GameMessage('invalidUid'));
    }
    return uid;
  }

  final String importedNickname;
  final EventPhase initialPhase;
  final GameStorage storage;
  final DateTime Function() _clock;
  @override
  DateTime get now => _clock();
  final Random _random;
  Map<String, dynamic> _s = {};
  Future<void>? _initializing;
  Future<void> _tail = Future<void>.value();
  // Face-to-face intent is deliberately transient, not a persistent inbox.
  final Map<String, DateTime> _friendRequests = {};
  final Set<String> _scannedPlayers = {};
  Map<String, String>? _globalBindings;
  Set<String> _bindingConflicts = const {};

  /// Server-owned overlay; independent saved fixture bindings are retained.
  void useGlobalBindings(
    Map<String, String> bindings, {
    Set<String> conflicts = const {},
  }) {
    _globalBindings = Map.unmodifiable(bindings);
    _bindingConflicts = Set.unmodifiable(conflicts);
  }

  Map<String, dynamic> _fresh() => {
    'version': 1,
    'name': importedNickname,
    'tags': <String>[],
    'contact': '',
    'badge': null,
    'checkedIn': false,
    'early': false,
    'earlyUnlocked': false,
    'tutorial': false,
    'role': AccountRole.user.name,
    'boothId': null,
    'recipients': <String, dynamic>{},
    'phase': initialPhase.index,
    'hand': [0, 0, 0, 0],
    'coins': 0,
    'points': 0,
    'packs': 0,
    'peek': 0,
    'planets': <String, dynamic>{},
    'seriesRewards': <int>[],
    'planet': null,
    'style': -1,
    'missions': <dynamic>[],
    'players': <dynamic>[],
    'friends': <String, dynamic>{},
    'checkpoints': <String, dynamic>{},
    'hints': <String, dynamic>{},
    'boothVisited': <String>[],
    'boothCompleted': <String>[],
    'stationClaims': <String, dynamic>{},
    'stationStock': {
      'station-1': 100,
      'station-2': 2,
      'station-3': 100,
      'station-4': 0,
    },
    'stationConfigs': <String, dynamic>{},
    'bindings': <String, dynamic>{},
    'ledger': <dynamic>[],
    'history': <dynamic>[],
    'battle': null,
    'cooldown': null,
    'hintCredits': 0,
    'hintRemainder': 0,
    'bag': <int>[],
    'scans': <String, dynamic>{},
    'agenda': <String>[],
    'deliveries': <String, dynamic>{},
    'photo': false,
    'sequence': 0,
    'opponentHands': <String, dynamic>{},
  };
  Map<String, dynamic> _map(String key) =>
      (_s[key] as Map).cast<String, dynamic>();
  List<dynamic> _list(String key) => _s[key] as List;
  int _n(String key) => _s[key] as int;
  bool _flag(String key) => _s[key] as bool;
  DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.parse(value as String);
  String _stamp([DateTime? at]) => (at ?? _clock()).toUtc().toIso8601String();

  @override
  Future<void> initialize() => _initializing ??= _load();
  Future<void> _load() async {
    final raw = await _readState();
    _s = raw == null ? _fresh() : _decodeState(raw);
    if (_s['version'] != 1) {
      throw GameStateError(const GameMessage('unsupportedSave'));
    }
    _s.putIfAbsent('stationConfigs', () => <String, dynamic>{});
    _s.putIfAbsent(
      'role',
      () =>
          _s['staff'] == true ? AccountRole.staff.name : AccountRole.user.name,
    );
    _s.remove('staff');
    _s.putIfAbsent('boothId', () => null);
    _s.putIfAbsent('recipients', () => <String, dynamic>{});
    if (!AccountRole.values.any((r) => r.name == _s['role']) ||
        (role == AccountRole.booth && !booths.any((b) => b.id == boothId)) ||
        (role != AccountRole.booth && boothId != null)) {
      throw GameStateError(const GameMessage('corruptSave'));
    }
    _advanceExpired();
    await _writeState(jsonEncode(_s));
    notifyListeners();
  }

  Map<String, dynamic> _decodeState(String raw) {
    try {
      return (jsonDecode(raw) as Map).cast<String, dynamic>();
    } on FormatException {
      throw GameStateError(const GameMessage('corruptSave'));
    } on TypeError {
      throw GameStateError(const GameMessage('corruptSave'));
    }
  }

  Future<String?> _readState() async {
    try {
      return await storage.read();
    } catch (error) {
      if (error is GameLocalizedError) rethrow;
      throw GameStateError(const GameMessage('storageFailure'));
    }
  }

  Future<void> _writeState(String value) async {
    try {
      await storage.write(value);
    } catch (error) {
      if (error is GameLocalizedError) rethrow;
      throw GameStateError(const GameMessage('storageFailure'));
    }
  }

  Future<T> _change<T>(T Function() action) async {
    await initialize();
    final result = Completer<T>();
    _tail = _tail.then((_) async {
      final before = jsonEncode(_s);
      final pending = Map<String, DateTime>.of(_friendRequests);
      final scanned = Set<String>.of(_scannedPlayers);
      try {
        final value = action();
        await _writeState(jsonEncode(_s));
        notifyListeners();
        result.complete(value);
      } catch (error, stack) {
        _s = (jsonDecode(before) as Map).cast<String, dynamic>();
        _friendRequests
          ..clear()
          ..addAll(pending);
        _scannedPlayers
          ..clear()
          ..addAll(scanned);
        result.completeError(error, stack);
      }
    });
    return result.future;
  }

  void _active() {
    if (phase != EventPhase.active) {
      throw GameStateError(
        GameMessage(phase == EventPhase.before ? 'eventBefore' : 'eventEnded'),
      );
    }
    if (!checkedIn) throw GameStateError(const GameMessage('checkInRequired'));
  }

  void _log(
    String reason,
    String detail, {
    int coins = 0,
    DateTime? at,
    Map<String, Object?> args = const {},
  }) {
    final balance = _n('coins') + coins;
    if (balance < 0) {
      throw GameStateError(const GameMessage('insufficientCoins'));
    }
    _s['coins'] = balance;
    _list('ledger').add({
      'at': _stamp(at),
      'reason': reason,
      'detail': '$detail；金幣餘額 $balance',
      'args': args,
      'coins': coins,
    });
  }

  @override
  PlayerCard get me => PlayerCard(
    id: 'mock-opass-self',
    name: _s['name'] as String,
    tags: List<String>.unmodifiable(_list('tags')),
    contact: _s['contact'] as String,
    planet: _s['planet'] as int?,
    style: _n('style'),
  );
  @override
  bool get checkedIn => _flag('checkedIn');
  @override
  String? get badgeUid => _s['badge'] as String?;
  @override
  bool get earlyClaimed => _flag('early');
  @override
  bool get tutorialSeen => _flag('tutorial');
  @override
  AccountRole get role => AccountRole.values.byName(_s['role'] as String);
  @override
  String? get boothId => _s['boothId'] as String?;
  @override
  EventPhase get phase => EventPhase.values[_n('phase')];
  @override
  List<int> get hand => List<int>.unmodifiable(_list('hand'));
  @override
  int get coins => _n('coins');
  @override
  int get points => _n('points');
  @override
  int get packs => _n('packs');
  @override
  int get peekCards => _n('peek');
  @override
  Set<int> get planets =>
      Set<int>.unmodifiable(_map('planets').keys.map(int.parse));
  @override
  Map<int, DateTime> get planetDates => Map<int, DateTime>.unmodifiable(
    _map('planets')
        .map((k, v) => MapEntry(int.parse(k), DateTime.parse(v as String))),
  );
  @override
  List<Mission> get missions => List<Mission>.unmodifiable(
    _list('missions').map((v) {
      final m = v as Map;
      final matches = friends
          .where((f) => f.tags.contains(m['tag']))
          .map((f) => f.id)
          .toList();
      return Mission(
        tag: m['tag'] as String,
        category: m['category'] as String,
        own: m['own'] as bool,
        friends: List.unmodifiable(matches),
        completedAt: _date(m['completedAt']),
      );
    }),
  );
  static const _areas = <String, int>{
    '議程廳': 8,
    '白板大戰': 2,
    '乾爹攤位': 5,
    'Demo 展攤位': 3,
    '攤位區': 4,
    '1F Welcoming Zone': 1,
    '用餐區': 4,
    '樓梯間': 4,
    '移動的活動組們': 4,
    '限定款': 3,
    '機動': 4,
  };
  @override
  List<Checkpoint> get checkpoints {
    var number = 0;
    return List.unmodifiable([
      for (final area in _areas.entries)
        for (var i = 0; i < area.value; i++)
          Checkpoint(
            number: ++number,
            area: area.key,
            collectedAt: _date(_map('checkpoints')['$number']),
            hint: _map('hints').containsKey('$number')
                ? GameMessage('checkpointHint', {
                    'number': number,
                    'area': area.key,
                  })
                : null,
          ),
    ]);
  }

  PlayerCard _player(Map v) => PlayerCard(
    id: v['id'] as String,
    name: v['name'] as String,
    tags: List<String>.unmodifiable(v['tags'] as List),
    contact: v['contact'] as String? ?? '',
    planet: v['planet'] as int?,
    style: v['style'] as int? ?? -1,
  );
  Map<String, dynamic> _playerJson(PlayerCard p) => {
    'id': p.id,
    'name': p.name,
    'tags': p.tags,
    'contact': p.contact,
    'planet': p.planet,
    'style': p.style,
  };
  static final _operatorAttendees = List<PlayerCard>.unmodifiable([
    for (var i = 1; i <= 18; i++)
      PlayerCard(
        id: playerUid(i),
        name: '模擬會眾 ${i.toString().padLeft(2, '0')}',
        tags: const [],
        contact: '本機測試人物，非真實會眾',
      ),
  ]);
  @override
  List<PlayerCard> get demoPlayers {
    final players = _list('players');
    if (players.isEmpty && role != AccountRole.user) return _operatorAttendees;
    return List.unmodifiable(players.map((v) => _player(v as Map)));
  }

  PlayerCard _findPlayer(String id) => demoPlayers.firstWhere(
    (p) => p.id == id,
    orElse: () => throw GameArgumentError(const GameMessage('playerNotFound')),
  );
  @override
  List<PlayerCard> get friends => List.unmodifiable(
    demoPlayers.where((p) => _map('friends').containsKey(p.id)),
  );
  @override
  Map<String, String> get friendMethods =>
      Map<String, String>.unmodifiable(_map('friends'));
  @override
  List<Booth> get booths => List.unmodifiable([
    for (var i = 1; i <= 3; i++)
      Booth(
        id: 'booth-$i',
        name: ['SITCON 社群交流（模擬）', '開源 Demo（模擬）', '活動組任務（模擬）'][i - 1],
        url: 'https://sitcon.org/',
        visited: _list('boothVisited').contains('booth-$i'),
        completed: _list('boothCompleted').contains('booth-$i'),
      ),
  ]);
  @override
  List<Station> get stations => List.unmodifiable([
    for (final entry in _map('stationStock').entries)
      Station(
        id: entry.key,
        name:
            (_map('stationConfigs')[entry.key] as Map?)?['name'] as String? ??
            [
              '服務台（模擬）',
              '限量走動站（模擬）',
              '未開放站（模擬）',
              '已發完站（模擬）',
            ][int.parse(entry.key.split('-').last) - 1],
        packs:
            (_map('stationConfigs')[entry.key] as Map?)?['packs'] as int? ??
            (entry.key == 'station-2' ? 2 : 1),
        limit:
            (_map('stationConfigs')[entry.key] as Map?)?['limit'] as int? ??
            (entry.key == 'station-2' ? 2 : 1),
        remaining: entry.value as int,
        open:
            (_map('stationConfigs')[entry.key] as Map?)?['open'] as bool? ??
            (entry.key != 'station-3'),
      ),
  ]);
  @override
  List<LedgerEntry> get ledger => List.unmodifiable(
    _list('ledger').reversed.map((v) {
      final m = v as Map;
      return LedgerEntry(
        DateTime.parse(m['at'] as String),
        m['reason'] as String,
        m['detail'] as String,
        coins: m['coins'] as int,
        args: Map<String, Object?>.unmodifiable(
          (m['args'] as Map? ?? const {}).cast<String, Object?>(),
        ),
      );
    }),
  );
  Map<String, dynamic> _battleJson(Battle b) => {
    'id': b.id,
    'opponent': _playerJson(b.opponent),
    'deadline': _stamp(b.deadline),
    'accepted': b.accepted,
    'finished': b.finished,
    'peekUsed': b.peekUsed,
    'opponentHand': b.opponentHand,
    'rounds': [
      for (final r in b.rounds)
        {
          'mine': r.mine.index,
          'opponent': r.opponent.index,
          'outcome': r.outcome,
          'automatic': r.automatic,
          'wild': r.wild,
        },
    ],
  };
  Battle _battleFrom(Map m) => Battle(
    id: m['id'] as String,
    opponent: _player(m['opponent'] as Map),
    deadline: DateTime.parse(m['deadline'] as String),
    accepted: m['accepted'] as bool,
    finished: m['finished'] as bool,
    peekUsed: m['peekUsed'] as bool,
    opponentHand: List<int>.unmodifiable(m['opponentHand'] as List),
    rounds: List<RoundResult>.unmodifiable(
      (m['rounds'] as List).map(
        (v) => RoundResult(
          HandCard.values[v['mine'] as int],
          HandCard.values[v['opponent'] as int],
          v['outcome'] as int,
          automatic: v['automatic'] as bool,
          wild: v['wild'] as bool,
        ),
      ),
    ),
  );
  @override
  List<BattleRecord> get history => List.unmodifiable(
    _list('history').reversed.map(
      (v) => BattleRecord(
        _battleFrom(v['battle'] as Map),
        DateTime.parse(v['at'] as String),
        v['points'] as int,
        v['coins'] as int,
        v['reward'] == null ? null : HandCard.values[v['reward'] as int],
      ),
    ),
  );
  @override
  Battle? get battle =>
      _s['battle'] == null ? null : _battleFrom(_s['battle'] as Map);
  @override
  DateTime? get cooldownUntil => _date(_s['cooldown']);
  @override
  int get hintCredits => _n('hintCredits');
  @override
  int get hintRemainder => _n('hintRemainder');
  @override
  int get randomEggPrice => parameters['randomEggPrice']!;
  @override
  int get seriesEggPrice => parameters['seriesEggPrice']!;

  void _validateTags(List<String> tags) {
    final all = hashtagOptions.values.expand((v) => v).toSet();
    if (tags.toSet().length != tags.length ||
        tags.any((t) => !all.contains(t))) {
      throw GameArgumentError(const GameMessage('invalidTags'));
    }
    for (final category in hashtagOptions.entries) {
      final count = tags.where(category.value.contains).length;
      if (count < 1 || count > 3) {
        throw GameArgumentError(
          GameMessage('categoryTagCount', {'category': category.key}),
        );
      }
    }
    for (final pair in opposingTags) {
      if (pair.every(tags.contains)) {
        throw GameArgumentError(
          GameMessage('opposingTags', {'first': pair[0], 'second': pair[1]}),
        );
      }
    }
  }

  @override
  Future<void> bindBadge(String uid) => _change(() {
    if (phase != EventPhase.active) {
      throw GameStateError(const GameMessage('badgePhase'));
    }
    final normalized = normalizeUid(uid);
    if (List.generate(18, (i) => playerUid(i + 1)).contains(normalized)) {
      throw GameStateError(const GameMessage('badgeTaken'));
    }
    final reserved = <String>{
      for (var i = 1; i <= 42; i++) checkpointUid(i),
      for (var i = 1; i <= 3; i++) boothUid(i),
      for (var i = 1; i <= 4; i++) stationUid(i),
      ..._map('bindings').keys,
    };
    if (reserved.contains(normalized)) {
      throw GameStateError(const GameMessage('notBadge'));
    }
    if (_s['badge'] != null && _s['badge'] != normalized) {
      throw GameStateError(const GameMessage('badgeLocked'));
    }
    if (_s['badge'] == normalized) return;
    _s['badge'] = normalized;
    _log('badge.bind', '綁定自己的名牌 $normalized（本機模擬 OPass）');
    _checkInIfReady();
  });
  @override
  Future<void> saveProfile(
    List<String> tags,
    String contact, {
    String? nickname,
  }) => _change(() {
    final savedTags = _list('tags');
    if (savedTags.isEmpty) {
      _validateTags(tags);
      _s['tags'] = List<String>.of(tags);
    } else if (tags.length != savedTags.length ||
        !tags.toSet().containsAll(savedTags)) {
      throw GameStateError(const GameMessage('profileTagsLocked'));
    }
    if (nickname != null) {
      if (nickname.trim().isEmpty) {
        throw GameArgumentError(const GameMessage('nicknameRequired'));
      }
      _s['name'] = nickname.trim();
    }
    if (contact.length > 1000) {
      throw GameArgumentError(const GameMessage('contactTooLong'));
    }
    _s['contact'] = contact.trim();
    _log(
      'profile.edit',
      '更新公開 Hashtag ${tags.join('、')}；聯絡資訊${contact.trim().isEmpty ? '留空' : '已更新'}',
    );
    _checkInIfReady();
    _recomputeMissions();
  });
  void _checkInIfReady() {
    if (phase != EventPhase.active ||
        checkedIn ||
        _s['badge'] == null ||
        _list('tags').isEmpty) {
      return;
    }
    _validateTags(List<String>.from(_list('tags')));
    _s['checkedIn'] = true;
    _s['hand'] = [4, 4, 4, 0];
    for (final entry in hashtagOptions.entries) {
      final own = entry.value.where(_list('tags').contains).toList();
      final notOwn = entry.value
          .where((t) => !_list('tags').contains(t))
          .toList();
      _list('missions').addAll([
        {
          'tag': own[_random.nextInt(own.length)],
          'category': entry.key,
          'own': true,
          'completedAt': null,
        },
        {
          'tag': notOwn[_random.nextInt(notOwn.length)],
          'category': entry.key,
          'own': false,
          'completedAt': null,
        },
      ]);
    }
    _generatePlayers();
    _log('checkin', '完成報到；起始牌 剪刀4／石頭4／布4；固定產生6個 Hashtag 任務');
    if (earlyClaimed && !_flag('earlyUnlocked')) {
      _s['earlyUnlocked'] = true;
      _s['packs'] = packs + 1;
      final hatch = _hatch(null);
      _log('early.unlock', '早鳥解鎖：1包＋星球${hatch.planet}（不扣金幣）');
    }
  }

  void _generatePlayers() {
    // Three clearly-labelled fixture people for each generated mission. This
    // guarantees all six missions can be exercised, without all-tag opponents.
    var index = 0;
    for (final mission in _list('missions')) {
      for (var copy = 0; copy < 3; copy++) {
        final tags = <String>[];
        for (final entry in hashtagOptions.entries) {
          tags.add(
            entry.key == mission['category']
                ? mission['tag'] as String
                : entry.value[(index + copy) % entry.value.length],
          );
        }
        final p = PlayerCard(
          id: playerUid(++index),
          name: '模擬會眾 ${index.toString().padLeft(2, '0')}',
          tags: tags,
          contact: '本機測試人物，非真實會眾',
        );
        _list('players').add(_playerJson(p));
        _map('opponentHands')[p.id] = [4, 4, 4, 0];
      }
    }
  }

  @override
  Future<void> finishTutorial() => _change(() {
    _s['tutorial'] = true;
  });
  @override
  Future<void> claimEarly() => _change(() {
    if (earlyClaimed) return;
    if (phase != EventPhase.before) {
      throw GameStateError(const GameMessage('earlyPhase'));
    }
    _s['early'] = true;
    _log('early.claim', '已登記早鳥：1顆隨機蛋＋1包，報到前鎖定');
  });

  Map<String, dynamic> _scanJson(
    ScanResult r,
    String source,
    ScannerMode mode,
  ) => {
    'source': source,
    'mode': mode.name,
    'assignedBooth': mode == ScannerMode.booth ? boothId : null,
    'kind': r.kind,
    'message': r.message.toJson(),
    'uid': r.uid,
    'player': r.player == null ? null : _playerJson(r.player!),
    'booth': r.booth == null
        ? null
        : {
            'id': r.booth!.id,
            'name': r.booth!.name,
            'url': r.booth!.url,
            'visited': r.booth!.visited,
            'completed': r.booth!.completed,
          },
    'openPacks': r.openPacks,
    'targetPlayerId': r.targetPlayerId,
    'repeated': r.repeated,
    'station': r.station == null
        ? null
        : {
            'id': r.station!.id,
            'name': r.station!.name,
            'packs': r.station!.packs,
            'limit': r.station!.limit,
            'remaining': r.station!.remaining,
            'open': r.station!.open,
          },
  };
  ScanResult _scanFrom(Map m) {
    final b = m['booth'] as Map?;
    final station = m['station'] as Map?;
    return ScanResult(
      m['kind'] as String,
      m['message'] is Map
          ? GameMessage.fromJson((m['message'] as Map).cast<String, dynamic>())
          : GameMessage('scan.${m['kind']}'),
      uid: m['uid'] as String?,
      player: m['player'] == null ? null : _player(m['player'] as Map),
      openPacks: m['openPacks'] as bool,
      targetPlayerId: m['targetPlayerId'] as String?,
      repeated: m['repeated'] as bool? ?? false,
      station: station == null
          ? null
          : Station(
              id: station['id'] as String,
              name: station['name'] as String,
              packs: station['packs'] as int,
              limit: station['limit'] as int,
              remaining: station['remaining'] as int,
              open: station['open'] as bool,
            ),
      booth: b == null
          ? null
          : Booth(
              id: b['id'] as String,
              name: b['name'] as String,
              url: b['url'] as String,
              visited: b['visited'] as bool,
              completed: b['completed'] as bool,
            ),
    );
  }

  /// Permission is checked before looking up a receipt, including after revocation.
  void requireScannerMode(ScannerMode mode) {
    if ((mode == ScannerMode.staff && role != AccountRole.staff) ||
        (mode == ScannerMode.booth && role != AccountRole.booth)) {
      throw GameStateError(const GameMessage('operatorPermission'));
    }
    if (mode != ScannerMode.user && phase != EventPhase.active) {
      throw GameStateError(
        GameMessage(phase == EventPhase.before ? 'eventBefore' : 'eventEnded'),
      );
    }
    if (mode == ScannerMode.booth && !booths.any((b) => b.id == boothId)) {
      throw GameStateError(const GameMessage('boothAssignmentRequired'));
    }
  }

  /// Trusted server orchestration only; never a player action.
  ScanResult? replayScan(String uid, String scanId, ScannerMode mode) {
    requireScannerMode(mode);
    final normalized = normalizeUid(uid);
    if (scanId.trim().isEmpty || scanId.length > 160) {
      throw GameArgumentError(const GameMessage('scanIdRequired'));
    }
    final previous = _map('scans')[scanId] as Map?;
    if (previous == null) return null;
    if (previous['source'] != normalized ||
        (previous['mode'] ?? ScannerMode.user.name) != mode.name ||
        (mode == ScannerMode.booth && previous['assignedBooth'] != boothId)) {
      throw GameStateError(const GameMessage('scanIdConflict'));
    }
    return _scanFrom(previous);
  }

  /// Saves an authoritative cross-account result in the actor's receipt journal.
  Future<ScanResult> recordOperatorScan(
    String uid,
    String scanId,
    ScannerMode mode,
    ScanResult result,
  ) => _change(() {
    if (mode == ScannerMode.user) {
      throw GameArgumentError(const GameMessage('operatorPermission'));
    }
    final prior = replayScan(uid, scanId, mode);
    if (prior != null) return prior;
    final normalized = normalizeUid(uid);
    _map('scans')[scanId] = _scanJson(result, normalized, mode);
    _log(
      'scan.operator',
      'scanId=$scanId UID=$normalized ${mode.name}',
      args: {'mode': mode.name, 'targetPlayerId': result.targetPlayerId},
    );
    return result;
  });

  @override
  Future<ScanResult> scan(
    String uid,
    String scanId, {
    ScannerMode mode = ScannerMode.user,
  }) => _change(() {
    final normalized = normalizeUid(uid);
    final previous = replayScan(normalized, scanId, mode);
    if (previous != null) {
      if (previous.player != null && previous.kind == 'player') {
        _scannedPlayers.add(previous.player!.id);
      }
      return previous;
    }
    final result = mode == ScannerMode.user
        ? _scanNew(normalized, scanId)
        : _scanOperator(normalized, mode);
    if (mode != ScannerMode.user) {
      _log(
        'scan.operator',
        'scanId=$scanId UID=$normalized ${mode.name}',
        args: {'mode': mode.name, 'targetPlayerId': result.targetPlayerId},
      );
    }
    _map('scans')[scanId] = _scanJson(result, normalized, mode);
    return result;
  });

  String? _stationForUid(String uid) {
    if (_bindingConflicts.contains(uid)) {
      throw GameStateError(const GameMessage('ambiguousTag'));
    }
    for (var i = 1; i <= 4; i++) {
      if (uid == stationUid(i)) return 'station-$i';
    }
    return (_globalBindings ?? _map('bindings'))[uid] as String?;
  }

  ScanResult _scanOperator(String uid, ScannerMode mode) {
    if (uid == _s['badge'] || (uid == selfUid && _s['badge'] == null)) {
      throw GameStateError(const GameMessage('operatorSelfScan'));
    }
    PlayerCard? recipient;
    for (var i = 1; i <= 18; i++) {
      if (uid != playerUid(i)) continue;
      recipient =
          demoPlayers.where((p) => p.id == uid).firstOrNull ??
          _operatorAttendees[i - 1];
      break;
    }
    if (recipient != null) {
      if (mode == ScannerMode.staff) {
        return ScanResult(
          'staffPlayer',
          const GameMessage('staffIdentity'),
          uid: uid,
          player: recipient,
          targetPlayerId: recipient.id,
        );
      }
      final progress = (_map('recipients').putIfAbsent(
        recipient.id,
        () => {
          'boothVisited': <String>[],
          'boothCompleted': <String>[],
          'hintCredits': 0,
          'hintRemainder': 0,
        },
      ) as Map).cast<String, dynamic>();
      final repeated = _completeBoothProgress(progress, boothId!);
      final booth = booths.firstWhere((b) => b.id == boothId);
      return ScanResult(
        'boothComplete',
        GameMessage(repeated ? 'boothAlreadyComplete' : 'boothTaskComplete'),
        uid: uid,
        player: recipient,
        targetPlayerId: recipient.id,
        booth: Booth(
          id: booth.id,
          name: booth.name,
          url: booth.url,
          visited: true,
          completed: true,
        ),
        repeated: repeated,
      );
    }
    if (mode == ScannerMode.booth) {
      throw GameStateError(const GameMessage('attendeeBadgeRequired'));
    }
    final stationId = _stationForUid(uid);
    if (stationId != null) {
      return ScanResult(
        'staffStation',
        const GameMessage('staffStationInfo'),
        uid: uid,
        station: stations.firstWhere((s) => s.id == stationId),
      );
    }
    final known = [
      for (var i = 1; i <= 42; i++) checkpointUid(i),
      for (var i = 1; i <= 3; i++) boothUid(i),
    ].contains(uid);
    return ScanResult(
      known ? 'operatorTag' : 'bindStation',
      GameMessage(known ? 'operatorTagInfo' : 'scan.bindStation'),
      uid: uid,
    );
  }

  bool _completeBoothProgress(Map<String, dynamic> progress, String id) {
    final completed = progress['boothCompleted'] as List;
    if (completed.contains(id)) return true;
    completed.add(id);
    final visited = progress['boothVisited'] as List;
    if (!visited.contains(id)) visited.add(id);
    final total = (progress['hintRemainder'] as int) + 1;
    final threshold = parameters['hintThreshold']!;
    progress['hintCredits'] =
        (progress['hintCredits'] as int) + total ~/ threshold;
    progress['hintRemainder'] = total % threshold;
    return false;
  }

  /// Recipient-side operation used inside the API's multi-account transaction.
  Future<bool> completeBoothTask(String id) => _change(() {
    _active();
    if (!booths.any((b) => b.id == id)) {
      throw GameArgumentError(const GameMessage('boothNotFound'));
    }
    final repeated = _completeBoothProgress(_s, id);
    if (!repeated) {
      _log(
        'booth.complete',
        'Recipient booth task completed',
        args: {'boothId': id},
      );
    }
    return repeated;
  });
  ScanResult _scanNew(String uid, String scanId) {
    if (uid == _s['badge'] || (uid == selfUid && _s['badge'] == null)) {
      _log('scan.self', 'scanId=$scanId UID=$uid');
      return ScanResult(
        'self',
        GameMessage(checkedIn ? 'scan.self' : 'checkInRequired'),
        uid: uid,
        player: me,
      );
    }
    for (final p in demoPlayers) {
      if (p.id == uid) {
        _scannedPlayers.add(p.id);
        _log('scan.player', 'scanId=$scanId UID=$uid ${p.name}');
        return ScanResult(
          'player',
          const GameMessage('scan.player'),
          uid: uid,
          player: p,
        );
      }
    }
    for (var i = 1; i <= 42; i++) {
      if (uid != checkpointUid(i)) continue;
      _active();
      if (_map('checkpoints').containsKey('$i')) {
        _log(
          'scan.checkpoint.repeat',
          'scanId=$scanId UID=$uid 打卡小石$i再次掃描，無獎勵',
        );
        return ScanResult(
          'checkpoint',
          GameMessage('checkpointRepeat', {'number': i}),
          uid: uid,
        );
      }
      _map('checkpoints')['$i'] = _stamp();
      final card = _draw();
      _addCard(card);
      _log(
        'scan.checkpoint',
        'scanId=$scanId UID=$uid 打卡小石$i＋${cardNames[card.index]}1張',
        args: {'number': i, 'card': card.index},
      );
      return ScanResult(
        'checkpoint',
        GameMessage('checkpointFound', {'number': i, 'card': card.index}),
        uid: uid,
      );
    }
    for (var i = 1; i <= booths.length; i++) {
      if (uid != boothUid(i)) continue;
      _active();
      final b = booths[i - 1];
      if (!_list('boothVisited').contains(b.id)) {
        _list('boothVisited').add(b.id);
      }
      _log('scan.booth', 'scanId=$scanId UID=$uid ${b.id}，只顯示介紹；任務由攤商回掃控制確認');
      return ScanResult(
        'booth',
        const GameMessage('scan.booth'),
        uid: uid,
        booth: booths[i - 1],
      );
    }
    final stationId = _stationForUid(uid);
    if (stationId != null) {
      _active();
      final station = stations.firstWhere((s) => s.id == stationId);
      final claimed = _map('stationClaims')[stationId] as int? ?? 0;
      GameMessage message;
      var awarded = false;
      if (!station.open) {
        message = const GameMessage('stationClosed');
      } else if (claimed >= station.limit) {
        message = const GameMessage('stationLimit');
      } else if (station.remaining < station.packs) {
        message = const GameMessage('stationEmpty');
      } else {
        _map('stationClaims')[stationId] = claimed + 1;
        _map('stationStock')[stationId] = station.remaining - station.packs;
        _s['packs'] = packs + station.packs;
        awarded = true;
        message = GameMessage('stationPacks', {'count': station.packs});
      }
      _log(
        'scan.station',
        'scanId=$scanId UID=$uid $stationId：${message.code}；未開卡包$packs',
        args: {
          'station': stationId,
          'awarded': awarded,
          'amount': awarded ? station.packs : 0,
        },
      );
      return ScanResult('station', message, uid: uid, openPacks: awarded);
    }
    _log('scan.unknown', 'scanId=$scanId UID=$uid 無法辨識');
    return ScanResult('unknown', const GameMessage('scan.unknown'), uid: uid);
  }

  @override
  Future<void> requestFriend(String playerId) => _change(() {
    _active();
    _findPlayer(playerId);
    if (!_scannedPlayers.contains(playerId)) {
      throw GameStateError(const GameMessage('scanFirst'));
    }
    if (_map('friends').containsKey(playerId)) return;
    _friendRequests[playerId] = _clock().add(const Duration(seconds: 30));
    _log('friend.request', '$playerId：等待30秒內模擬對方回掃；不發獎勵');
  });
  @override
  Future<void> simulateReciprocalScan(String playerId) => _change(() {
    _active();
    _advanceExpired();
    final p = _findPlayer(playerId);
    final current = battle;
    if (current != null &&
        !current.finished &&
        !current.accepted &&
        current.opponent.id == playerId) {
      final handOther = List<int>.from(_map('opponentHands')[playerId] as List);
      if (_total(handOther) < 3) {
        throw GameStateError(const GameMessage('opponentCardsLow'));
      }
      _s['battle'] = _battleJson(
        Battle(
          id: current.id,
          opponent: p,
          deadline: _clock().add(const Duration(seconds: 10)),
          accepted: true,
          opponentHand: handOther,
        ),
      );
      _log('battle.accept', '${current.id} $playerId 模擬對手已回掃；第一回合10秒');
      return;
    }
    final deadline = _friendRequests[playerId];
    if (deadline == null || !_clock().isBefore(deadline)) {
      throw GameStateError(const GameMessage('friendRequestExpired'));
    }
    _friendRequests.remove(playerId);
    _addFriend(playerId, '互掃名牌');
  });
  void _addFriend(String id, String method, {DateTime? at}) {
    if (_map('friends').containsKey(id)) return;
    _map('friends')[id] = method;
    _log('friend.add', '$id 好友成立，方式：$method；好友本身不發金幣', at: at);
    _recomputeMissions(at: at);
  }

  void _recomputeMissions({DateTime? at}) {
    final formal = friends;
    for (final m in _list('missions')) {
      if (m['completedAt'] != null) continue;
      if (formal.where((p) => p.tags.contains(m['tag'])).length < 3) continue;
      m['completedAt'] = _stamp(at);
      _log(
        'mission.complete',
        'Hashtag #${m['tag']} 3位正式好友；任務＋${parameters['missionCoins']}金幣',
        coins: parameters['missionCoins']!,
        at: at,
        args: {'tag': m['tag']},
      );
    }
  }

  int _total(List<int> cards) => cards.fold(0, (sum, n) => sum + n);
  @override
  GameMessage? battleBlocked(PlayerCard opponent) {
    if (phase != EventPhase.active) {
      return GameMessage(
        phase == EventPhase.before ? 'eventBefore' : 'eventEnded',
      );
    }
    if (!checkedIn) return const GameMessage('checkInRequired');
    if (!demoPlayers.any((p) => p.id == opponent.id)) {
      return const GameMessage('playerNotFound');
    }
    if (battle != null && !battle!.finished) {
      return const GameMessage('battleBusy');
    }
    if (cooldownUntil != null && _clock().isBefore(cooldownUntil!)) {
      return const GameMessage('battleCooldown');
    }
    if (_total(hand) < 3) return const GameMessage('cardsLow');
    if (_total(List<int>.from(_map('opponentHands')[opponent.id] as List)) <
        3) {
      return const GameMessage('opponentCardsLow');
    }
    return null;
  }

  @override
  Future<void> inviteBattle(String playerId) => _change(() {
    _advanceExpired();
    final p = _findPlayer(playerId);
    final blocked = battleBlocked(p);
    if (blocked != null) throw GameStateError(blocked);
    if (!_scannedPlayers.contains(playerId)) {
      throw GameStateError(const GameMessage('scanFirst'));
    }
    _s['sequence'] = _n('sequence') + 1;
    final id = 'mock-battle-${_n('sequence')}';
    _s['battle'] = _battleJson(
      Battle(
        id: id,
        opponent: p,
        deadline: _clock().add(const Duration(seconds: 30)),
        opponentHand: List<int>.from(_map('opponentHands')[p.id] as List),
      ),
    );
    _log('battle.invite', '$id $playerId：等待30秒內模擬對方回掃');
  });
  @override
  Future<void> cancelBattle() => _change(() {
    final b = battle;
    if (b == null || b.finished) {
      _s['battle'] = null;
      return;
    }
    if (b.accepted) {
      throw GameStateError(const GameMessage('battleCannotCancel'));
    }
    _s['battle'] = null;
    _log('battle.cancel', '${b.id} 取消邀請，未消耗卡牌');
  });
  @override
  Future<void> playCard(HandCard card, {HandCard? asCard}) => _change(() {
    _active();
    final before = battle;
    if (before == null || !before.accepted || before.finished) {
      throw GameStateError(const GameMessage('noBattle'));
    }
    if (!_clock().isBefore(before.deadline)) {
      _advanceExpired();
      return; // A late tap cannot play into the following round.
    }
    if ((_list('hand')[card.index] as int) < 1) {
      throw GameStateError(const GameMessage('cardUnavailable'));
    }
    if (card == HandCard.wild && (asCard == null || asCard == HandCard.wild)) {
      throw GameArgumentError(const GameMessage('wildChoiceRequired'));
    }
    if (card != HandCard.wild && asCard != null) {
      throw GameArgumentError(const GameMessage('normalCardFixed'));
    }
    _resolveRound(
      card,
      card == HandCard.wild ? asCard! : card,
      false,
      _clock(),
    );
  });
  HandCard _randomCard(List<int> cards) {
    final normalCount = cards[0] + cards[1] + cards[2];
    if (normalCount == 0) {
      if (cards[3] == 0) {
        throw GameStateError(const GameMessage('battleCardsEmpty'));
      }
      return HandCard.wild;
    }
    var choice = _random.nextInt(normalCount);
    for (var i = 0; i < 3; i++) {
      if (choice < cards[i]) return HandCard.values[i];
      choice -= cards[i];
    }
    throw GameStateError(const GameMessage('invalidCardCount'));
  }

  int _outcome(HandCard mine, HandCard other) {
    if (mine == other) return 0;
    return (mine.index - other.index + 3) % 3 == 1 ? 1 : -1;
  }

  void _resolveRound(
    HandCard consumed,
    HandCard effective,
    bool automatic,
    DateTime at,
  ) {
    final b = battle!;
    final mine = List<int>.from(hand);
    mine[consumed.index]--;
    final other = List<int>.from(b.opponentHand);
    final otherConsumed = _randomCard(other);
    other[otherConsumed.index]--;
    final otherEffective = otherConsumed == HandCard.wild
        ? HandCard.values[_random.nextInt(3)]
        : otherConsumed;
    final rounds = [
      ...b.rounds,
      RoundResult(
        effective,
        otherEffective,
        _outcome(effective, otherEffective),
        automatic: automatic,
        wild: consumed == HandCard.wild,
      ),
    ];
    _s['hand'] = mine;
    _map('opponentHands')[b.opponent.id] = other;
    final wins = rounds.where((r) => r.outcome > 0).length;
    final losses = rounds.where((r) => r.outcome < 0).length;
    final finished = rounds.length >= 3 || wins >= 2 || losses >= 2;
    final next = Battle(
      id: b.id,
      opponent: b.opponent,
      deadline: at.add(const Duration(seconds: 10)),
      accepted: true,
      rounds: List.unmodifiable(rounds),
      finished: finished,
      peekUsed: b.peekUsed,
      opponentHand: other,
    );
    _s['battle'] = _battleJson(next);
    _log(
      'battle.round',
      '${b.id} 回合${rounds.length}：${automatic ? '逾時代出' : '手動'} '
          '${cardNames[consumed.index]}${consumed == HandCard.wild ? '→${cardNames[effective.index]}' : ''}；'
          '模擬對手${cardNames[otherConsumed.index]}；結果${rounds.last.outcome}；雙方各消耗1張；剩餘手牌$mine／$other',
      at: at,
    );
    if (finished) _settle(next, at);
  }

  void _settle(Battle b, DateTime at) {
    final earnedPoints = b.result > 0
        ? 3
        : b.result == 0
        ? 1
        : 0;
    final earnedCoins = b.result > 0
        ? parameters['battleWinCoins']!
        : b.result == 0
        ? parameters['battleDrawCoins']!
        : 0;
    final reward = b.result >= 0 ? _draw() : null;
    if (reward != null) _addCard(reward);
    _s['points'] = points + earnedPoints;
    _s['cooldown'] = _stamp(
      at.add(Duration(seconds: parameters['battleCooldownSeconds']!)),
    );
    _list('history').add({
      'battle': _battleJson(b),
      'at': _stamp(at),
      'points': earnedPoints,
      'coins': earnedCoins,
      'reward': reward?.index,
    });
    _log(
      'battle.settle',
      '${b.id} 對手${b.opponent.id} 結果${b.result}；積分＋$earnedPoints；'
          '${reward == null ? '無抽牌' : '抽牌＋${cardNames[reward.index]}1張'}；冷卻至${_s['cooldown']}',
      coins: earnedCoins,
      at: at,
      args: {'points': earnedPoints, 'result': b.result, 'card': reward?.index},
    );
    _addFriend(b.opponent.id, '對戰自動成為好友', at: at);
    _advanceHint(at: at);
  }

  @override
  Future<void> usePeek() => _change(() {
    _active();
    final b = battle;
    if (b == null || b.finished || !b.accepted) {
      throw GameStateError(const GameMessage('peekTiming'));
    }
    if (!_clock().isBefore(b.deadline)) {
      _advanceExpired();
      return;
    }
    if (b.peekUsed) throw GameStateError(const GameMessage('peekUsed'));
    if (peekCards < 1) throw GameStateError(const GameMessage('peekEmpty'));
    _s['peek'] = peekCards - 1;
    final json = _battleJson(b)..['peekUsed'] = true;
    _s['battle'] = json;
    _log(
      'battle.peek',
      '${b.id} 消耗透視卡1張；模擬對手收到使用通知；目前手牌${b.opponentHand}；倒數不暫停',
    );
  });
  void _advanceExpired() {
    _friendRequests.removeWhere((_, deadline) => !_clock().isBefore(deadline));
    while (true) {
      final b = battle;
      if (b == null || b.finished || _clock().isBefore(b.deadline)) return;
      if (!b.accepted) {
        _s['battle'] = null;
        _log('battle.invite.expired', '${b.id} 30秒未回掃，取消且不消耗', at: b.deadline);
        return;
      }
      final selected = _randomCard(hand);
      final effective = selected == HandCard.wild
          ? HandCard.values[_random.nextInt(3)]
          : selected;
      _resolveRound(selected, effective, true, b.deadline);
    }
  }

  @override
  Future<void> tick() async {
    await initialize();
    final current = battle;
    if (current != null &&
        !current.finished &&
        !_clock().isBefore(current.deadline)) {
      await _change(_advanceExpired);
    } else {
      _friendRequests.removeWhere(
        (_, deadline) => !_clock().isBefore(deadline),
      );
    }
  }

  void _addCard(HandCard card) {
    final inventory = _list('hand');
    inventory[card.index] = (inventory[card.index] as int) + 1;
  }

  HandCard _draw() {
    if (_list('bag').isEmpty) {
      final bag = [
        for (var i = 0; i < 3; i++)
          for (var n = 0; n < 4; n++) i,
      ]..shuffle(_random);
      _s['bag'] = bag;
    }
    return HandCard.values[_list('bag').removeLast() as int];
  }

  @override
  Future<List<HandCard>> openPacks({bool all = false}) => _change(() {
    _active();
    if (packs < 1) throw GameStateError(const GameMessage('packsEmpty'));
    final count = all ? packs : 1;
    final cards = <HandCard>[];
    for (var i = 0; i < count * 3; i++) {
      final card = _draw();
      cards.add(card);
      _addCard(card);
    }
    _s['packs'] = packs - count;
    _log(
      'pack.open',
      '開啟$count包；抽出${cards.map((c) => cardNames[c.index]).join('、')}；剩餘卡包$packs；手牌$hand',
      args: {'count': count},
    );
    return List<HandCard>.unmodifiable(cards);
  });
  @override
  Future<HatchResult> buyEgg({int? series}) => _change(() {
    _active();
    if (series != null && (series < 0 || series >= 6)) {
      throw GameArgumentError(const GameMessage('invalidSeries'));
    }
    final price = series == null ? randomEggPrice : seriesEggPrice;
    if (coins < price) {
      throw GameStateError(
        GameMessage('coinsShort', {'amount': price - coins}),
      );
    }
    final hatch = _hatch(series);
    _log(
      'egg.buy',
      '${series == null ? '隨機蛋' : '${seriesNames[series]}星球蛋'} 解鎖星球${hatch.planet}；花費$price',
      coins: -price,
      args: {'planet': hatch.planet},
    );
    return hatch;
  });
  HatchResult _hatch(int? series) {
    final owned = _map('planets');
    final available = [
      for (var i = 0; i < 42; i++)
        if (!owned.containsKey('$i') && (series == null || i ~/ 7 == series)) i,
    ];
    if (available.isEmpty) {
      throw GameStateError(
        GameMessage(series == null ? 'allPlanetsOwned' : 'seriesOwned'),
      );
    }
    final planet = available[_random.nextInt(available.length)];
    _map('planets')['$planet'] = _stamp();
    final group = planet ~/ 7;
    final completed =
        planets.where((p) => p ~/ 7 == group).length == 7 &&
        !_list('seriesRewards').contains(group);
    if (completed) {
      _list('seriesRewards').add(group);
      _addCard(HandCard.wild);
      _s['peek'] = peekCards + 1;
      _s['packs'] = packs + 1;
      _log(
        'series.complete',
        '${seriesNames[group]}7色集滿；萬用卡＋1、透視卡＋1、卡包＋1、名片樣式$group解鎖',
        args: {'series': group},
      );
    }
    return HatchResult(planet, completed);
  }

  @override
  Future<void> selectAppearance(int? planet, int style) => _change(() {
    if (planet != null && !_map('planets').containsKey('$planet')) {
      throw GameStateError(const GameMessage('planetLocked'));
    }
    if (style < -1 ||
        style >= 6 ||
        (style >= 0 && !_list('seriesRewards').contains(style))) {
      throw GameStateError(const GameMessage('styleLocked'));
    }
    _s['planet'] = planet;
    _s['style'] = style;
    _log('appearance.edit', '代表星球${planet ?? '基本卡面'}；名片樣式$style');
  });
  void _advanceHint({DateTime? at}) {
    final total = hintRemainder + 1;
    final threshold = parameters['hintThreshold']!;
    _s['hintCredits'] = hintCredits + total ~/ threshold;
    _s['hintRemainder'] = total % threshold;
    if (total >= threshold) {
      _log('hint.earn', '累積$threshold次對戰／攤位任務，提示＋1；剩餘$hintCredits', at: at);
    }
  }

  @override
  Future<GameMessage> redeemHint() => _change(() {
    _active();
    if (hintCredits < 1) {
      throw GameStateError(
        GameMessage('hintsEmpty', {'count': parameters['hintThreshold']!}),
      );
    }
    final available = checkpoints
        .where((p) => p.collectedAt == null && p.hint == null)
        .toList();
    if (available.isEmpty) {
      throw GameStateError(const GameMessage('hintsExhausted'));
    }
    final selected = available[_random.nextInt(available.length)];
    final hint = GameMessage('checkpointHint', {
      'number': selected.number,
      'area': selected.area,
    });
    _map('hints')['${selected.number}'] = hint.toJson();
    _s['hintCredits'] = hintCredits - 1;
    _log('hint.redeem', '${hint.code} ${hint.args}；提示－1', args: hint.args);
    return hint;
  });
  @override
  List<RankEntry> ranking(String metric) {
    int mine;
    switch (metric) {
      case 'points':
        mine = points;
      case 'friends':
        mine = friends.length;
      case 'planets':
        mine = planets.length;
      case 'checkpoints':
        mine = _map('checkpoints').length;
      case 'missions':
        mine = missions.where((m) => m.completedAt != null).length;
      default:
        throw GameArgumentError(
          GameMessage('unknownRanking', {'metric': metric}),
        );
    }
    final entries = <RankEntry>[RankEntry(me, mine)];
    for (var i = 0; i < demoPlayers.length; i++) {
      // Synthetic scoreboard values, never represented as remote live data.
      final value = switch (metric) {
        'points' => (i * 7 + 3) % 46,
        'friends' => (i * 3) % 19,
        'planets' => (i * 5) % 43,
        'checkpoints' => (i * 4) % 43,
        _ => i % 7,
      };
      entries.add(RankEntry(demoPlayers[i], value));
    }
    entries.sort((a, b) {
      final c = b.value.compareTo(a.value);
      return c != 0 ? c : a.player.id.compareTo(b.player.id);
    });
    return List.unmodifiable(entries);
  }

  @override
  Future<void> bindStation(String uid, String stationId) => _change(() {
    if (role != AccountRole.staff) {
      throw GameStateError(const GameMessage('staffRequired'));
    }
    final normalized = normalizeUid(uid);
    stations.firstWhere(
      (s) => s.id == stationId,
      orElse: () =>
          throw GameArgumentError(const GameMessage('stationNotFound')),
    );
    final reserved = <String>{
      selfUid,
      if (_s['badge'] != null) _s['badge'] as String,
      for (var i = 1; i <= 18; i++) playerUid(i),
      for (var i = 1; i <= 42; i++) checkpointUid(i),
      for (var i = 1; i <= 3; i++) boothUid(i),
      for (var i = 1; i <= 4; i++) stationUid(i),
    };
    if (reserved.contains(normalized) ||
        _bindingConflicts.contains(normalized) ||
        (_globalBindings ?? _map('bindings')).containsKey(normalized)) {
      throw GameStateError(const GameMessage('uidReserved'));
    }
    _map('bindings')[normalized] = stationId;
    _log('station.bind', '模擬工作人員把$normalized綁定$stationId');
  });

  /// Shared atomic inventory transaction for the local capability only.
  /// Deliberately absent from GameService and every remote action allowlist.
  Future<void> grantLocalResources({
    required String resource,
    required int amount,
  }) => _change(() {
    if (amount <= 0 || (resource != 'coins' && resource != 'packs')) {
      throw GameArgumentError(const GameMessage('invalidGrant'));
    }
    final current = resource == 'coins' ? coins : packs;
    if (amount > 0x7fffffffffffffff - current) {
      throw GameArgumentError(const GameMessage('grantTooLarge'));
    }
    if (resource == 'packs') _s['packs'] = packs + amount;
    _log(
      'cheat.$resource',
      'Local grant: $amount $resource',
      coins: resource == 'coins' ? amount : 0,
      args: {'amount': amount},
    );
  });

  Future<void> setMockPhase(EventPhase value) => _change(() {
    _advanceExpired();
    _s['phase'] = value.index;
    _log('mock.phase', '本機模擬年會階段：${value.name}');
  });
  Future<void> configureRole(AccountRole role, {String? boothId}) =>
      _change(() {
        if (role == AccountRole.booth && !booths.any((b) => b.id == boothId)) {
          throw GameArgumentError(const GameMessage('boothAssignmentRequired'));
        }
        _s['role'] = role.name;
        _s['boothId'] = role == AccountRole.booth ? boothId : null;
        _log(
          'admin.role',
          'Account role assigned',
          args: {'role': role.name, 'boothId': _s['boothId']},
        );
      });
  Future<void> simulateAgenda(String slot) => _change(() {
    _active();
    if (slot.trim().isEmpty) {
      throw GameArgumentError(const GameMessage('agendaRequired'));
    }
    if (_list('agenda').contains(slot)) return;
    _list('agenda').add(slot);
    _s['packs'] = packs + parameters['agendaPacks']!;
    _log(
      'mock.agenda',
      '模擬議程時段$slot統一發包＋${parameters['agendaPacks']}；未開卡包$packs',
      args: {'amount': parameters['agendaPacks']!},
    );
  });
  Future<void> simulateBoothCompletion(String boothId) => _change(() {
    _active();
    booths.firstWhere(
      (b) => b.id == boothId,
      orElse: () => throw GameArgumentError(const GameMessage('boothNotFound')),
    );
    if (_list('boothCompleted').contains(boothId)) return;
    _list('boothCompleted').add(boothId);
    if (!_list('boothVisited').contains(boothId)) {
      _list('boothVisited').add(boothId);
    }
    _log('mock.booth.complete', '$boothId 模擬攤商回掃確認完成；不發金幣／卡包，計入提示');
    _advanceHint();
  });
  Future<void> simulateRemotePacks(
    String deliveryId,
    int amount,
    String reason,
  ) => _change(() {
    _active();
    if (deliveryId.trim().isEmpty || reason.trim().isEmpty || amount < 1) {
      throw GameArgumentError(const GameMessage('invalidDelivery'));
    }
    final existing = _map('deliveries')[deliveryId] as Map?;
    if (existing != null) {
      if (existing['amount'] != amount || existing['reason'] != reason) {
        throw GameStateError(const GameMessage('deliveryConflict'));
      }
      return;
    }
    _map('deliveries')[deliveryId] = {'amount': amount, 'reason': reason};
    _s['packs'] = packs + amount;
    _log(
      'mock.remote',
      'deliveryId=$deliveryId；模擬遠端發包＋$amount；原因$reason；未開卡包$packs',
      args: {'amount': amount, 'reason': reason},
    );
  });
  Future<void> simulatePhotoReward() => _change(() {
    _active();
    if (_flag('photo')) return;
    _s['photo'] = true;
    _s['packs'] = packs + 1;
    _log('mock.photo', '模擬 Avatar chef 合照獎勵＋1包（每人一次）；未開卡包$packs');
  });
}
