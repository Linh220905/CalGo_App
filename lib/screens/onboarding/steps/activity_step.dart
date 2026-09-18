import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../models/onboarding_data.dart';
import '../../../widgets/premium_ui.dart';

class ActivityStep extends StatelessWidget {
  const ActivityStep({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;
    final items = <(String, String, String, ActivityLevel)>[
      (
        '🪑',
        s.activitySedentary,
        s.activitySedentaryDesc,
        ActivityLevel.sedentary
      ),
      ('🚶', s.activityLight, s.activityLightDesc, ActivityLevel.light),
      (
        '🏃',
        s.activityModerate,
        s.activityModerateDesc,
        ActivityLevel.moderate
      ),
      ('🏋️', s.activityActive, s.activityActiveDesc, ActivityLevel.active),
      (
        '🔥',
        s.activityVeryActive,
        s.activityVeryActiveDesc,
        ActivityLevel.veryActive
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      s.activityStepTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.activityStepSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF71717A),
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Consumer<OnboardingProvider>(
                      builder: (context, provider, _) => ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: items.map((e) {
                          final (_, label, desc, level) = e;
                          final sel = provider.data.activityLevel == level;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: OptionCard(
                              title: label,
                              subtitle: desc,
                              selected: sel,
                              onTap: () => provider.setActivityLevel(level),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: Consumer<OnboardingProvider>(
                  builder: (context, provider, _) => ElevatedButton(
                    onPressed: provider.data.activityLevel == null
                        ? null
                        : () => provider.nextStep(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: const Color(0xFFECECEC),
                      disabledForegroundColor: const Color(0xFFAAAAAA),
                    ),
                    child: Text(
                      s.nextStepButton,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
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
