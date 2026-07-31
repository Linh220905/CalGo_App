import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _tokenKey = 'access_token';

  AuthService(this._api);

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> _saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    _api.setToken(token);
  }

  Future<void> _clearToken() async {
    await _storage.delete(key: _tokenKey);
    _api.setToken(null);
  }

  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    final res = await _api.post('/auth/google', body: {
      'id_token': idToken,
    });
    final token =
        res['access_token'] as String? ?? res['accessToken'] as String?;
    if (token != null) {
      await _saveToken(token);
    }
    final user = await _api.get('/users/me');
    return user as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> loginWithDevEmail(String email) async {
    final res = await _api.post('/auth/dev-login', body: {
      'email': email,
    });
    final token =
        res['access_token'] as String? ?? res['accessToken'] as String?;
    if (token != null) {
      await _saveToken(token);
    }
    final user = await _api.get('/users/me');
    return user as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> loginWithEmail(
      String email, String password) async {
    final res = await _api.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    final token =
        res['access_token'] as String? ?? res['accessToken'] as String?;
    if (token != null) {
      await _saveToken(token);
    }
    final user = await _api.get('/users/me');
    return user as Map<String, dynamic>;
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    await _clearToken();
  }

  Future<Map<String, dynamic>?> tryRestore() async {
    final token = await getToken();
    if (token == null) return null;
    _api.setToken(token);
    try {
      return await _api.get('/users/me') as Map<String, dynamic>;
    } catch (_) {
      await _clearToken();
      return null;
    }
  }
}
