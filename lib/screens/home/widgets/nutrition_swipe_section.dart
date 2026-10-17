import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/home_data.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/macro_colors.dart';
import '../../../utils/macro_icons.dart';
import '../../../widgets/calculation_sources.dart';
import '../../onboarding/steps/premium_paywall_step.dart';
import 'cal_ai_hero_card.dart';
import 'cal_ai_macro_card.dart';
import 'micro_nutrients_page.dart';
import 'body_vitality_page.dart';

const _kProteinColor = MacroColors.protein;
const _kCarbColor = MacroColors.carb;
const _kFatColor = MacroColors.fat;

class NutritionSwipeSection extends StatefulWidget {
  final TodaySummary summary;

  const NutritionSwipeSection({
    super.key,
    required this.summary,
  });

  @override
  State<NutritionSwipeSection> createState() => _NutritionSwipeSectionState();
}

class _NutritionSwipeSectionState extends State<NutritionSwipeSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openPaywall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PremiumPaywallStep(
          onboardingMode: false,
          source: 'home_nutrients_swipe',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final isDark = settings.isDarkMode;
    final strings = settings.strings;
    final isPremium = auth.user?.hasPremiumAccess ?? false;

    final dotActiveColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final dotInactiveColor =
        isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B);

    return Column(
      children: [
        SizedBox(
          height: 324,
          child: PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            children: [
              // ── Page 1: CalAiHeroCard + 3 CalAiMacroCards (Protein, Carbs, Fat) ──
              _buildPageOne(strings),

              // ── Page 2: 3 Micronutrients (Fiber, Sugar, Sodium) + Health Score ──
              MicroNutrientsPage(
                summary: widget.summary,
                isPremium: isPremium,
                onLockedTap: () => _openPaywall(context),
              ),

              // ── Page 3: 4 Body Vitality Indices ──
              BodyVitalityPage(
                summary: widget.summary,
                isPremium: isPremium,
                onLockedTap: () => _openPaywall(context),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isActive = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 7 : 6,
              height: isActive ? 7 : 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? dotActiveColor
                    : dotInactiveColor.withValues(alpha: 0.35),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CalculationSources(type: CalculationSourceType.nutrients, dark: isDark),
        ),
      ],
    );
  }

  Widget _buildPageOne(dynamic strings) {
    final s = widget.summary;
    final target =
        s.effectiveTargetCalories > 0 ? s.effectiveTargetCalories : 2000;
    final remaining = s.remainingCalories;
    final pct = s.caloriesProgress;

    final targetProtein =
        s.targetProteinG > 0 ? s.targetProteinG.toDouble() : 120;
    final targetCarb = s.targetCarbG > 0 ? s.targetCarbG.toDouble() : 250;
    final targetFat = s.targetFatG > 0 ? s.targetFatG.toDouble() : 55;

    final proteinG = s.proteinG.toDouble();
    final carbG = s.carbG.toDouble();
    final fatG = s.fatG.toDouble();
    final proteinLeft = (targetProtein - proteinG).clamp(0.0, targetProtein);
    final carbLeft = (targetCarb - carbG).clamp(0.0, targetCarb);
    final fatLeft = (targetFat - fatG).clamp(0.0, targetFat);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CalAiHeroCard(
          caloriesConsumed: s.consumedCalories,
          caloriesBurned: s.burnedCalories,
          caloriesLeft: remaining,
          targetCalories: target,
          progress: pct,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Protein
            Expanded(
              child: CalAiMacroCard(
                title: strings.gramsValue(proteinLeft.round()),
                subtitle: strings.proteinLabel,
                consumed: proteinG.round(),
                target: targetProtein.round(),
                progress: (proteinG / targetProtein).clamp(0.0, 1.0),
                color: _kProteinColor,
                trackColor: const Color(0xFFFEE2E2),
                bgIconColor: const Color(0xFFFEF2F2),
                iconWidget: MacroIcons.protein(size: 18),
              ),
            ),
            const SizedBox(width: 10),
            // Carbs
            Expanded(
              child: CalAiMacroCard(
                title: strings.gramsValue(carbLeft.round()),
                subtitle: strings.carbsLabel,
                consumed: carbG.round(),
                target: targetCarb.round(),
                progress: (carbG / targetCarb).clamp(0.0, 1.0),
                color: _kCarbColor,
                trackColor: const Color(0xFFFEF3C7),
                bgIconColor: const Color(0xFFFFFBEB),
                iconWidget: MacroIcons.carb(size: 18),
              ),
            ),
            const SizedBox(width: 10),
            // Fats
            Expanded(
              child: CalAiMacroCard(
                title: strings.gramsValue(fatLeft.round()),
                subtitle: strings.fatsLabel,
                consumed: fatG.round(),
                target: targetFat.round(),
                progress: (fatG / targetFat).clamp(0.0, 1.0),
                color: _kFatColor,
                trackColor: const Color(0xFFDBEAFE),
                bgIconColor: const Color(0xFFEFF6FF),
                iconWidget: MacroIcons.fat(size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
