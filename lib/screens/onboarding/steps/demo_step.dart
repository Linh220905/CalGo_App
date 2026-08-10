import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/app_settings_provider.dart';

class DemoStep extends StatelessWidget {
  const DemoStep({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Animate(
                    effects: const [
                      FadeEffect(duration: Duration(milliseconds: 600)),
                    ],
                    child: Text(
                      s.demoStepTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Demo video placeholder
                  Animate(
                    effects: const [
                      FadeEffect(
                        duration: Duration(milliseconds: 600),
                        delay: Duration(milliseconds: 200),
                      ),
                    ],
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 400),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_outline_rounded,
                          color: Color(0xFFCCCCCC),
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
              child: Animate(
                effects: const [
                  FadeEffect(
                    duration: Duration(milliseconds: 600),
                    delay: Duration(milliseconds: 400),
                  ),
                ],
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () =>
                        context.read<OnboardingProvider>().nextStep(),
                    child: Text(
                      s.nextStepButton,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
