import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/social_auth_button.dart';
import '../../widgets/language_selector.dart';
import '../../providers/app_settings_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _completeLoginAndNavigate(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      return;
    }
    if (context.mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final s = context.watch<AppSettingsProvider>().strings;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 620;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    // ── Top Header Row with Language Selector ──
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          LanguageSelectorButton(isDark: false),
                        ],
                      ),
                    ),

                    SizedBox(height: compact ? 16 : 44),

                    // Logo & Title
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/calgo_logo_wordmark.png',
                          height: compact ? 76 : 110,
                          errorBuilder: (_, __, ___) => Container(
                            width: compact ? 72 : 90,
                            height: compact ? 72 : 90,
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
                        SizedBox(height: compact ? 14 : 24),
                        Text(
                          s.loginTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.loginSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: compact ? 22 : 48),

                    // Auth Buttons
                    SocialAuthButton(
                      type: SocialAuthType.google,
                      label: s.loginGoogle,
                      isLoading: auth.googleLoading,
                      onTap: () async {
                        final success = await context
                            .read<AuthProvider>()
                            .signInWithGoogle();
                        if (success && context.mounted) {
                          await _completeLoginAndNavigate(context);
                        } else if (auth.error != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(s.loginFailed(auth.error ?? '')),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                    ),

                    SizedBox(height: compact ? 10 : 14),

                    SocialAuthButton(
                      type: SocialAuthType.apple,
                      label: s.loginApple,
                      isLoading: auth.appleLoading,
                      onTap: () async {
                        final success = await context
                            .read<AuthProvider>()
                            .signInWithApple();
                        if (success && context.mounted) {
                          await _completeLoginAndNavigate(context);
                        } else if (auth.error != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(s.loginFailed(auth.error ?? '')),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                    ),

                    SizedBox(height: compact ? 8 : 20),

                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(s.loginRequired),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      child: Text(
                        s.loginRequiredButton,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(height: compact ? 8 : 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
