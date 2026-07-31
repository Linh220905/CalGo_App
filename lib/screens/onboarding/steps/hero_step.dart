import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../theme/app_theme.dart';

class HeroStep extends StatelessWidget {
  const HeroStep({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),

            // ── Welcome header ──
            Column(
              children: [
                Text(
                  'Chào mừng đến với',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Image.asset(
                  'assets/images/CalGo.png',
                  height: 68,
                  fit: BoxFit.contain,
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 350.ms)
                .slideY(begin: -8, end: 0, duration: 350.ms),

            const Spacer(flex: 1),

            // ── Mascot ──
            Animate(
              effects: [
                FadeEffect(duration: 400.ms),
                ScaleEffect(
                  begin: const Offset(0.92, 0.92),
                  end: const Offset(1, 1),
                  duration: 450.ms,
                  curve: Curves.easeOutCubic,
                ),
              ],
              child: ClipRect(
                child: Align(
                  alignment: Alignment.center,
                  heightFactor: 0.55,
                  child: Image.asset(
                    'assets/images/apple_mascot/apple_hello.png',
                    height: size.height * 0.45,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const Spacer(flex: 1),

            // ── Feature card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Animate(
                effects: [
                  FadeEffect(duration: 350.ms, delay: 80.ms),
                  SlideEffect(
                    begin: const Offset(0, 8),
                    end: Offset.zero,
                    duration: 350.ms,
                    delay: 80.ms,
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _BenefitRow(
                        icon: Icons.camera_alt_rounded,
                        title: 'Chụp ảnh. Để AI lo.',
                        desc:
                            'AI tự động nhận diện món ăn và tính calo trong vài giây.',
                      ),
                      const SizedBox(height: 16),
                      _BenefitRow(
                        icon: Icons.bar_chart_rounded,
                        title: 'Theo dõi dễ dàng.',
                        desc:
                            'Theo dõi calo, protein, carb và chất béo mỗi ngày.',
                      ),
                      const SizedBox(height: 16),
                      _BenefitRow(
                        icon: Icons.flag_rounded,
                        title: 'Đạt mục tiêu nhanh hơn.',
                        desc:
                            'Nhận mục tiêu cá nhân hóa và theo dõi tiến trình giảm mỡ.',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(flex: 2),

            // ── CTA ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Animate(
                effects: [
                  FadeEffect(duration: 350.ms, delay: 160.ms),
                  SlideEffect(
                    begin: const Offset(0, 8),
                    end: Offset.zero,
                    duration: 350.ms,
                    delay: 160.ms,
                  ),
                ],
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () =>
                          context.read<OnboardingProvider>().nextStep(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                        textStyle: GoogleFonts.beVietnamPro(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      child: const Text('Bắt đầu'),
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

// ── Benefit row ─────────────────────────────────────────
class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppColors.ink),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
