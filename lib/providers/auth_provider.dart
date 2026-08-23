import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  User? _user;
  bool _loading = false;
  bool _googleLoading = false;
  bool _appleLoading = false;
  String? _error;
  int _restoreGeneration = 0;

  static const String _googleWebClientId =
      '985323892414-cq0r7jaosveklll3cftiv9gbadqq2eff.apps.googleusercontent.com';
  static const String _googleIosClientId =
      '985323892414-vasqth1jns0c9kb5t0bej7ubgdb4k7sk.apps.googleusercontent.com';

  AuthProvider(ApiService api) : _authService = AuthService(api);

  User? get user => _user;
  bool get loading => _loading;
  bool get googleLoading => _googleLoading;
  bool get appleLoading => _appleLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> tryRestore() async {
    final generation = ++_restoreGeneration;
    _loading = true;
    notifyListeners();
    try {
      final userData = await _authService.tryRestore();
      if (generation != _restoreGeneration) return;
      if (userData != null) {
        _user = User.fromJson(userData);
      } else {
        _user = null;
      }
    } catch (_) {
      if (generation != _restoreGeneration) return;
      // A failed restore is an unauthenticated state, never another user's
      // account or a fabricated local profile.
      _user = null;
    }
    _loading = _googleLoading || _appleLoading;
    notifyListeners();
  }

  void updateUserFromJson(Map<String, dynamic> json) {
    _user = User.fromJson(json);
    notifyListeners();
  }

  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> refreshUser() => tryRestore();

  /// Silently refreshes the access token in the background (no loading state,
  /// no UI change). Used as the ApiService.refreshCallback interceptor so that
  /// any in-flight request that hits a 401 can retry without forcing re-login.
  Future<bool> refreshTokenSilently() => _authService.refreshTokenSilently();

  Future<bool> signInWithGoogle() async {
    _beginSocialLoading('google');
    try {
      final googleSignIn = _googleSignIn();

      final GoogleSignInAccount? account =
          await googleSignIn.signIn().timeout(const Duration(seconds: 45));
      if (account != null) {
        final GoogleSignInAuthentication auth = await account.authentication;
        // The API verifies a Google OpenID Connect ID token. An OAuth access
        // token is not interchangeable and causes the backend to return 401.
        final idToken = auth.idToken;

        if (idToken != null && idToken.isNotEmpty) {
          final userData = await _authService.loginWithGoogle(idToken);
          _user = User.fromJson(userData);
          _error = null;
          return true;
        }
        throw StateError('Google ID token is unavailable');
      }
      return false;
    } catch (e) {
      final errStr = e.toString();
      _error = errStr;
      return false;
    } finally {
      _endSocialLoading('google');
    }
  }

  Future<bool> signInWithApple() async {
    _beginSocialLoading('apple');
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final identityToken = credential.identityToken;
      final authorizationCode = credential.authorizationCode;

      if (identityToken != null && identityToken.isNotEmpty) {
        final userData = await _authService.loginWithApple(
          identityToken: identityToken,
          authorizationCode: authorizationCode,
          firstName: credential.givenName,
          lastName: credential.familyName,
        );
        _user = User.fromJson(userData);
        _error = null;
        return true;
      }
      return false;
    } catch (e) {
      final errStr = e.toString();
      _error = errStr;
      return false;
    } finally {
      _endSocialLoading('apple');
    }
  }

  void _beginSocialLoading(String provider) {
    if (provider == 'google') {
      _googleLoading = true;
    } else {
      _appleLoading = true;
    }
    _loading = true;
    _error = null;
    notifyListeners();
  }

  void _endSocialLoading(String provider) {
    if (provider == 'google') {
      _googleLoading = false;
    } else {
      _appleLoading = false;
    }
    _loading = _googleLoading || _appleLoading;
    notifyListeners();
  }

  Future<bool> loginWithGoogle(String idToken) async {
    try {
      _loading = true;
      notifyListeners();
      final userData = await _authService.loginWithGoogle(idToken);
      _user = User.fromJson(userData);
      _error = null;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    try {
      _loading = true;
      notifyListeners();
      final userData = await _authService.loginWithEmail(email, password);
      _user = User.fromJson(userData);
      _error = null;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    // Clear the plugin's active Google session as well as CalGo's API tokens.
    // Otherwise the next signIn() can silently return the previous Google
    // account instead of opening the account picker.
    _restoreGeneration++;
    await _authService.logout();
    try {
      await _googleSignIn().signOut();
    } catch (_) {
      // API logout still succeeded; a stale Google plugin session must not
      // block leaving the account.
    }
    _user = null;
    _loading = _googleLoading || _appleLoading;
    notifyListeners();
  }

  GoogleSignIn _googleSignIn() => GoogleSignIn(
        // google_sign_in_ios needs both IDs when the project does not ship a
        // GoogleService-Info.plist. Without clientId, serverClientId is not
        // applied and iOS returns a token for the wrong audience.
        clientId: !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
            ? _googleIosClientId
            : null,
        serverClientId: _googleWebClientId,
        scopes: ['email', 'profile'],
      );

  Future<bool> deleteAccount() async {
    try {
      await _authService.deleteAccount();
      _user = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
