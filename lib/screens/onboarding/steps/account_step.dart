import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/home_provider.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../widgets/social_auth_button.dart';

class AccountStep extends StatelessWidget {
  const AccountStep({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<OnboardingProvider>();
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/calgo_logo_wordmark.png',
                              height: 100,
                              errorBuilder: (_, __, ___) => Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF22C55E).withOpacity(0.1),
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
                                FadeEffect(
                                  duration: Duration(milliseconds: 600),
                                ),
                                SlideEffect(
                                  begin: Offset(0, -12),
                                  end: Offset.zero,
                                  duration: Duration(milliseconds: 600),
                                ),
                              ],
                              child: Text(
                                s.accountStepTitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                  height: 1.3,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              s.accountStepSubtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SocialAuthButton(
                type: SocialAuthType.google,
                label: s.continueWithGoogle,
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
                      if (context.mounted) context.go('/home');
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            provider.error == 'onboardingSaveNetworkFailed'
                                ? s.onboardingSaveNetworkFailed
                                : s.onboardingSaveFailed,
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  } else if (context.mounted && auth.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(s.googleSignInFailed(auth.error ?? '')),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 14),
              SocialAuthButton(
                type: SocialAuthType.apple,
                label: s.continueWithApple,
                isLoading: auth.loading,
                onTap: () async {
                  final authProvider = context.read<AuthProvider>();
                  final success = await authProvider.signInWithApple();
                  if (success && context.mounted) {
                    await context.read<OnboardingProvider>().completeOnboarding();
                    if (context.mounted) {
                      context.go('/home');
                    }
                  } else if (authProvider.error != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(s.loginFailed(authProvider.error ?? '')),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              Text(
                s.dataPrivacyNote,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
