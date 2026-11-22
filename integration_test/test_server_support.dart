import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sitcon_app/services/game/device_sessions.dart';

const testApiBase = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8787',
);

int _lastFixtureStamp = 0;

String createTestBadgeUid() {
  final now = DateTime.now().microsecondsSinceEpoch;
  final stamp = now > _lastFixtureStamp ? now : _lastFixtureStamp + 1;
  _lastFixtureStamp = stamp;
  return '04AA${(stamp & 0xffffffffff).toRadixString(16).padLeft(10, '0').toUpperCase()}';
}

DeviceSessions testInstallation() {
  final records = <String, String>{};
  return DeviceSessions(
    readRecord: (key) async => records[key],
    writeRecord: (key, value) async {
      records[key] = value;
    },
  );
}

Future<Map<String, dynamic>> adminAction(
  String action, [
  Map<String, dynamic> args = const {},
]) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(
      Uri.parse('$testApiBase/api/admin/actions'),
    );
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({'action': action, 'args': args}));
    final response = await request.close();
    final body = jsonDecode(
      await utf8.decoder.bind(response).join(),
    ) as Map<String, dynamic>;
    expect(response.statusCode, 200, reason: '$action: $body');
    return body['data'] as Map<String, dynamic>;
  } finally {
    client.close(force: true);
  }
}

Future<void> until(
  WidgetTester tester,
  bool Function() predicate, {
  String reason = 'server state update',
}) async {
  for (var attempt = 0; attempt < 80; attempt++) {
    if (predicate()) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(predicate(), true, reason: reason);
}
