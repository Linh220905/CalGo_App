import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../services/analytics_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/home_provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../widgets/social_auth_button.dart';

class AccountStep extends StatefulWidget {
  const AccountStep({super.key});

  @override
  State<AccountStep> createState() => _AccountStepState();
}

class _AccountStepState extends State<AccountStep> {
  int _logoTapCount = 0;
  DateTime? _lastLogoTap;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(context.read<AnalyticsService>().trackAuthScreenView());
    });
  }

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
                          final onboarding = context.read<OnboardingProvider>();
                          final home = context.read<HomeProvider>();
                          await onboarding.setAccountMethod('email');
                          final hasPremium = auth.user?.hasPremiumAccess ?? false;
                          if (hasPremium) {
                            await onboarding.completeOnboarding(
                              authProvider: auth,
                              homeProvider: home,
                            );
                            if (context.mounted) {
                              await home.loadToday(forceRefresh: true);
                              if (context.mounted) context.go('/home');
                            }
                          } else {
                            await onboarding.saveProfileToBackend(authProvider: auth);
                            onboarding.nextStep();
                          }
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

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
                            GestureDetector(
                              onTap: () => _onLogoTap(context),
                              behavior: HitTestBehavior.opaque,
                              child: Image.asset(
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
                isLoading: auth.googleLoading,
                onTap: () async {
                  final authProvider = context.read<AuthProvider>();
                  final analytics = context.read<AnalyticsService>();
                  final success = await authProvider.signInWithGoogle();
                  if (success && context.mounted) {
                    unawaited(analytics.trackLoginSuccess(method: 'google'));
                    // Sync pending anonymous purchases made before login (background)
                    unawaited(context.read<PaymentProvider>().retryPendingPurchaseVerification());
                    await provider.setAccountMethod('google');
                    if (context.mounted) {
                      final hasPremium = authProvider.user?.hasPremiumAccess ?? false;
                      if (hasPremium) {
                        final home = context.read<HomeProvider>();
                        await provider.completeOnboarding(
                          authProvider: authProvider,
                          homeProvider: home,
                        );
                        if (context.mounted) {
                          await home.loadToday(forceRefresh: true);
                          if (context.mounted) context.go('/home');
                        }
                      } else {
                        // Save user profile data to backend without prematurely marking onboarding as completed
                        await provider.saveProfileToBackend(authProvider: authProvider);
                        provider.nextStep(); // Advance to Step 17 (PremiumPaywallStep)
                      }
                    }
                  } else if (context.mounted && authProvider.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(s.googleSignInFailed(authProvider.error ?? '')),
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
                isLoading: auth.appleLoading,
                onTap: () async {
                  final authProvider = context.read<AuthProvider>();
                  final onboarding = context.read<OnboardingProvider>();
                  final analytics = context.read<AnalyticsService>();
                  final success = await authProvider.signInWithApple();
                  if (success && context.mounted) {
                    unawaited(analytics.trackLoginSuccess(method: 'apple'));
                    // Sync pending anonymous purchases made before login (background)
                    unawaited(context.read<PaymentProvider>().retryPendingPurchaseVerification());
                    await onboarding.setAccountMethod('apple');
                    if (context.mounted) {
                      final hasPremium = authProvider.user?.hasPremiumAccess ?? false;
                      if (hasPremium) {
                        final home = context.read<HomeProvider>();
                        await onboarding.completeOnboarding(
                          authProvider: authProvider,
                          homeProvider: home,
                        );
                        if (context.mounted) {
                          await home.loadToday(forceRefresh: true);
                          if (context.mounted) context.go('/home');
                        }
                      } else {
                        // Save user profile data to backend without prematurely marking onboarding as completed
                        await onboarding.saveProfileToBackend(authProvider: authProvider);
                        onboarding.nextStep(); // Advance to Step 17 (PremiumPaywallStep)
                      }
                    }
                  } else if (authProvider.error != null && context.mounted) {
                    final msg = authProvider.error == 'apple_auth_error'
                        ? s.appleSignInFailed
                        : s.loginFailed(authProvider.error ?? '');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(msg),
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
