import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../models/onboarding_data.dart';
import '../../../widgets/premium_ui.dart';

class ActivityStep extends StatelessWidget {
  const ActivityStep({super.key});

  static const _items = <(String, String, String, ActivityLevel)>[
    (
      '🪑',
      'Ít vận động',
      'Ngồi làm việc, ít di chuyển',
      ActivityLevel.sedentary
    ),
    ('🚶', 'Đi bộ nhẹ', 'Đi lại nhẹ 1-2 lần/tuần', ActivityLevel.light),
    ('🏃', 'Tập 1-3 buổi', 'Thể dục 1-3 ngày/tuần', ActivityLevel.moderate),
    ('🏋️', 'Tập 4-5 buổi', 'Thể dục 4-5 ngày/tuần', ActivityLevel.active),
    (
      '🔥',
      'Tập hằng ngày',
      'Vận động nặng hằng ngày',
      ActivityLevel.veryActive
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: SingleChildScrollView(
            child: Column(children: [
              const SizedBox(height: 16),
              const Text('Mức vận động của bạn?',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111))),
              const SizedBox(height: 8),
              const Text('Ảnh hưởng đến lượng calo tiêu thụ',
                  style: TextStyle(fontSize: 15, color: Color(0xFF7A7A7A))),
              const SizedBox(height: 24),
              Consumer<OnboardingProvider>(
                builder: (context, provider, _) => ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: _items.map((e) {
                    final (emoji, label, desc, level) = e;
                    final sel = provider.data.activityLevel == level;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OptionCard(
                          title: label,
                          subtitle: desc,
                          selected: sel,
                          onTap: () {
                            provider.setActivityLevel(level);
                            provider.nextStep();
                          }),
                    );
                  }).toList(),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
