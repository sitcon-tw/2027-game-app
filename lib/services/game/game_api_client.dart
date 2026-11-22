import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:sitcon_backend/game/game_service.dart';

import '../preferences/test_server_settings.dart';

class GameApiException implements Exception, GameLocalizedError {
  const GameApiException(this.code, this.localizedMessage, this.status);
  final String code;
  @override
  final GameMessage localizedMessage;
  final int status;
  @override
  String toString() => 'GameApiException($status)';
}

class GameApiClient {
  GameApiClient(String baseUrl)
    : origin = testServerOrigin(baseUrl) ??
          (throw GameArgumentError(const GameMessage('invalidApiOrigin')));

  final Uri origin;
  HttpClient? _client;

  void requireSecureTransport() {
    if (origin.scheme != 'https' &&
        origin.host != '127.0.0.1' &&
        origin.host != 'localhost' &&
        origin.host != '::1') {
      throw GameArgumentError(const GameMessage('deviceSecureOriginRequired'));
    }
  }

  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    String? bearer,
    Map<String, dynamic>? body,
  }) async {
    if (bearer != null) requireSecureTransport();
    try {
      final url = origin.resolve(path);
      if (url.origin != origin.origin) {
        throw GameArgumentError(const GameMessage('invalidApiOrigin'));
      }
      final client = _client ??= HttpClient()
        ..connectionTimeout = const Duration(seconds: 5);
      if (bearer != null) client.findProxy = (_) => 'DIRECT';
      final request = await client.openUrl(method, url)
          .timeout(const Duration(seconds: 5));
      request.followRedirects = false;
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (bearer != null) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearer');
      }
      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode(body));
      }
      final response = await request.close().timeout(const Duration(seconds: 10));
      final status = response.statusCode;
      if (status >= 300 && status < 400) {
        await response.drain<void>().timeout(const Duration(seconds: 10));
        throw GameStateError(const GameMessage('serverFailure'));
      }
      if (status == HttpStatus.unauthorized && bearer != null) {
        await response.drain<void>().timeout(const Duration(seconds: 10));
        throw const GameApiException(
          'device_session_required',
          GameMessage('deviceSessionRequired'),
          HttpStatus.unauthorized,
        );
      }
      final raw = await response.transform(utf8.decoder).join()
          .timeout(const Duration(seconds: 10));
      final decoded = (jsonDecode(raw) as Map).cast<String, dynamic>();
      if (status < 200 || status >= 300) {
        final error = (decoded['error'] as Map?) ?? const {};
        throw GameApiException(
          error['code'] as String? ?? 'http_error',
          error['message'] is Map
              ? GameMessage.fromJson((error['message'] as Map).cast<String, dynamic>())
              : GameMessage(status == 401 ? 'deviceSessionRequired' : 'serverFailure'),
          status,
        );
      }
      return (decoded['data'] as Map).cast<String, dynamic>();
    } on TimeoutException {
      throw GameStateError(const GameMessage('networkTimeout'));
    } on IOException {
      throw GameStateError(const GameMessage('networkUnavailable'));
    } on FormatException {
      throw GameStateError(const GameMessage('invalidResponse'));
    } on TypeError {
      throw GameStateError(const GameMessage('invalidResponse'));
    } on ArgumentError catch (error) {
      if (error is GameLocalizedError) rethrow;
      throw GameStateError(const GameMessage('invalidResponse'));
    }
  }

  void close() => _client?.close(force: true);
}

String requireApiString(Map<String, dynamic> data, String field) {
  final value = data[field];
  if (value is! String || value.isEmpty) {
    throw GameStateError(const GameMessage('invalidResponse'));
  }
  return value;
}
