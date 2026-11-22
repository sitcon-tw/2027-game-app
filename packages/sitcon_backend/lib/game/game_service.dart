/// Locale-neutral UI content. Codes are stable across persistence and transport.
class GameMessage {
  const GameMessage(this.code, [this.args = const {}]);
  final String code;
  final Map<String, Object?> args;
  factory GameMessage.fromJson(Map<String, dynamic> json) => GameMessage(
    json['code'] as String,
    Map<String, Object?>.unmodifiable(
      (json['args'] as Map? ?? const {}).cast<String, Object?>(),
    ),
  );
  Map<String, Object?> toJson() => {'code': code, 'args': args};

  @override
  bool operator ==(Object other) =>
      other is GameMessage &&
      code == other.code &&
      args.length == other.args.length &&
      args.entries.every(
        (entry) =>
            other.args.containsKey(entry.key) &&
            other.args[entry.key] == entry.value,
      );
  @override
  int get hashCode => Object.hash(
    code,
    Object.hashAllUnordered(
      args.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
  );
}

/// Uses [localizedMessage] to avoid conflicting with StateError.message.
abstract interface class GameLocalizedError {
  GameMessage get localizedMessage;
}

class GameStateError extends StateError implements GameLocalizedError {
  GameStateError(this.localizedMessage) : super(localizedMessage.code);
  @override
  final GameMessage localizedMessage;
}

class GameArgumentError extends ArgumentError implements GameLocalizedError {
  GameArgumentError(this.localizedMessage) : super(localizedMessage.code);
  @override
  final GameMessage localizedMessage;
}

enum HandCard { scissors, rock, paper, wild }

enum EventPhase { before, active, ended }

enum AccountRole { user, staff, booth }

enum ScannerMode { user, staff, booth }

const cardNames = ['剪刀', '石頭', '布', '萬用卡'];
const seriesNames = ['太陽', '地球', '水星', '火星', '土星', '月球'];
const colorNames = ['綠', '粉', '橘', '黃', '淺藍', '深藍', '紫'];
const hashtagOptions = <String, List<String>>{
  '技術': [
    'AI',
    '資安',
    'CTF',
    '網頁前端',
    '後端',
    'App開發',
    '遊戲開發',
    '物聯網',
    '區塊鏈',
    'UI/UX',
    '競程',
    '各種程式語言',
  ],
  '派系': [
    'Vim派',
    'VSCode派',
    'Tab派',
    '空格派',
    '深色模式派',
    '貓派',
    '狗派',
    '咖哩不拌',
    '咖哩拌爆',
    '香菜是邪教',
    '火鍋加芋頭',
  ],
  '興趣': ['夜貓族', '咖啡續命', '手搖飲', '動漫', '電玩', '桌遊', '運動', '音樂', '攝影', '創客'],
};
const opposingTags = [
  ['Vim派', 'VSCode派'],
  ['Tab派', '空格派'],
  ['貓派', '狗派'],
  ['咖哩不拌', '咖哩拌爆'],
];

class PlayerCard {
  const PlayerCard({
    required this.id,
    required this.name,
    required this.tags,
    this.contact = '',
    this.planet,
    this.style = -1,
    this.roles = const ['會眾'],
  });
  final String id, name, contact;
  final List<String> tags, roles;
  final int? planet;
  final int style;
}

class Mission {
  const Mission({
    required this.tag,
    required this.category,
    required this.own,
    required this.friends,
    this.completedAt,
  });
  final String tag, category;
  final bool own;
  final List<String> friends;
  final DateTime? completedAt;
  int get progress => friends.length.clamp(0, 3);
}

class Checkpoint {
  const Checkpoint({
    required this.number,
    required this.area,
    this.collectedAt,
    this.hint,
  });
  final int number;
  final String area;
  final DateTime? collectedAt;
  final GameMessage? hint;
}

class Booth {
  const Booth({
    required this.id,
    required this.name,
    required this.url,
    this.visited = false,
    this.completed = false,
  });
  final String id, name, url;
  final bool visited, completed;
}

class Station {
  const Station({
    required this.id,
    required this.name,
    this.packs = 1,
    this.limit = 1,
    this.remaining = 100,
    this.open = true,
  });
  final String id, name;
  final int packs, limit, remaining;
  final bool open;
}

class LedgerEntry {
  const LedgerEntry(
    this.at,
    this.reason,
    this.detail, {
    this.coins = 0,
    this.args = const {},
  });
  final DateTime at;
  final String reason, detail;
  final int coins;
  final Map<String, Object?> args;
  GameMessage get message =>
      GameMessage('ledger.$reason', {...args, 'coins': coins});
}

class RoundResult {
  const RoundResult(
    this.mine,
    this.opponent,
    this.outcome, {
    this.automatic = false,
    this.wild = false,
  });
  final HandCard mine, opponent;
  final int outcome;
  final bool automatic, wild;
}

class Battle {
  const Battle({
    required this.id,
    required this.opponent,
    required this.deadline,
    this.accepted = false,
    this.rounds = const [],
    this.finished = false,
    this.peekUsed = false,
    this.opponentHand = const [4, 4, 4, 0],
  });
  final String id;
  final PlayerCard opponent;
  final DateTime deadline;
  final bool accepted, finished, peekUsed;
  final List<RoundResult> rounds;
  final List<int> opponentHand;
  int get wins => rounds.where((r) => r.outcome > 0).length;
  int get losses => rounds.where((r) => r.outcome < 0).length;
  int get result => wins.compareTo(losses);
}

class BattleRecord {
  const BattleRecord(
    this.battle,
    this.at,
    this.points,
    this.coins,
    this.reward,
  );
  final Battle battle;
  final DateTime at;
  final int points, coins;
  final HandCard? reward;
}

class RankEntry {
  const RankEntry(this.player, this.value);
  final PlayerCard player;
  final int value;
}

class ScanResult {
  const ScanResult(
    this.kind,
    this.message, {
    this.player,
    this.booth,
    this.uid,
    this.openPacks = false,
    this.station,
    this.targetPlayerId,
    this.repeated = false,
  });
  final String kind;
  final GameMessage message;
  final PlayerCard? player;
  final Booth? booth;
  final Station? station;
  final String? targetPlayerId;
  final bool repeated;
  final String? uid;
  final bool openPacks;
}

class HatchResult {
  const HatchResult(this.planet, this.seriesCompleted);
  final int planet;
  final bool seriesCompleted;
}

/// Service owns rules and persistence; views observe it only through a ViewModel.
abstract interface class GameService {
  void addListener(void Function() listener);
  void removeListener(void Function() listener);
  void dispose();
  Future<void> initialize();
  Map<String, int> get parameters;
  DateTime get now;
  PlayerCard get me;
  bool get checkedIn;
  String? get badgeUid;
  bool get earlyClaimed;
  bool get tutorialSeen;
  AccountRole get role;
  String? get boothId;
  EventPhase get phase;
  List<int> get hand;
  int get coins;
  int get points;
  int get packs;
  int get peekCards;
  Set<int> get planets;
  Map<int, DateTime> get planetDates;
  List<Mission> get missions;
  List<Checkpoint> get checkpoints;
  List<PlayerCard> get friends;
  Map<String, String> get friendMethods;
  List<PlayerCard> get demoPlayers;
  List<Booth> get booths;
  List<Station> get stations;
  List<LedgerEntry> get ledger;
  List<BattleRecord> get history;
  Battle? get battle;
  DateTime? get cooldownUntil;
  int get hintCredits;
  int get hintRemainder;
  int get randomEggPrice;
  int get seriesEggPrice;
  GameMessage? battleBlocked(PlayerCard opponent);
  List<RankEntry> ranking(String metric);
  Future<void> bindBadge(String uid);
  Future<void> saveProfile(
    List<String> tags,
    String contact, {
    String? nickname,
  });
  Future<void> finishTutorial();
  Future<void> claimEarly();
  Future<ScanResult> scan(
    String uid,
    String scanId, {
    ScannerMode mode = ScannerMode.user,
  });
  Future<void> requestFriend(String playerId);

  /// Mock counterpart scans our badge. No production acceptance endpoint.
  Future<void> simulateReciprocalScan(String playerId);
  Future<void> inviteBattle(String playerId);
  Future<void> cancelBattle();
  Future<void> playCard(HandCard card, {HandCard? asCard});
  Future<void> usePeek();

  /// Resolve expired invitation/round deadlines, including after app resume.
  Future<void> tick();
  Future<List<HandCard>> openPacks({bool all = false});
  Future<HatchResult> buyEgg({int? series});
  Future<void> selectAppearance(int? planet, int style);
  Future<GameMessage> redeemHint();
  Future<void> bindStation(String uid, String stationId);
}
