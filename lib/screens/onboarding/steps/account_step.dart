import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/home_provider.dart';
import '../../../widgets/social_auth_button.dart';

class AccountStep extends StatelessWidget {
  const AccountStep({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<OnboardingProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Image.asset(
                'assets/images/calgo_logo.png',
                height: 100,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    size: 40,
                    color: Color(0xFF22C55E),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Animate(
                effects: const [
                  FadeEffect(duration: Duration(milliseconds: 600)),
                  SlideEffect(
                    begin: Offset(0, -12),
                    end: Offset.zero,
                    duration: Duration(milliseconds: 600),
                  ),
                ],
                child: const Text(
                  'Tạo tài khoản để\nđồng bộ dữ liệu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    height: 1.3,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bảo mật thông tin & đồng bộ tiến trình cá nhân',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const Spacer(flex: 2),
              SocialAuthButton(
                type: SocialAuthType.google,
                label: 'Tiếp tục với Google',
                isLoading: auth.loading,
                onTap: () async {
                  final authProvider = context.read<AuthProvider>();
                  final homeProvider = context.read<HomeProvider>();
                  final success = await authProvider.signInWithGoogle();
                  if (success && context.mounted) {
                    await provider.setAccountMethod('google');
                    final saved = await provider.completeOnboarding(
                      authProvider: authProvider,
                      homeProvider: homeProvider,
                    );
                    if (saved && context.mounted) {
                      await homeProvider.loadToday(forceRefresh: true);
                      context.go('/home');
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            provider.error ??
                                'Không thể lưu mục tiêu dinh dưỡng. Vui lòng thử lại.',
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  } else if (context.mounted && auth.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Đăng nhập Google thất bại: ${auth.error}'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 14),
              SocialAuthButton(
                type: SocialAuthType.apple,
                label: 'Tiếp tục với Apple',
                onTap: () async {
                  // Apple Sign-In is not wired to the backend yet. Previously
                  // this button marked onboarding complete without an account,
                  // so the nutrition profile was never saved.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Đăng nhập Apple đang được hoàn thiện. Vui lòng dùng Google.',
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              const Text(
                'Dữ liệu của bạn được bảo mật tuyệt đối',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
