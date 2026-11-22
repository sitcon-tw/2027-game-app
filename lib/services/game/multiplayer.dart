import 'package:sitcon_backend/game/game_service.dart';
import 'package:sitcon_backend/game/game_wire.dart';

typedef MultiplayerBattle = ({
  String id,
  bool incoming,
  bool played,
  bool waitingReady,
  bool ready,
});

/// Optional player state. Older servers and offline games have no live inbox.
class MultiplayerState {
  MultiplayerState.fromJson(Map<String, dynamic> json)
    : incomingFriends = List<PlayerCard>.unmodifiable(
        (json['incomingFriends'] as List).map(
          (player) => playerFromWire((player as Map).cast<String, dynamic>()),
        ),
      ),
      outgoingFriends = Set<String>.unmodifiable(
        (json['outgoingFriends'] as List).cast<String>(),
      ),
      scanned = Set<String>.unmodifiable(
        (json['scanned'] as List).cast<String>(),
      ),
      battle = _battleFromJson(json['battle'] as Map?);

  final List<PlayerCard> incomingFriends;
  final Set<String> outgoingFriends, scanned;
  final MultiplayerBattle? battle;

  static MultiplayerBattle? _battleFromJson(Map? json) => json == null
      ? null
      : (
          id: json['id'] as String,
          incoming: json['incoming'] as bool,
          played: json['played'] as bool,
          waitingReady: json['waitingReady'] == true,
          ready: json['ready'] == true,
        );
}

abstract interface class Multiplayer {
  MultiplayerState? get multiplayer;
  Future<void> respondFriend(String playerId, bool accept);
  Future<void> respondBattle(String battleId, bool accept);
  Future<void> readyBattle(String battleId, int round);
}
