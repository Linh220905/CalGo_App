import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class AuthService {
  static const _primaryIosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );
  static const _legacyIosOptions = IOSOptions(
    accessibility: KeychainAccessibility.unlocked,
  );
  static const List<IOSOptions> _allIosOptions = [
    _primaryIosOptions,
    _legacyIosOptions,
    IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
    IOSOptions(accessibility: KeychainAccessibility.unlocked_this_device),
    IOSOptions(accessibility: KeychainAccessibility.passcode),
  ];

  final ApiService _api;
  final FlutterSecureStorage _storage;
  static const _tokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  AuthService(this._api, {FlutterSecureStorage? storage})
    : _storage =
          storage ?? const FlutterSecureStorage(iOptions: _primaryIosOptions);

  ApiService get api => _api;

  bool _isInvalidSession(Object error) {
    return error is ApiException &&
        (error.statusCode == 401 || error.statusCode == 403);
  }

  Future<String?> _readKey(String key) async {
    try {
      final primary = await _storage.read(key: key, iOptions: _primaryIosOptions);
      if (primary != null && primary.isNotEmpty) {
        return primary;
      }
    } on PlatformException {
      // Fall through to legacy Keychain accessibility lookup.
    }

    try {
      final legacy = await _storage.read(key: key, iOptions: _legacyIosOptions);
      if (legacy != null && legacy.isNotEmpty) {
        // Migrate old `unlocked` Keychain item to `first_unlock` so upgraded
        // iOS users keep their session and never hit errSecDuplicateItem (-25299).
        try {
          await _deleteKeyEverywhere(key);
          await _storage.write(
            key: key,
            value: legacy,
            iOptions: _primaryIosOptions,
          );
        } catch (_) {}
        return legacy;
      }
    } on PlatformException {
      // Ignore unreadable legacy items.
    }
    return null;
  }

  Future<void> _writeKey(String key, String value) async {
    try {
      await _storage.write(
        key: key,
        value: value,
        iOptions: _primaryIosOptions,
      );
    } on PlatformException {
      // Upgrading iOS Keychain accessibility from default `unlocked` to
      // `first_unlock` throws errSecDuplicateItem (-25299) when an older item
      // exists under the same key. Remove across all accessibility levels and
      // write cleanly under `first_unlock`.
      await _deleteKeyEverywhere(key);
      await _storage.write(
        key: key,
        value: value,
        iOptions: _primaryIosOptions,
      );
    }
  }

  Future<void> _deleteKeyEverywhere(String key) async {
    for (final iosOptions in _allIosOptions) {
      try {
        await _storage.delete(key: key, iOptions: iosOptions);
      } catch (_) {}
    }
  }

  Future<String?> getToken() async {
    return _readKey(_tokenKey);
  }

  Future<void> _saveTokens(String accessToken, {String? refreshToken}) async {
    await _writeKey(_tokenKey, accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _writeKey(_refreshTokenKey, refreshToken);
    }
    _api.setToken(accessToken);
  }

  Future<void> clearAllStorage() async {
    for (final iosOptions in _allIosOptions) {
      try {
        await _storage.deleteAll(iOptions: iosOptions);
      } catch (_) {}
    }
    _api.setToken(null);
  }

  Future<void> _clearToken() async {
    await _deleteKeyEverywhere(_tokenKey);
    await _deleteKeyEverywhere(_refreshTokenKey);
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
    final user = await _api
        .get(
          '/users/me',
          caller: 'AuthService._saveSessionAndGetUser',
        )
        .timeout(const Duration(seconds: 15));
    return user as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    return _saveSessionAndGetUser(
      _api.post('/auth/google', body: {'id_token': idToken}),
    );
  }

  Future<Map<String, dynamic>> loginWithApple({
    required String identityToken,
    required String authorizationCode,
    String? firstName,
    String? lastName,
  }) async {
    return _saveSessionAndGetUser(
      _api.post(
        '/auth/apple',
        body: {
          'identity_token': identityToken,
          'authorization_code': authorizationCode,
          if (firstName != null && firstName.isNotEmpty)
            'first_name': firstName,
          if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
        },
      ),
    );
  }

  Future<Map<String, dynamic>> loginWithEmail(
    String email,
    String password,
  ) async {
    return _saveSessionAndGetUser(
      _api.post('/auth/login', body: {'email': email, 'password': password}),
    );
  }

  Future<void> logout() async {
    final refreshToken = await _readKey(_refreshTokenKey);
    try {
      await _api.post(
        '/auth/logout',
        body: refreshToken == null || refreshToken.isEmpty
            ? null
            : {'refresh_token': refreshToken},
      );
    } catch (_) {}
    await _clearToken();
  }

  Future<void> deleteAccount() async {
    await _api.delete('/users/me');
    await _clearToken();
  }

  Future<bool>? _inFlightRefresh;

  /// Silently refreshes the access token using the stored refresh token.
  /// Does NOT update user state or notify listeners — it only rotates the
  /// in-memory token so the next API call succeeds.
  /// Returns true if a new token was obtained, false otherwise.
  Future<bool> refreshTokenSilently() async {
    if (_inFlightRefresh != null) {
      return await _inFlightRefresh!;
    }

    _inFlightRefresh = () async {
      final refreshToken = await _readKey(_refreshTokenKey);
      if (refreshToken == null || refreshToken.isEmpty) return false;
      try {
        final res = await _api.post(
          '/auth/refresh',
          body: {'refresh_token': refreshToken},
        );
        if (res is! Map<String, dynamic>) return false;
        final accessToken =
            res['access_token'] as String? ?? res['accessToken'] as String?;
        if (accessToken == null || accessToken.isEmpty) return false;
        await _saveTokens(
          accessToken,
          refreshToken:
              res['refresh_token'] as String? ??
              res['refreshToken'] as String? ??
              refreshToken,
        );
        return true;
      } catch (error) {
        if (_isInvalidSession(error)) {
          await _clearToken();
        }
        return false;
      }
    }();

    try {
      return await _inFlightRefresh!;
    } finally {
      _inFlightRefresh = null;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return null;
    _api.setToken(token);
    try {
      final res = await _api.get(
        '/users/me',
        caller: 'AuthService.getCurrentUser',
      );
      if (res is Map<String, dynamic>) {
        return res;
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> tryRestore() async {
    final token = await getToken();
    final refreshToken = await _readKey(_refreshTokenKey);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        // Rotate on every cold start. This keeps an actively used mobile
        // session alive without relying on the one-hour access token.
        final res = await _api.post(
          '/auth/refresh',
          body: {'refresh_token': refreshToken},
        );
        if (res is! Map<String, dynamic>) {
          throw ApiException(
            statusCode: 500,
            message: 'Invalid refresh response',
          );
        }
        final accessToken =
            res['access_token'] as String? ?? res['accessToken'] as String?;
        if (accessToken == null || accessToken.isEmpty) {
          throw ApiException(
            statusCode: 500,
            message: 'Missing refreshed token',
          );
        }
        await _saveTokens(
          accessToken,
          refreshToken:
              res['refresh_token'] as String? ??
              res['refreshToken'] as String? ??
              refreshToken,
        );
        return await _api.get('/users/me', caller: 'AuthService.tryRestore')
            as Map<String, dynamic>;
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
        return await _api.get(
              '/users/me',
              caller: 'AuthService.tryRestoreLegacy',
            )
            as Map<String, dynamic>;
      } catch (error) {
        if (_isInvalidSession(error)) {
          await _clearToken();
        }
      }
    }
    return null;
  }
}
