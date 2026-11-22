import 'dart:convert';
import 'dart:io';

import 'package:sitcon_backend/game/game_service.dart';
import 'package:sitcon_backend/game/game_engine.dart';

/// A complete engine document is committed by atomic replacement, never in place.
/// A failed/corrupt read is an error, not permission to replace saved progress.
class DemoGameStorage implements GameStorage {
  DemoGameStorage(this.file);
  final File file;

  @override
  Future<String?> read() async {
    if (!await file.exists()) return null;
    final raw = await file.readAsString();
    try {
      _validate(jsonDecode(raw));
    } catch (_) {
      throw GameStateError(const GameMessage('corruptSave'));
    }
    return raw;
  }

  @override
  Future<void> write(String value) async {
    await file.parent.create(recursive: true);
    final pending = File('${file.path}.pending');
    await pending.writeAsString(value, flush: true);
    await pending.rename(file.path);
  }
}

// Storage-shape validation only: gameplay rules remain exclusively in the core.
void _require(bool valid) {
  if (!valid) throw const FormatException('Invalid demo state');
}

Map<String, dynamic> _object(dynamic value) {
  _require(value is Map<String, dynamic>);
  return value as Map<String, dynamic>;
}

List<dynamic> _list(dynamic value) {
  _require(value is List);
  return value as List;
}

bool _integer(dynamic value, [int minimum = 0, int? maximum]) =>
    value is int && value >= minimum && (maximum == null || value <= maximum);
bool _date(dynamic value) =>
    value is String && DateTime.tryParse(value) != null;
bool _nullableDate(dynamic value) => value == null || _date(value);
bool _strings(dynamic value) =>
    value is List && value.every((v) => v is String);
bool _hand(dynamic value) =>
    value is List && value.length == 4 && value.every((v) => _integer(v));
bool _planet(dynamic value) => value == null || _integer(value, 0, 41);

void _player(dynamic value) {
  final p = _object(value);
  _require(p['id'] is String && p['name'] is String);
  _require(_strings(p['tags']) && p['contact'] is String);
  _require(_planet(p['planet']) && _integer(p['style'], -1, 5));
}

void _battle(dynamic value) {
  final b = _object(value);
  _require(b['id'] is String && _date(b['deadline']));
  _player(b['opponent']);
  for (final key in ['accepted', 'finished', 'peekUsed']) {
    _require(b[key] is bool);
  }
  _require(_hand(b['opponentHand']));
  final rounds = _list(b['rounds']);
  _require(rounds.length <= 3);
  for (final value in rounds) {
    final r = _object(value);
    _require(_integer(r['mine'], 0, 3) && _integer(r['opponent'], 0, 3));
    _require(_integer(r['outcome'], -1, 1));
    _require(r['automatic'] is bool && r['wild'] is bool);
  }
}

void _validate(dynamic value) {
  final s = _object(value);
  _require(s['version'] == 1);
  for (final key in ['name', 'contact']) {
    _require(s[key] is String);
  }
  _require(s.containsKey('badge'));
  _require(
    s['badge'] == null ||
        (s['badge'] is String &&
            RegExp(r'^[0-9A-F]{14}$').hasMatch(s['badge'] as String)),
  );
  for (final key in [
    'checkedIn',
    'early',
    'earlyUnlocked',
    'tutorial',
    'photo',
  ]) {
    _require(s[key] is bool);
  }
  if (s.containsKey('role')) {
    _require(AccountRole.values.any((r) => r.name == s['role']));
    _require(s.containsKey('boothId'));
    _require(
      s['role'] == AccountRole.booth.name
          ? ['booth-1', 'booth-2', 'booth-3'].contains(s['boothId'])
          : s['boothId'] == null,
    );
  } else {
    _require(s['staff'] is bool);
  }
  if (s.containsKey('recipients')) {
    for (final entry in _object(s['recipients']).entries) {
      _require(
        List.generate(
          18,
          (i) => GameEngine.playerUid(i + 1),
        ).contains(entry.key),
      );
      final progress = _object(entry.value);
      for (final key in ['boothVisited', 'boothCompleted']) {
        _require(_strings(progress[key]));
        _require(
          (progress[key] as List).every(
            (id) => ['booth-1', 'booth-2', 'booth-3'].contains(id),
          ),
        );
      }
      _require(_integer(progress['hintCredits']));
      _require(_integer(progress['hintRemainder']));
    }
  }
  _require(_integer(s['phase'], 0, 2));
  _require(_hand(s['hand']));
  for (final key in [
    'coins',
    'points',
    'packs',
    'peek',
    'hintCredits',
    'hintRemainder',
    'sequence',
  ]) {
    _require(_integer(s[key]));
  }
  _require(s.containsKey('planet') && _planet(s['planet']));
  _require(_integer(s['style'], -1, 5));
  for (final key in ['tags', 'boothVisited', 'boothCompleted', 'agenda']) {
    _require(_strings(s[key]));
  }
  _require(_list(s['seriesRewards']).every((v) => _integer(v, 0, 5)));
  _require(_list(s['bag']).every((v) => _integer(v, 0, 2)));
  for (final key in ['planets', 'checkpoints']) {
    for (final entry in _object(s[key]).entries) {
      final index = int.tryParse(entry.key);
      _require(
        index != null &&
            _integer(
              index,
              key == 'planets' ? 0 : 1,
              key == 'planets' ? 41 : 42,
            ),
      );
      _require(_date(entry.value));
    }
  }
  for (final key in ['friends', 'bindings']) {
    _require(_object(s[key]).values.every((v) => v is String));
  }
  for (final value in _object(s['hints']).values) {
    _require(value is String || _message(value));
  }
  for (final key in ['stationClaims', 'stationStock']) {
    _require(_object(s[key]).values.every((v) => _integer(v)));
  }
  for (final value in _object(s['stationConfigs']).values) {
    final station = _object(value);
    _require(station['name'] is String && station['open'] is bool);
    _require(_integer(station['packs'], 1) && _integer(station['limit'], 1));
  }
  for (final value in _object(s['opponentHands']).values) {
    _require(_hand(value));
  }
  if (s.containsKey('parameters')) {
    final parameters = _object(s['parameters']);
    _require(parameters.length == GameEngine.defaultParameters.length);
    for (final key in GameEngine.defaultParameters.keys) {
      _require(_integer(parameters[key]));
    }
  }
  for (final value in _list(s['missions'])) {
    final m = _object(value);
    _require(m['tag'] is String && m['category'] is String && m['own'] is bool);
    _require(m.containsKey('completedAt') && _nullableDate(m['completedAt']));
  }
  for (final value in _list(s['players'])) {
    _player(value);
  }
  for (final value in _list(s['ledger'])) {
    final entry = _object(value);
    _require(
      _date(entry['at']) &&
          entry['reason'] is String &&
          entry['detail'] is String,
    );
    _require(entry['coins'] is int);
    _require(
      !entry.containsKey('args') || entry['args'] is Map<String, dynamic>,
    );
  }
  _require(s.containsKey('battle') && s.containsKey('cooldown'));
  if (s['battle'] != null) _battle(s['battle']);
  _require(_nullableDate(s['cooldown']));
  for (final value in _list(s['history'])) {
    final record = _object(value);
    _battle(record['battle']);
    _require(
      _date(record['at']) &&
          _integer(record['points']) &&
          _integer(record['coins']),
    );
    _require(
      record.containsKey('reward') &&
          (record['reward'] == null || _integer(record['reward'], 0, 3)),
    );
  }
  for (final value in _object(s['deliveries']).values) {
    final delivery = _object(value);
    _require(_integer(delivery['amount'], 1) && delivery['reason'] is String);
  }
  for (final value in _object(s['scans']).values) {
    final scan = _object(value);
    for (final key in ['source', 'kind']) {
      _require(scan[key] is String);
    }
    if (scan.containsKey('mode')) {
      _require(ScannerMode.values.any((m) => m.name == scan['mode']));
      _require(
        scan['mode'] == ScannerMode.booth.name
            ? ['booth-1', 'booth-2', 'booth-3'].contains(scan['assignedBooth'])
            : scan['assignedBooth'] == null,
      );
      _require(scan['repeated'] is bool);
      _require(
        scan['targetPlayerId'] == null || scan['targetPlayerId'] is String,
      );
      if (scan['station'] != null) {
        final station = _object(scan['station']);
        _require(station['id'] is String && station['name'] is String);
        _require(station['open'] is bool);
        for (final key in ['packs', 'limit', 'remaining']) {
          _require(_integer(station[key]));
        }
      }
    }
    _require(scan['message'] is String || _message(scan['message']));
    _require(
      scan.containsKey('uid') && (scan['uid'] == null || scan['uid'] is String),
    );
    _require(scan['openPacks'] is bool);
    _require(scan.containsKey('player') && scan.containsKey('booth'));
    if (scan['player'] != null) _player(scan['player']);
    if (scan['booth'] != null) {
      final booth = _object(scan['booth']);
      _require(
        booth['id'] is String &&
            booth['name'] is String &&
            booth['url'] is String,
      );
      _require(booth['visited'] is bool && booth['completed'] is bool);
    }
  }
}

bool _message(dynamic value) =>
    value is Map && value['code'] is String && value['args'] is Map;
