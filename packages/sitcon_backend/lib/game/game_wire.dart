import 'package:sitcon_backend/game/game_service.dart';

/// Public, read-only protocol. Private core persistence is never sent to players.
const gameWireVersion = 3;
const rankingMetrics = [
  'points',
  'friends',
  'planets',
  'checkpoints',
  'missions',
];

Map<String, dynamic> playerToWire(PlayerCard p) => {
  'id': p.id,
  'name': p.name,
  'tags': p.tags,
  'contact': p.contact,
  'planet': p.planet,
  'style': p.style,
  'roles': p.roles,
};
PlayerCard playerFromWire(Map<String, dynamic> p) => PlayerCard(
  id: p['id'] as String,
  name: p['name'] as String,
  tags: List<String>.unmodifiable(p['tags'] as List),
  contact: p['contact'] as String,
  planet: p['planet'] as int?,
  style: p['style'] as int,
  roles: List<String>.unmodifiable(p['roles'] as List),
);
Map<String, dynamic> boothToWire(Booth b) => {
  'id': b.id,
  'name': b.name,
  'url': b.url,
  'visited': b.visited,
  'completed': b.completed,
};
Booth boothFromWire(Map<String, dynamic> b) => Booth(
  id: b['id'] as String,
  name: b['name'] as String,
  url: b['url'] as String,
  visited: b['visited'] as bool,
  completed: b['completed'] as bool,
);
Map<String, dynamic> stationToWire(Station s) => {
  'id': s.id,
  'name': s.name,
  'packs': s.packs,
  'limit': s.limit,
  'remaining': s.remaining,
  'open': s.open,
};
Station stationFromWire(Map<String, dynamic> s) => Station(
  id: s['id'] as String,
  name: s['name'] as String,
  packs: s['packs'] as int,
  limit: s['limit'] as int,
  remaining: s['remaining'] as int,
  open: s['open'] as bool,
);
Map<String, dynamic> battleToWire(Battle b) => {
  'id': b.id,
  'opponent': playerToWire(b.opponent),
  'deadline': b.deadline.toUtc().toIso8601String(),
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
Battle battleFromWire(Map<String, dynamic> b) => Battle(
  id: b['id'] as String,
  opponent: playerFromWire(_map(b['opponent'])),
  deadline: DateTime.parse(b['deadline'] as String),
  accepted: b['accepted'] as bool,
  finished: b['finished'] as bool,
  peekUsed: b['peekUsed'] as bool,
  opponentHand: List<int>.unmodifiable(b['opponentHand'] as List),
  rounds: List<RoundResult>.unmodifiable(
    (b['rounds'] as List).map((v) {
      final r = _map(v);
      return RoundResult(
        HandCard.values[r['mine'] as int],
        HandCard.values[r['opponent'] as int],
        r['outcome'] as int,
        automatic: r['automatic'] as bool,
        wild: r['wild'] as bool,
      );
    }),
  ),
);
Map<String, dynamic> scanToWire(ScanResult r) => {
  'kind': r.kind,
  'message': r.message.toJson(),
  'uid': r.uid,
  'player': r.player == null ? null : playerToWire(r.player!),
  'booth': r.booth == null ? null : boothToWire(r.booth!),
  'station': r.station == null ? null : stationToWire(r.station!),
  'targetPlayerId': r.targetPlayerId,
  'repeated': r.repeated,
  'openPacks': r.openPacks,
};
ScanResult scanFromWire(Map<String, dynamic> r) => ScanResult(
  r['kind'] as String,
  GameMessage.fromJson(_map(r['message'])),
  uid: r['uid'] as String?,
  player: r['player'] == null ? null : playerFromWire(_map(r['player'])),
  booth: r['booth'] == null ? null : boothFromWire(_map(r['booth'])),
  station: r['station'] == null ? null : stationFromWire(_map(r['station'])),
  targetPlayerId: r['targetPlayerId'] as String?,
  repeated: r['repeated'] as bool,
  openPacks: r['openPacks'] as bool,
);
Map<String, dynamic> hatchToWire(HatchResult r) => {
  'planet': r.planet,
  'seriesCompleted': r.seriesCompleted,
};
HatchResult hatchFromWire(Map<String, dynamic> r) =>
    HatchResult(r['planet'] as int, r['seriesCompleted'] as bool);

Map<String, dynamic> gameToWire(GameService g) => {
  'version': gameWireVersion,
  'me': playerToWire(g.me),
  'badgeUid': g.badgeUid,
  'checkedIn': g.checkedIn, 'earlyClaimed': g.earlyClaimed,
  'tutorialSeen': g.tutorialSeen, 'role': g.role.name,
  'boothId': g.boothId, 'phase': g.phase.name,
  'hand': g.hand, 'coins': g.coins, 'points': g.points, 'packs': g.packs,
  'peekCards': g.peekCards, 'planets': g.planets.toList(),
  'planetDates': g.planetDates.map(
    (k, v) => MapEntry('$k', v.toUtc().toIso8601String()),
  ),
  'missions': [
    for (final m in g.missions)
      {
        'tag': m.tag,
        'category': m.category,
        'own': m.own,
        'friends': m.friends,
        'completedAt': m.completedAt?.toUtc().toIso8601String(),
      },
  ],
  'checkpoints': [
    for (final c in g.checkpoints)
      {
        'number': c.number,
        'area': c.area,
        'collectedAt': c.collectedAt?.toUtc().toIso8601String(),
        'hint': c.hint?.toJson(),
      },
  ],
  'friends': g.friends.map(playerToWire).toList(),
  'friendMethods': g.friendMethods,
  'demoPlayers': g.demoPlayers.map(playerToWire).toList(),
  'booths': g.booths.map(boothToWire).toList(),
  'stations': g.stations.map(stationToWire).toList(),
  'ledger': [
    for (final l in g.ledger)
      {
        'at': l.at.toUtc().toIso8601String(),
        'reason': l.reason,
        'detail': l.detail,
        'coins': l.coins,
        'args': l.args,
      },
  ],
  'history': [
    for (final h in g.history)
      {
        'battle': battleToWire(h.battle),
        'at': h.at.toUtc().toIso8601String(),
        'points': h.points,
        'coins': h.coins,
        'reward': h.reward?.index,
      },
  ],
  'battle': g.battle == null ? null : battleToWire(g.battle!),
  'cooldownUntil': g.cooldownUntil?.toUtc().toIso8601String(),
  'hintCredits': g.hintCredits, 'hintRemainder': g.hintRemainder,
  'randomEggPrice': g.randomEggPrice, 'seriesEggPrice': g.seriesEggPrice,
  'parameters': g.parameters,
  // Calculated by the authoritative core, not reimplemented in the client.
  'battleBlocked': {
    for (final p in g.demoPlayers) p.id: g.battleBlocked(p)?.toJson(),
  },
  'unknownBattleBlocked': g
      .battleBlocked(const PlayerCard(id: '', name: '', tags: []))
      ?.toJson(),
  'rankings': {
    for (final metric in rankingMetrics)
      metric: [
        for (final r in g.ranking(metric))
          {'player': playerToWire(r.player), 'value': r.value},
      ],
  },
};

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();
DateTime? _date(dynamic value) =>
    value == null ? null : DateTime.parse(value as String);

/// An immutable decoded view, with no local mutation, clock or game engine.
class GameSnapshot {
  GameSnapshot.fromJson(Map<String, dynamic> json) {
    if (json['version'] != gameWireVersion) {
      throw GameStateError(const GameMessage('wireVersion'));
    }
    me = playerFromWire(_map(json['me']));
    checkedIn = json['checkedIn'] as bool;
    badgeUid = json['badgeUid'] as String?;
    earlyClaimed = json['earlyClaimed'] as bool;
    tutorialSeen = json['tutorialSeen'] as bool;
    role = AccountRole.values.byName(json['role'] as String);
    boothId = json['boothId'] as String?;
    phase = EventPhase.values.byName(json['phase'] as String);
    hand = List<int>.unmodifiable(json['hand'] as List);
    coins = json['coins'] as int;
    points = json['points'] as int;
    packs = json['packs'] as int;
    peekCards = json['peekCards'] as int;
    planets = Set<int>.unmodifiable((json['planets'] as List).cast<int>());
    planetDates = Map<int, DateTime>.unmodifiable(
      _map(json['planetDates'])
          .map((k, v) => MapEntry(int.parse(k), DateTime.parse(v as String))),
    );
    missions = List<Mission>.unmodifiable(
      (json['missions'] as List).map((v) {
        final m = _map(v);
        return Mission(
          tag: m['tag'] as String,
          category: m['category'] as String,
          own: m['own'] as bool,
          friends: List<String>.unmodifiable(m['friends'] as List),
          completedAt: _date(m['completedAt']),
        );
      }),
    );
    checkpoints = List<Checkpoint>.unmodifiable(
      (json['checkpoints'] as List).map((v) {
        final c = _map(v);
        return Checkpoint(
          number: c['number'] as int,
          area: c['area'] as String,
          collectedAt: _date(c['collectedAt']),
          hint: c['hint'] == null
              ? null
              : GameMessage.fromJson(_map(c['hint'])),
        );
      }),
    );
    friends = List<PlayerCard>.unmodifiable(
      (json['friends'] as List).map((v) => playerFromWire(_map(v))),
    );
    friendMethods = Map<String, String>.unmodifiable(
      _map(json['friendMethods']).cast<String, String>(),
    );
    demoPlayers = List<PlayerCard>.unmodifiable(
      (json['demoPlayers'] as List).map((v) => playerFromWire(_map(v))),
    );
    booths = List<Booth>.unmodifiable(
      (json['booths'] as List).map((v) => boothFromWire(_map(v))),
    );
    stations = List<Station>.unmodifiable(
      (json['stations'] as List).map((v) => stationFromWire(_map(v))),
    );
    ledger = List<LedgerEntry>.unmodifiable(
      (json['ledger'] as List).map((v) {
        final l = _map(v);
        return LedgerEntry(
          DateTime.parse(l['at'] as String),
          l['reason'] as String,
          l['detail'] as String,
          coins: l['coins'] as int,
          args: Map<String, Object?>.unmodifiable(_map(l['args'])),
        );
      }),
    );
    history = List<BattleRecord>.unmodifiable(
      (json['history'] as List).map((v) {
        final h = _map(v);
        return BattleRecord(
          battleFromWire(_map(h['battle'])),
          DateTime.parse(h['at'] as String),
          h['points'] as int,
          h['coins'] as int,
          h['reward'] == null ? null : HandCard.values[h['reward'] as int],
        );
      }),
    );
    battle = json['battle'] == null
        ? null
        : battleFromWire(_map(json['battle']));
    cooldownUntil = _date(json['cooldownUntil']);
    hintCredits = json['hintCredits'] as int;
    hintRemainder = json['hintRemainder'] as int;
    randomEggPrice = json['randomEggPrice'] as int;
    seriesEggPrice = json['seriesEggPrice'] as int;
    parameters = Map<String, int>.unmodifiable(
      _map(json['parameters']).cast<String, int>(),
    );
    _battleBlocked = Map<String, GameMessage?>.unmodifiable(
      _map(json['battleBlocked']).map(
        (key, value) => MapEntry(
          key,
          value == null ? null : GameMessage.fromJson(_map(value)),
        ),
      ),
    );
    _unknownBattleBlocked = json['unknownBattleBlocked'] == null
        ? null
        : GameMessage.fromJson(_map(json['unknownBattleBlocked']));
    _rankings = Map<String, List<RankEntry>>.unmodifiable(
      _map(json['rankings']).map(
        (k, v) => MapEntry(
          k,
          List<RankEntry>.unmodifiable(
            (v as List).map((entry) {
              final r = _map(entry);
              return RankEntry(
                playerFromWire(_map(r['player'])),
                r['value'] as int,
              );
            }),
          ),
        ),
      ),
    );
  }
  late final PlayerCard me;
  late final bool checkedIn, earlyClaimed, tutorialSeen;
  late final AccountRole role;
  late final String? boothId, badgeUid;
  late final EventPhase phase;
  late final List<int> hand;
  late final int coins, points, packs, peekCards, hintCredits, hintRemainder;
  late final int randomEggPrice, seriesEggPrice;
  late final Map<String, int> parameters;
  late final Set<int> planets;
  late final Map<int, DateTime> planetDates;
  late final List<Mission> missions;
  late final List<Checkpoint> checkpoints;
  late final List<PlayerCard> friends, demoPlayers;
  late final Map<String, String> friendMethods;
  late final List<Booth> booths;
  late final List<Station> stations;
  late final List<LedgerEntry> ledger;
  late final List<BattleRecord> history;
  late final Battle? battle;
  late final DateTime? cooldownUntil;
  late final Map<String, GameMessage?> _battleBlocked;
  late final GameMessage? _unknownBattleBlocked;
  late final Map<String, List<RankEntry>> _rankings;
  GameMessage? battleBlocked(PlayerCard p) => _battleBlocked.containsKey(p.id)
      ? _battleBlocked[p.id]
      : _unknownBattleBlocked;
  List<RankEntry> ranking(String metric) =>
      _rankings[metric] ??
      (throw GameArgumentError(
        GameMessage('unknownRanking', {'metric': metric}),
      ));
}
