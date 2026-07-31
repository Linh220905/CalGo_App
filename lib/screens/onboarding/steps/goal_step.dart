import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../models/onboarding_data.dart';

class GoalStep extends StatelessWidget {
  const GoalStep({super.key});

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
              Image.asset(
                'assets/images/apple_mascot/apple_thinking.png',
                height: 105,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
              const Text('Mục tiêu của bạn?',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111))),
              const SizedBox(height: 4),
              const Text('Chọn mục tiêu phù hợp nhất',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF71717A))),
              const SizedBox(height: 24),
              Consumer<OnboardingProvider>(
                builder: (context, provider, _) => Column(
                  children: [
                    _GoalCard(
                      icon: Icons.trending_down_rounded,
                      iconColor: const Color(0xFFFF6B35),
                      label: 'Giảm cân',
                      desc: 'Đốt mỡ hiệu quả, săn chắc cơ thể',
                      selected: provider.data.goalType == GoalType.lose,
                      onTap: () => provider.setGoalType(GoalType.lose),
                    ),
                    const SizedBox(height: 12),
                    _GoalCard(
                      icon: Icons.fitness_center_rounded,
                      iconColor: const Color(0xFF007AFF),
                      label: 'Tăng cơ',
                      desc: 'Tăng cơ, tăng sức mạnh',
                      selected: provider.data.goalType == GoalType.gain,
                      onTap: () => provider.setGoalType(GoalType.gain),
                    ),
                    const SizedBox(height: 12),
                    _GoalCard(
                      icon: Icons.balance_rounded,
                      iconColor: const Color(0xFF34C759),
                      label: 'Duy trì',
                      desc: 'Giữ vóc dáng cân đối',
                      selected: provider.data.goalType == GoalType.maintain,
                      onTap: () => provider.setGoalType(GoalType.maintain),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: provider.data.goalType != null
                            ? () {
                                provider.nextStep();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111111),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: const Color(0xFFECECEC),
                          disabledForegroundColor: const Color(0xFFAAAAAA),
                        ),
                        child: const Text('Tiếp theo',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String desc;
  final bool selected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected ? const Color(0xFFFAFAFA) : const Color(0xFFFFFFFF),
          border: Border.all(
            color: selected ? const Color(0xFF111111) : const Color(0xFFECECEC),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: selected
                  ? iconColor.withOpacity(0.12)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                size: 20,
                color: selected ? iconColor : const Color(0xFF7A7A7A)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  )),
              const SizedBox(height: 2),
              Text(desc,
                  style:
                      const TextStyle(fontSize: 13, color: Color(0xFF7A7A7A))),
            ]),
          ),
          if (selected)
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF111111),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 15),
            ),
        ]),
      ),
    );
  }
}
