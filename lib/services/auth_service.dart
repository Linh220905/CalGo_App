import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  AuthService(this._api);

  bool _isInvalidSession(Object error) {
    return error is ApiException &&
        (error.statusCode == 401 || error.statusCode == 403);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> _saveTokens(
    String accessToken, {
    String? refreshToken,
  }) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
    _api.setToken(accessToken);
  }

  Future<void> _clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    _api.setToken(null);
  }

  Future<Map<String, dynamic>> _saveSessionAndGetUser(
    Future<dynamic> loginRequest,
  ) async {
    final res = await loginRequest;
    if (res is! Map<String, dynamic>) {
      throw ApiException(statusCode: 500, message: 'Invalid login response');
    }
    final accessToken =
        res['access_token'] as String? ?? res['accessToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException(statusCode: 500, message: 'Missing access token');
    }
    await _saveTokens(
      accessToken,
      refreshToken:
          res['refresh_token'] as String? ?? res['refreshToken'] as String?,
    );
    final user = await _api.get('/users/me');
    return user as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    return _saveSessionAndGetUser(_api.post('/auth/google', body: {
      'id_token': idToken,
    }));
  }

  Future<Map<String, dynamic>> loginWithApple({
    required String identityToken,
    required String authorizationCode,
    String? firstName,
    String? lastName,
  }) async {
    return _saveSessionAndGetUser(_api.post('/auth/apple', body: {
      'identity_token': identityToken,
      'authorization_code': authorizationCode,
      if (firstName != null && firstName.isNotEmpty) 'first_name': firstName,
      if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
    }));
  }

  Future<Map<String, dynamic>> loginWithEmail(
      String email, String password) async {
    return _saveSessionAndGetUser(_api.post('/auth/login', body: {
      'email': email,
      'password': password,
    }));
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    await _clearToken();
  }

  Future<void> deleteAccount() async {
    await _api.delete('/users/me');
    await _clearToken();
  }

  Future<Map<String, dynamic>?> tryRestore() async {
    final token = await getToken();
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        // Rotate on every cold start. This keeps an actively used mobile
        // session alive without relying on the one-hour access token.
        final res = await _api.post('/auth/refresh', body: {
          'refresh_token': refreshToken,
        });
        if (res is! Map<String, dynamic>) {
          throw ApiException(
              statusCode: 500, message: 'Invalid refresh response');
        }
        final accessToken =
            res['access_token'] as String? ?? res['accessToken'] as String?;
        if (accessToken == null || accessToken.isEmpty) {
          throw ApiException(
              statusCode: 500, message: 'Missing refreshed token');
        }
        await _saveTokens(
          accessToken,
          refreshToken: res['refresh_token'] as String? ??
              res['refreshToken'] as String? ??
              refreshToken,
        );
        return await _api.get('/users/me') as Map<String, dynamic>;
      } catch (error) {
        // Keep credentials on transient network/server errors so reopening
        // the app can retry. Clear only when the backend explicitly rejects
        // the refresh token.
        if (_isInvalidSession(error)) {
          await _clearToken();
        }
        return null;
      }
    }

    // Session created by an older app version: keep it usable until its
    // access token expires, then require one fresh sign-in.
    if (token != null) {
      _api.setToken(token);
      try {
        return await _api.get('/users/me') as Map<String, dynamic>;
      } catch (error) {
        if (_isInvalidSession(error)) {
          await _clearToken();
        }
      }
    }
    return null;
  }
}
