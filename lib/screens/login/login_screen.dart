import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/social_auth_button.dart';
import '../../widgets/language_selector.dart';
import '../../providers/app_settings_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _logoTapCount = 0;
  DateTime? _lastLogoTap;

  void _onLogoTap(BuildContext context) {
    final now = DateTime.now();
    if (_lastLogoTap == null || now.difference(_lastLogoTap!) > const Duration(seconds: 2)) {
      _logoTapCount = 1;
    } else {
      _logoTapCount++;
    }
    _lastLogoTap = now;

    if (_logoTapCount >= 5) {
      _logoTapCount = 0;
      _showTesterLoginDialog(context);
    }
  }

  void _showTesterLoginDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool loading = false;
    String? errorMsg;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF0F172A)),
              SizedBox(width: 8),
              Text(
                'Tester Login',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Demo / Review account sign in',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              if (errorMsg != null) ...[
                const SizedBox(height: 10),
                Text(
                  errorMsg!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: loading
                  ? null
                  : () async {
                      final email = emailController.text.trim();
                      final pass = passwordController.text;
                      if (email.isEmpty || pass.isEmpty) {
                        setDialogState(() => errorMsg = 'Please enter email & password');
                        return;
                      }
                      setDialogState(() {
                        loading = true;
                        errorMsg = null;
                      });

                      final auth = context.read<AuthProvider>();
                      final success = await auth.loginWithEmail(email, pass);
                      if (!mounted) return;

                      if (success) {
                        if (dialogCtx.mounted) {
                          Navigator.of(dialogCtx).pop();
                        }
                        if (mounted) {
                          final navContext = context;
                          await _completeLoginAndNavigate(navContext);
                        }
                      } else {
                        setDialogState(() {
                          loading = false;
                          errorMsg = auth.error ?? 'Login failed';
                        });
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeLoginAndNavigate(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      return;
    }
    if (context.mounted) {
      if (auth.user?.hasCompletedOnboarding == true) {
        context.go('/home');
      } else {
        context.read<OnboardingProvider>().resetLocalProgressForIncompleteAccount();
        context.go('/onboarding');
      }
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
                        GestureDetector(
                          onTap: () => _onLogoTap(context),
                          behavior: HitTestBehavior.opaque,
                          child: Image.asset(
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
