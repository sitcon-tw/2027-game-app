import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sitcon_app/services/game/http_game_service.dart';
import 'package:sitcon_backend/game/game_engine.dart';
import 'package:sitcon_backend/game/game_service.dart';
import 'package:sitcon_backend/game/game_wire.dart';

class _MemoryStorage implements GameStorage {
  String? document;

  @override
  Future<String?> read() async => document;

  @override
  Future<void> write(String value) async => document = value;
}

void main() {
  late HttpServer server;
  late HttpGameService client;
  late GameEngine fixture;
  late Future<void> Function(HttpRequest) respond;

  setUp(() async {
    fixture = GameEngine(
      storage: _MemoryStorage(),
      initialPhase: EventPhase.active,
    );
    await fixture.initialize();
    await fixture.saveProfile(['AI', 'Vim派', '夜貓族'], '');
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      try {
        await respond(request);
      } finally {
        await request.response.close();
      }
    });
    client = HttpGameService(
      baseUrl: 'http://127.0.0.1:${server.port}',
      playerId: 'named-player',
    );
  });

  tearDown(() async {
    client.dispose();
    await server.close(force: true);
    fixture.dispose();
  });

  void sendState(
    HttpRequest request,
    int sequence, [
    Map<String, dynamic> state = const {},
  ]) {
    request.response.headers.contentType = ContentType.json;
    request.response.write(
      jsonEncode({
        'data': {
          'instance': 'test-instance',
          'sequence': sequence,
          'serverTime': DateTime.now().toUtc().toIso8601String(),
          'state': {...gameToWire(fixture), ...state},
        },
      }),
    );
  }

  test('loads named player and applies authoritative action state', () async {
    const uid = '04A20000000001';
    final calls = <(String, String)>[];
    Object? payload;
    respond = (request) async {
      calls.add((request.method, request.uri.path));
      if (request.method == 'POST') {
        payload = jsonDecode(await utf8.decoder.bind(request).join());
        await fixture.bindBadge(uid);
      }
      sendState(request, calls.length);
    };

    await client.initialize();
    expect(client.checkedIn, isFalse);
    await client.bindBadge(uid);
    expect(client.checkedIn, isTrue);
    expect(client.multiplayer, isNull);
    expect(calls, [
      ('GET', '/api/players/named-player/state'),
      ('POST', '/api/players/named-player/actions'),
    ]);
    expect(payload, {
      'action': 'bindBadge',
      'args': {'uid': uid},
    });
  });

  test('live actions keep their target and round in the request', () async {
    const peer = PlayerCard(id: 'p-peer', name: 'Peer', tags: ['AI']);
    const id = 'live-match';
    final calls = <Object?>[];
    var sequence = 0;
    var live = true;
    respond = (request) async {
      if (request.method == 'POST') {
        calls.add(jsonDecode(await utf8.decoder.bind(request).join()));
      }
      sendState(request, ++sequence, {
        if (live) ...{
          'multiplayer': {
            'incomingFriends': [playerToWire(peer)],
            'outgoingFriends': [peer.id],
            'scanned': [peer.id],
            'battle': {'id': id, 'incoming': true, 'played': false},
          },
          'battle': battleToWire(
            Battle(
              id: id,
              opponent: peer,
              deadline: DateTime.now().add(const Duration(seconds: 10)),
              accepted: true,
              rounds: const [
                RoundResult(HandCard.scissors, HandCard.paper, 1),
              ],
            ),
          ),
        },
      });
    };

    await client.initialize();
    final snapshot = client.multiplayer!;
    expect(snapshot.incomingFriends.single.id, peer.id);
    expect(snapshot.outgoingFriends, {peer.id});
    expect(snapshot.scanned, {peer.id});
    expect(snapshot.battle?.id, id);
    expect(snapshot.battle?.incoming, true);
    expect(snapshot.battle?.waitingReady, false); // Older servers omit the gate.

    await client.respondFriend(peer.id, true);
    await client.respondBattle(id, false);
    await client.readyBattle(id, 1);
    await client.playCard(HandCard.wild, asCard: HandCard.rock);
    await client.usePeek();
    await client.cancelBattle();
    live = false;
    await client.tick();
    expect(client.multiplayer, isNull);
    await client.usePeek();
    expect(calls, [
      {
        'action': 'respondFriend',
        'args': {'playerId': peer.id, 'accept': true},
      },
      {
        'action': 'respondBattle',
        'args': {'battleId': id, 'accept': false},
      },
      {
        'action': 'readyBattle',
        'args': {'battleId': id, 'round': 1},
      },
      {
        'action': 'playCard',
        'args': {
          'card': HandCard.wild.index,
          'asCard': HandCard.rock.index,
          'battleId': id,
          'round': 1,
        },
      },
      {
        'action': 'usePeek',
        'args': {'battleId': id, 'round': 1},
      },
      {
        'action': 'cancelBattle',
        'args': {'battleId': id},
      },
      {'action': 'usePeek', 'args': {}},
    ]);
  });

  test(
    'invalid initialization can retry; rejected mutation leaves state intact',
    () async {
      respond = (request) async => request.response.write('not JSON');
      await expectLater(client.initialize(), throwsA(isA<GameStateError>()));

      respond = (request) async {
        if (request.method == 'GET') {
          sendState(request, 1);
          return;
        }
        await request.drain<void>();
        request.response.statusCode = HttpStatus.conflict;
        request.response.write(
          jsonEncode({
            'error': {
              'code': 'game_rule',
              'message': const GameMessage('serverFailure').toJson(),
            },
          }),
        );
      };
      await client.initialize();
      await expectLater(
        client.bindBadge('04A20000000001'),
        throwsA(
          isA<GameApiException>()
              .having((error) => error.status, 'status', HttpStatus.conflict)
              .having(
                (error) => error.localizedMessage.code,
                'message code',
                'serverFailure',
              ),
        ),
      );
      expect(client.checkedIn, isFalse);
    },
  );
}
