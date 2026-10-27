import 'dart:convert';

import 'package:ai_talk_test/core/network/api_end_point.dart';
import 'package:ai_talk_test/core/network/api_exceptions.dart';
import 'package:ai_talk_test/core/network/cabinet_client.dart';
import 'package:http/http.dart' as http;

class HttpApi {
  HttpApi({http.Client? client, http.Client? cabinetClient})
    : _client = client ?? http.Client(),
      _cabinetClient = cabinetClient ?? client ?? createCabinetClient();

  final http.Client _client;
  final http.Client _cabinetClient;

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  Future<Map<String, dynamic>> postObject(
    Uri uri,
    Map<String, dynamic> body, {
    Set<int> successCodes = const {200},
  }) async {
    final response = await _postJson(uri, body);
    return _decodeObject(response, successCodes: successCodes);
  }

  Future<String> postText(Uri uri, Map<String, dynamic> body) async {
    final response = await _postJson(uri, body);
    return _decodeText(response);
  }

  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) {
    return _client.get(uri, headers: headers);
  }

  Future<http.Response> postCabinet({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
  }) {
    return _cabinetClient.post(uri, headers: headers, body: body);
  }

  Uri baseUri(String path) => _uri(ApiEndPoint.baseUrl, path);

  Uri clientUri(String path) => _uri(ApiEndPoint.clientApiBaseUrl, path);

  Uri partnerUri(String path) => _uri(ApiEndPoint.partnerApiBaseUrl, path);

  dynamic decodeBody(String body) => _decodeBody(body);

  String errorMessage(http.Response response) {
    return _errorMessage(response, _tryDecode(response.body));
  }

  Future<http.Response> _postJson(Uri uri, Map<String, dynamic> body) {
    return _client.post(uri, headers: _headers, body: jsonEncode(body));
  }

  Uri _uri(String base, String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalized');
  }

  Map<String, dynamic> _decodeObject(
    http.Response response, {
    Set<int> successCodes = const {200},
  }) {
    final decoded = _tryDecode(response.body);
    if (successCodes.contains(response.statusCode) && decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    throw ApiException(
      _errorMessage(response, decoded),
      statusCode: response.statusCode,
    );
  }

  String _decodeText(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _errorMessage(response, _tryDecode(response.body)),
        statusCode: response.statusCode,
      );
    }

    final body = response.body.trim();
    final decoded = _tryDecode(body);
    if (decoded is String) return decoded.trim();
    return body;
  }

  dynamic _decodeBody(String body) {
    final decoded = _tryDecode(body);
    if (decoded is String) {
      final nested = _tryDecode(decoded);
      if (nested != null) return nested;
    }
    return decoded;
  }

  dynamic _tryDecode(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String _errorMessage(http.Response response, dynamic decoded) {
    if (decoded is String && decoded.trim().isNotEmpty) return decoded.trim();
    if (decoded is Map) {
      final errors = decoded['errors'];
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty && value.first is String) {
            final text = (value.first as String).trim();
            if (text.isNotEmpty) return text;
          }
        }
      }
      final title = decoded['title'];
      if (title is String && title.trim().isNotEmpty) return title.trim();
      if (decoded['error'] is Map) {
        final message = decoded['error']['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    }
    final plain = response.body.trim();
    if (plain.isNotEmpty && decoded == null && !plain.startsWith('<')) {
      return plain;
    }
    return 'Request failed (${response.statusCode}).';
  }

  void close() {
    _client.close();
    if (!identical(_cabinetClient, _client)) {
      _cabinetClient.close();
    }
  }
}
