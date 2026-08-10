import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/home_provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../widgets/tao_widget.dart';

class HomeStep extends StatelessWidget {
  const HomeStep({super.key});

  Future<void> _complete(BuildContext context) async {
    final provider = context.read<OnboardingProvider>();
    final s = context.read<AppSettingsProvider>().strings;
    final authProvider = context.read<AuthProvider>();
    final homeProvider = context.read<HomeProvider>();

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
          content: Text(provider.error == 'onboardingSaveNetworkFailed'
              ? s.onboardingSaveNetworkFailed
              : s.onboardingSaveFailed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    const TaoWidget(
                      expression: TaoExpression.happy,
                      size: 120,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      s.firstScanTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      s.firstScanSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF7A7A7A),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        color: Color(0xFF111111),
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.scanLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => _complete(context),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(s.startScanning, maxLines: 1),
                  ),
                ),
              ),
            ),
          ],
          ),
      ),
    );
  }
}
