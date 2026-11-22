import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sitcon_app/services/game/device_sessions.dart';
import 'package:sitcon_app/services/game/http_game_service.dart';
import 'package:sitcon_backend/game/game_service.dart';

DeviceSessions installation(Map<String, String> disk) => DeviceSessions(
  readRecord: (key) async => disk[key],
  writeRecord: (key, value) async {
    disk[key] = value;
  },
);

String authorization(HttpRequest request) {
  final header = request.headers.value(HttpHeaders.authorizationHeader);
  expect(header, matches(r'^Bearer [A-Za-z0-9_-]{43}$'));
  return header!.substring('Bearer '.length);
}

void reply(HttpResponse response, Map<String, Object?> data) {
  response.headers.contentType = ContentType.json;
  response.write(jsonEncode({'data': data}));
}

void main() {
  late HttpServer server;
  late String origin;
  late Future<void> Function(HttpRequest request) respond;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    origin = 'http://127.0.0.1:${server.port}';
    server.listen((request) async {
      try {
        await respond(request);
      } finally {
        await request.response.close();
      }
    });
  });
  tearDown(() => server.close(force: true));

  test('enrolls with a persistent pending bearer; reopens by normalized origin', () async {
    final disk = <String, String>{};
    final bearers = <String>[];
    respond = (request) async {
      expect(request.uri.path, '/api/session/enroll');
      final bearer = authorization(request);
      bearers.add(bearer);
      expect(disk.values.any((value) => jsonDecode(value)['bearer'] == bearer), isTrue);
      expect(jsonDecode(await utf8.decoder.bind(request).join()), isEmpty);
      if (bearers.length == 1) {
        // Simulate a server allocation whose reply could not be read by the app.
        request.response.write('not JSON');
        return;
      }
      reply(request.response, {'playerId': 'player-${bearers.length}'});
    };

    await expectLater(installation(disk).open(origin), throwsA(isA<GameStateError>()));
    final retry = await installation(disk).open('$origin/');
    addTearDown(retry.dispose);
    final reopened = await installation(disk).open(origin);
    addTearDown(reopened.dispose);
    expect(reopened.playerId, retry.playerId);
    expect(bearers, hasLength(2));
    expect(bearers.first, bearers.last);

    final distinctOrigin = await installation(disk).open('http://localhost:${server.port}');
    addTearDown(distinctOrigin.dispose);
    expect(distinctOrigin.playerId, isNot(reopened.playerId));
    expect(bearers.last, isNot(bearers.first));
    expect(disk, hasLength(2));
  });

  test('failed transfer preserves destination; retry promotes and revoked device never reenrolls', () async {
    final sourceDisk = <String, String>{};
    final destinationDisk = <String, String>{};
    final owners = <String, String>{};
    String? accepted;
    const code = 'private-transfer-code';
    var enrollments = 0;
    respond = (request) async {
      final bearer = authorization(request);
      final body = await utf8.decoder.bind(request).join();
      switch (request.uri.path) {
        case '/api/session/enroll':
          final id = 'player-${++enrollments}';
          owners[id] = bearer;
          reply(request.response, {'playerId': id});
        case '/api/players/player-1/transfer-code':
          expect(bearer, owners['player-1']);
          reply(request.response, {'code': code});
        case '/api/session/transfer':
          final entered = jsonDecode(body)['code'];
          final saved = jsonDecode(destinationDisk.values.single);
          expect(saved['playerId'], 'player-2');
          expect(saved['bearer'], owners['player-2']);
          expect(saved['transferBearer'], bearer);
          expect(saved['transferCode'], entered);
          expect(bearer, isNot(owners['player-2']));
          if (entered != code) {
            request.response.statusCode = HttpStatus.badRequest;
            request.response.write(jsonEncode({
              'error': {
                'code': 'device_transfer_invalid',
                'message': const GameMessage('deviceTransferInvalid').toJson(),
              },
            }));
          } else if (accepted == null) {
            owners['player-1'] = accepted = bearer;
            request.response.write('lost reply');
          } else {
            expect(bearer, accepted);
            reply(request.response, {'playerId': 'player-1'});
          }
        case '/api/players/player-1/state':
          expect(bearer, isNot(owners['player-1']));
          request.response.statusCode = HttpStatus.unauthorized;
        default:
          fail('Unexpected endpoint: ${request.uri.path}');
      }
    };

    final source = await installation(sourceDisk).open(origin);
    addTearDown(source.dispose);
    final destination = await installation(destinationDisk).open(origin);
    addTearDown(destination.dispose);
    final issued = await source.issueTransferCode();
    await expectLater(
      installation(destinationDisk).open(origin, transferCode: 'invalid-code'),
      throwsA(isA<GameApiException>()),
    );
    final preserved = await installation(destinationDisk).open(origin);
    addTearDown(preserved.dispose);
    expect(preserved.playerId, destination.playerId);

    await expectLater(
      installation(destinationDisk).open(origin, transferCode: issued),
      throwsA(isA<GameStateError>()),
    );
    final beforeRetry = await installation(destinationDisk).open(origin);
    addTearDown(beforeRetry.dispose);
    expect(beforeRetry.playerId, destination.playerId);
    final transferred = await installation(destinationDisk).open(origin, transferCode: '');
    addTearDown(transferred.dispose);
    expect(transferred.playerId, source.playerId);
    expect(jsonDecode(destinationDisk.values.single)['transferCode'], isNull);
    expect(jsonDecode(destinationDisk.values.single)['bearer'], accepted);
    final reopenedSource = await installation(sourceDisk).open(origin);
    addTearDown(reopenedSource.dispose);
    GameApiException? revocation;
    reopenedSource.onSessionRevoked = (failure) => revocation = failure;
    await expectLater(
      reopenedSource.initialize(),
      throwsA(isA<GameApiException>().having((e) => e.status, 'status', 401)),
    );
    expect(revocation?.localizedMessage.code, 'deviceSessionRequired');
    expect(enrollments, 2);
  });

  test('rejects non-loopback HTTP and never follows auth or player redirects', () async {
    final disk = <String, String>{};
    await expectLater(
      installation(disk).open('http://192.0.2.1'),
      throwsA(isA<GameArgumentError>().having(
        (e) => e.localizedMessage.code, 'code', 'deviceSecureOriginRequired',
      )),
    );
    expect(disk, isEmpty);
    final paths = <String>[];
    respond = (request) async {
      paths.add(request.uri.path);
      authorization(request);
      await request.drain<void>();
      request.response.statusCode = HttpStatus.seeOther;
      request.response.headers.set(HttpHeaders.locationHeader, '$origin/redirected');
    };
    await expectLater(installation(disk).open(origin), throwsA(isA<GameStateError>()));
    final player = HttpGameService(
      baseUrl: origin,
      playerId: 'redirect-fixture',
      bearer: jsonDecode(disk.values.single)['bearer'] as String,
    );
    addTearDown(player.dispose);
    await expectLater(player.initialize(), throwsA(isA<GameStateError>()));
    expect(paths, ['/api/session/enroll', '/api/players/redirect-fixture/state']);
  });
}
