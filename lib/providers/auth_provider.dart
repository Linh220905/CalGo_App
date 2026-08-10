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
  String? _error;

  static const String _googleWebClientId =
      '985323892414-cq0r7jaosveklll3cftiv9gbadqq2eff.apps.googleusercontent.com';

  AuthProvider(ApiService api) : _authService = AuthService(api);

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> tryRestore() async {
    _loading = true;
    notifyListeners();
    try {
      final userData = await _authService.tryRestore();
      if (userData != null) {
        _user = User.fromJson(userData);
      } else {
        _user = null;
      }
    } catch (_) {
      // A failed restore is an unauthenticated state, never another user's
      // account or a fabricated local profile.
      _user = null;
    }
    _loading = false;
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

  Future<bool> signInWithGoogle() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: _googleWebClientId,
        scopes: ['email', 'profile'],
      );

      // Force Google Account picker modal by signing out local session first
      try {
        await googleSignIn.signOut();
      } catch (_) {}

      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account != null) {
        final GoogleSignInAuthentication auth = await account.authentication;
        final idToken = auth.idToken ?? auth.accessToken;

        if (idToken != null && idToken.isNotEmpty) {
          final userData = await _authService.loginWithGoogle(idToken);
          _user = User.fromJson(userData);
          _error = null;
          _loading = false;
          notifyListeners();
          return true;
        }
      }

      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      final errStr = e.toString();
      _loading = false;
      _error = errStr;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

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
        _loading = false;
        notifyListeners();
        return true;
      }

      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      final errStr = e.toString();
      _loading = false;
      _error = errStr;
      notifyListeners();
      return false;
    }
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
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

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
