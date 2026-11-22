import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final safeName = name.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final file = File('build/flow-screenshots/$safeName.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
      if (name.endsWith('share-sheet')) {
        final nativeFile = 'build/flow-screenshots/$safeName-native.png';
        if (name.startsWith('ios-')) {
          final result = await Process.run('xcrun', [
            'simctl',
            'io',
            'B883627D-4424-4F63-B037-BC2D3843E5CD',
            'screenshot',
            nativeFile,
          ]);
          if (result.exitCode != 0) throw StateError('${result.stderr}');
        } else if (name.startsWith('android-')) {
          final result = await Process.run('adb', [
            '-s',
            'emulator-5554',
            'exec-out',
            'screencap',
            '-p',
          ], stdoutEncoding: null);
          if (result.exitCode != 0) throw StateError('${result.stderr}');
          await File(nativeFile).writeAsBytes(result.stdout as List<int>);
        }
      }
      return bytes.isNotEmpty;
    },
  );
}
