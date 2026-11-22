import 'dart:io';

import 'package:path_provider/path_provider.dart';

Uri? testServerOrigin(String input) {
  final uri = Uri.tryParse(input.trim());
  if (uri == null ||
      (uri.scheme != 'http' && uri.scheme != 'https') ||
      uri.host.isEmpty ||
      uri.authority.contains('@') ||
      (uri.path.isNotEmpty && uri.path != '/') ||
      uri.hasQuery ||
      uri.hasFragment ||
      uri.port < 1 ||
      uri.port > 65535) {
    return null;
  }
  return Uri.parse(uri.origin);
}

class TestServerSettings {
  TestServerSettings(this._file);

  final File _file;
  String? lastUrl;

  static Future<TestServerSettings> load() async {
    final root = await getApplicationSupportDirectory();
    final settings = TestServerSettings(
      File('${root.path}/preferences/test-server-url'),
    );
    await settings.read();
    return settings;
  }

  Future<void> read() async {
    if (!await _file.exists()) return;
    lastUrl = testServerOrigin(await _file.readAsString())?.toString();
  }

  Future<void> remember(Uri origin) async {
    final url = origin.toString();
    if (url == lastUrl) return;
    await _file.parent.create(recursive: true);
    final pending = File('${_file.path}.pending');
    await pending.writeAsString(url, flush: true);
    await pending.rename(_file.path);
    lastUrl = url;
  }
}
