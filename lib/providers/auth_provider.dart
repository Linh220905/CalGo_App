import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  Future<bool> loginWithDevEmail(String email) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      final userData = await _authService.loginWithDevEmail(email);
      _user = User.fromJson(userData);
      _error = null;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Khi không có backend server chạy local, tự động mở phiên Dev làm việc
      _user = User(
        id: 'dev_user_01',
        email: email.isNotEmpty ? email : 'dev@calgo.app',
        name: email.split('@').first,
        credits: 20,
        subscriptionTier: 'pro',
      );
      _error = null;
      _loading = false;
      notifyListeners();
      return true;
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
}
