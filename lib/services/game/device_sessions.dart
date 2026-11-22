import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sitcon_backend/game/game_service.dart';

import 'game_api_client.dart';
import 'http_game_service.dart';

class DeviceSessions {
  DeviceSessions({required this.readRecord, required this.writeRecord});

  factory DeviceSessions.secure() {
    const storage = FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
      aOptions: AndroidOptions(resetOnError: false),
    );
    // iOS Keychain items may survive app deletion. A sandbox-only installation
    // marker keeps a reinstall from reopening credentials from the old app.
    Future<String>? installation;
    Future<String> storageKey(String key) async {
      try {
        final id = await (installation ??= _loadInstallation());
        return '$id:$key';
      } catch (_) {
        installation = null;
        rethrow;
      }
    }
    return DeviceSessions(
      readRecord: (key) async => storage.read(key: await storageKey(key)),
      writeRecord: (key, value) async {
        await storage.write(key: await storageKey(key), value: value);
        if (Platform.isAndroid) {
          const channel = MethodChannel('org.sitcon/device_sessions');
          await channel.invokeMethod<void>('flush');
        }
      },
    );
  }

  final Future<String?> Function(String key) readRecord;
  final Future<void> Function(String key, String value) writeRecord;

  static Future<String> _loadInstallation() async {
    final root = await getApplicationSupportDirectory();
    final marker = File('${root.path}/device-session-installation');
    if (await marker.exists()) {
      final id = await marker.readAsString();
      if (!_validBearer(id)) throw const FormatException();
      return id;
    }
    await root.create(recursive: true);
    final id = _newBearer();
    final pending = File('${marker.path}.pending');
    await pending.writeAsString(id, flush: true);
    await pending.rename(marker.path);
    return id;
  }

  static String _newBearer() {
    final random = Random.secure();
    return base64UrlEncode(List.generate(32, (_) => random.nextInt(256)))
        .replaceAll('=', '');
  }

  /// A null code opens the saved player (or enrolls on a clean installation).
  /// An empty code explicitly resumes a previously submitted transfer.
  Future<HttpGameService> open(String baseUrl, {String? transferCode}) async {
    final api = GameApiClient(baseUrl)..requireSecureTransport();
    final key = 'device-session:${api.origin.origin}';
    try {
      final record = await _load(key);
      final playerId = record['playerId'] as String?;
      final activeBearer = record['bearer'] as String?;
      if (transferCode == null && playerId != null && activeBearer != null) {
        return HttpGameService(
          baseUrl: api.origin.origin, playerId: playerId, bearer: activeBearer,
        );
      }

      final pendingCode = record['transferCode'] as String?;
      final code = transferCode == null || transferCode.isEmpty
          ? pendingCode
          : transferCode;
      final String bearer;
      final Map<String, dynamic> data;
      if (code != null) {
        final candidate = code == pendingCode ? record['transferBearer'] as String? : null;
        bearer = candidate ?? _newBearer();
        await _save(key, {...record, 'transferCode': code, 'transferBearer': bearer});
        try {
          data = await api.request(
            'POST', '/api/session/transfer', bearer: bearer, body: {'code': code},
          );
        } on GameApiException catch (error) {
          if (error.localizedMessage.code == 'deviceTransferInvalid' ||
              error.localizedMessage.code == 'deviceSessionConflict') {
            await _save(key, {...record}..remove('transferCode')..remove('transferBearer'));
          }
          rethrow;
        }
      } else {
        if (transferCode != null) {
          throw GameStateError(const GameMessage('deviceTransferInvalid'));
        }
        bearer = activeBearer ?? _newBearer();
        await _save(key, {...record, 'bearer': bearer});
        data = await api.request('POST', '/api/session/enroll', bearer: bearer, body: const {});
      }
      final enrolledId = requireApiString(data, 'playerId');
      await _save(key, {'bearer': bearer, 'playerId': enrolledId});
      return HttpGameService(
        baseUrl: api.origin.origin, playerId: enrolledId, bearer: bearer,
      );
    } finally {
      api.close();
    }
  }

  Future<Map<String, dynamic>> _load(String key) async {
    try {
      final raw = await readRecord(key);
      if (raw == null) return {};
      final data = (jsonDecode(raw) as Map).cast<String, dynamic>();
      final id = data['playerId'];
      final bearer = data['bearer'];
      final code = data['transferCode'];
      final candidate = data['transferBearer'];
      if ((id != null && (id is! String || id.isEmpty || bearer == null)) ||
          (bearer != null && !_validBearer(bearer)) ||
          ((code == null) != (candidate == null)) ||
          (code != null && (code is! String || code.isEmpty)) ||
          (candidate != null && !_validBearer(candidate))) {
        throw const FormatException();
      }
      return data;
    } on Exception {
      throw GameStateError(const GameMessage('deviceStorageUnavailable'));
    } on TypeError {
      throw GameStateError(const GameMessage('deviceStorageUnavailable'));
    }
  }

  static bool _validBearer(Object value) =>
      value is String && RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(value);

  Future<void> _save(String key, Map<String, dynamic> record) async {
    try {
      await writeRecord(key, jsonEncode(record));
    } on Exception {
      throw GameStateError(const GameMessage('deviceStorageUnavailable'));
    }
  }
}
