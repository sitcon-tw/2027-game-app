import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sitcon_app/services/preferences/test_server_settings.dart';

void main() {
  test('most recent server origin survives reopening preferences', () async {
    final directory = await Directory.systemTemp.createTemp('server-settings-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/preferences/test-server-url');
    final settings = TestServerSettings(file);
    await settings.remember(testServerOrigin('http://127.0.0.1:8787')!);
    await settings.remember(testServerOrigin(' https://example.test:8443/ ')!);

    final reopened = TestServerSettings(file);
    await reopened.read();
    expect(reopened.lastUrl, 'https://example.test:8443');
  });
}
