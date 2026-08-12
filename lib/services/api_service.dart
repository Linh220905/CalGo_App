import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  String? _accessToken;
  int _authScope = 0;
  final http.Client _client = http.Client();
  final Map<String, Future<dynamic>> _inFlightGets = {};

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  void setToken(String? token) {
    if (_accessToken != token) {
      _authScope++;
    }
    _accessToken = token;
  }

  /// Changes whenever the signed-in account changes. Services use this to
  /// keep short-lived caches from ever crossing account boundaries.
  int get authScope => _authScope;
  bool get hasAccessToken => _accessToken?.trim().isNotEmpty == true;

  Future<dynamic> get(String path) async {
    final requestKey = '${_accessToken ?? ''}\n$path';
    return _inFlightGets.putIfAbsent(requestKey, () async {
      try {
        final response = await _client
            .get(
              Uri.parse('${ApiConfig.baseUrl}$path'),
              headers: _headers(),
            )
            .timeout(ApiConfig.timeout);
        return _handleResponse(response);
      } finally {
        _inFlightGets.remove(requestKey);
      }
    });
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: _headers(),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConfig.timeout);
    return _handleResponse(response);
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    final response = await _client
        .patch(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: _headers(),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConfig.timeout);
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await _client
        .delete(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: _headers(),
        )
        .timeout(ApiConfig.timeout);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        response.body.trim().isEmpty) {
      return null;
    }

    dynamic body;
    try {
      body = jsonDecode(response.body);
    } on FormatException {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body.isEmpty
            ? 'Server returned an empty response'
            : response.body,
      );
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: body is Map
          ? (body['detail'] ??
                  body['message'] ??
                  body['error'] ??
                  'Unknown error')
              .toString()
          : 'Unknown error',
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
