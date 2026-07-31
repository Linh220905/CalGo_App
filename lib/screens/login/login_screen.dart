import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/social_auth_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _completeLoginAndNavigate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (context.mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo & Title
              Column(
                children: [
                  Image.asset(
                    'assets/images/calgo_logo.png',
                    height: 110,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        size: 48,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Chào mừng đến với CalGo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Đăng nhập để đồng bộ dữ liệu dinh dưỡng của bạn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 3),

              // Auth Buttons
              SocialAuthButton(
                type: SocialAuthType.google,
                label: 'Đăng nhập với Google',
                isLoading: auth.loading,
                onTap: () async {
                  final success =
                      await context.read<AuthProvider>().signInWithGoogle();
                  if (success && context.mounted) {
                    await _completeLoginAndNavigate(context);
                  } else if (auth.error != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đăng nhập thất bại: ${auth.error}'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 14),

              SocialAuthButton(
                type: SocialAuthType.apple,
                label: 'Đăng nhập với Apple',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng Đăng nhập Apple sắp ra mắt!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () => _completeLoginAndNavigate(context),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text(
                  'Tiếp tục với tư cách Khách',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
