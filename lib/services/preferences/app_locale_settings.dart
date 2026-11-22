import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

enum AppLanguage { system, zhTw, en }

class AppLocaleSettings extends ValueNotifier<AppLanguage> {
  AppLocaleSettings({this._directory}) : super(AppLanguage.system);

  final Directory? _directory;
  File? _file;

  Locale? get locale => switch (value) {
    AppLanguage.system => null,
    AppLanguage.zhTw => const Locale('zh', 'TW'),
    AppLanguage.en => const Locale('en'),
  };

  Future<File> _settingsFile() async {
    if (_file case final file?) return file;
    final root = _directory ?? await getApplicationSupportDirectory();
    return _file = File('${root.path}/preferences/language');
  }

  Future<void> load() async {
    final file = await _settingsFile();
    if (!await file.exists()) return;
    value = switch ((await file.readAsString()).trim()) {
      'zh_TW' => AppLanguage.zhTw,
      'en' => AppLanguage.en,
      _ => AppLanguage.system,
    };
  }

  Future<void> setLanguage(AppLanguage language) async {
    final file = await _settingsFile();
    final name = switch (language) {
      AppLanguage.system => 'system',
      AppLanguage.zhTw => 'zh_TW',
      AppLanguage.en => 'en',
    };
    await file.parent.create(recursive: true);
    final pending = File('${file.path}.pending');
    await pending.writeAsString(name, flush: true);
    await pending.rename(file.path);
    value = language;
  }
}

final appLocaleSettings = AppLocaleSettings();
