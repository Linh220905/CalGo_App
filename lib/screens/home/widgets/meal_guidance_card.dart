import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../models/meal_guidance.dart';
import '../../../providers/app_settings_provider.dart';

class MealGuidanceCard extends StatelessWidget {
  final MealGuidance? guidance;
  final bool isLoading;
  final bool isDark;
  final VoidCallback onScan;
  final VoidCallback onRefresh;

  const MealGuidanceCard({
    super.key,
    required this.guidance,
    required this.isLoading,
    required this.isDark,
    required this.onScan,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && guidance == null) {
      return _GuidanceLoadingCard(isDark: isDark);
    }
    final value = guidance;
    if (value == null) return const SizedBox.shrink();
    if (value.needsFirstScan) {
      return _FirstScanCard(
        message: value.message,
        isDark: isDark,
        onScan: onScan,
      );
    }
    if (value.goalReached) {
      return _GoalReachedCard(isDark: isDark, message: value.message);
    }
    if (!value.isAvailable || value.recommendations.isEmpty) {
      return _UnavailableCard(
          isDark: isDark, message: value.message, onScan: onScan);
    }
    return _RecommendationsCard(
      guidance: value,
      isDark: isDark,
      onScan: onScan,
      onRefresh: onRefresh,
    );
  }
}

class _RecommendationsCard extends StatelessWidget {
  final MealGuidance guidance;
  final bool isDark;
  final VoidCallback onScan;
  final VoidCallback onRefresh;

  const _RecommendationsCard({
    required this.guidance,
    required this.isDark,
    required this.onScan,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final s = context.watch<AppSettingsProvider>().strings;
    final bg = isDark ? const Color(0xFF1D1D20) : const Color(0xFFF1F1F3);
    final border = isDark ? const Color(0xFF444449) : const Color(0xFFD6D6DA);
    final title = isDark ? Colors.white : const Color(0xFF18181B);
    final muted = isDark ? const Color(0xFFB7B7BD) : const Color(0xFF68686E);
    final summary = guidance.summary!;
    final featured = guidance.recommendations.first;
    final alternatives = guidance.recommendations.skip(1).toList();

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .22 : .08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: guidance.isRecovery
                        ? const [Color(0xFF3A3A3F), Color(0xFF242428)]
                        : const [Color(0xFFE2E2E5), Color(0xFFF8F8F9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    '01',
                    style: TextStyle(
                      color: guidance.isRecovery
                          ? const Color(0xFFE8E8EB)
                          : const Color(0xFF2A2A2E),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guidance.title,
                      style: TextStyle(
                        color: title,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        letterSpacing: -.35,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      guidance.isRecovery
                          ? s.guidanceRecoverySubtitle
                          : s.guidanceLoggedSubtitle,
                      style: TextStyle(
                          color: muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (guidance.llmCallsRemaining > 0)
                IconButton(
                  tooltip: s.guidanceRefreshTooltip,
                  onPressed: onRefresh,
                  icon: Icon(Icons.refresh_rounded, size: 20, color: muted),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            guidance.message,
            style: TextStyle(
                color: title,
                fontSize: 14,
                height: 1.38,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricPill(
                icon: Icons.local_fire_department_rounded,
                label: s.guidanceCaloriesRemaining(
                    summary.caloriesRemaining.clamp(0, 9999).round()),
                color:
                    isDark ? const Color(0xFFE2E2E5) : const Color(0xFF38383D),
                isDark: isDark,
              ),
              _MetricPill(
                icon: Icons.bolt_rounded,
                label: s
                    .guidanceProteinRemaining(summary.proteinRemaining.round()),
                color:
                    isDark ? const Color(0xFFD0D0D5) : const Color(0xFF5A5A61),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FeaturedDish(
            dish: featured,
            isDark: isDark,
            onScan: onScan,
          ),
          if (alternatives.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(s.guidanceAlternativesTitle,
                style: TextStyle(
                    color: muted, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...alternatives.map((dish) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _CompactDish(
                    dish: dish,
                    isDark: isDark,
                    onTap: onScan,
                  ),
                )),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onScan,
                  icon: const Icon(Icons.photo_camera_outlined, size: 18),
                  label: Text(s.guidanceOtherMeal),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark
                        ? const Color(0xFFE4E4E7)
                        : const Color(0xFF28282C),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              if (guidance.llmCallsRemaining > 0)
                TextButton(
                  onPressed: onRefresh,
                  child: Text(s.guidanceSeeMore),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            s.guidanceDisclaimer,
            style: TextStyle(color: muted, fontSize: 11.5, height: 1.3),
          ),
        ],
      ),
    )
        .animate(target: reduceMotion ? 0 : 1)
        .fadeIn(duration: 200.ms, curve: Curves.easeOut)
        .slideY(
            begin: .035, end: 0, duration: 220.ms, curve: Curves.easeOutCubic);
  }
}

class _FeaturedDish extends StatelessWidget {
  final MealGuidanceDish dish;
  final bool isDark;
  final VoidCallback onScan;

  const _FeaturedDish(
      {required this.dish, required this.isDark, required this.onScan});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final text = isDark ? Colors.white : const Color(0xFF18181B);
    return Material(
      color: isDark ? const Color(0xFF252529) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onScan,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF3A3A3F)
                      : const Color(0xFFE5E5E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('01',
                      style: TextStyle(
                          color: Color(0xFF343439),
                          fontSize: 11,
                          fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(dish.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: text,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800))),
                        if (dish.isFamiliar)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6A6A70)
                                  .withOpacity(isDark ? .22 : .12),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(s.guidanceFamiliarTag,
                                style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFFE4E4E7)
                                        : const Color(0xFF3A3A3F),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900)),
                          ),
                        _FitBadge(fit: dish.fit),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 7,
                      children: [
                        _DishValue(
                            s.guidanceDishCalories(dish.calories.round())),
                        _DishValue(s.guidanceDishProtein(dish.protein.round())),
                        _DishValue(s.guidanceDishCarbs(dish.carbs.round())),
                        if (dish.prepTimeMin != null)
                          _DishValue(s.guidancePrepTime(dish.prepTimeMin!)),
                        if (dish.priceVnd != null)
                          _DishValue(s.guidancePrice(
                              (dish.priceVnd! / 1000).round().toString())),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(dish.reason,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: isDark
                                ? const Color(0xFFC8C8CD)
                                : const Color(0xFF626269),
                            fontSize: 12,
                            height: 1.25)),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.photo_camera_outlined,
                  color: isDark
                      ? const Color(0xFFE4E4E7)
                      : const Color(0xFF3A3A3F),
                  size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactDish extends StatelessWidget {
  final MealGuidanceDish dish;
  final bool isDark;
  final VoidCallback onTap;

  const _CompactDish(
      {required this.dish, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    return Material(
      color: isDark ? const Color(0xFF242428) : const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 25,
                height: 25,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF77777D).withOpacity(isDark ? .22 : .12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text('•',
                    style: TextStyle(
                        color: isDark
                            ? const Color(0xFFE4E4E7)
                            : const Color(0xFF444449),
                        fontSize: 18,
                        height: 1,
                        fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(dish.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color:
                              isDark ? Colors.white : const Color(0xFF242428),
                          fontWeight: FontWeight.w700))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(s.guidanceDishCalories(dish.calories.round()),
                      style: TextStyle(
                          color: isDark
                              ? const Color(0xFFD0D0D5)
                              : const Color(0xFF444449),
                          fontWeight: FontWeight.w800,
                          fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(s.guidanceDishProtein(dish.protein.round()),
                      style: TextStyle(
                          color: isDark
                              ? const Color(0xFFB7B7BD)
                              : const Color(0xFF77777D),
                          fontWeight: FontWeight.w700,
                          fontSize: 10)),
                ],
              ),
              const SizedBox(width: 5),
              Icon(Icons.photo_camera_outlined,
                  color: isDark
                      ? const Color(0xFFB7B7BD)
                      : const Color(0xFF77777D)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DishValue extends StatelessWidget {
  final String value;
  const _DishValue(this.value);

  @override
  Widget build(BuildContext context) => Text(value,
      style: const TextStyle(
          color: Color(0xFF444449), fontSize: 12, fontWeight: FontWeight.w800));
}

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  const _MetricPill(
      {required this.icon,
      required this.label,
      required this.color,
      required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color:
              isDark ? color.withOpacity(.16) : Colors.white.withOpacity(.78),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF35353A),
                  fontSize: 11,
                  fontWeight: FontWeight.w800)),
        ]),
      );
}

class _FitBadge extends StatelessWidget {
  final String fit;
  const _FitBadge({required this.fit});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final label = fit == 'great'
        ? s.guidanceFitGreat
        : fit == 'adjust'
            ? s.guidanceFitAdjust
            : s.guidanceFitGood;
    const color = Color(0xFF444449);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(.12),
          borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }
}

class _FirstScanCard extends StatelessWidget {
  final String message;
  final bool isDark;
  final VoidCallback onScan;
  const _FirstScanCard(
      {required this.message, required this.isDark, required this.onScan});

  @override
  Widget build(BuildContext context) => _EmptyGuidanceShell(
        isDark: isDark,
        icon: Icons.center_focus_strong_rounded,
        title: context.watch<AppSettingsProvider>().strings.guidanceAppleTitle,
        message: message,
        action: context
            .watch<AppSettingsProvider>()
            .strings
            .guidanceFirstScanAction,
        onAction: onScan,
      );
}

class _UnavailableCard extends StatelessWidget {
  final bool isDark;
  final String message;
  final VoidCallback onScan;
  const _UnavailableCard(
      {required this.isDark, required this.message, required this.onScan});

  @override
  Widget build(BuildContext context) => _EmptyGuidanceShell(
        isDark: isDark,
        icon: Icons.auto_awesome_outlined,
        title: context
            .watch<AppSettingsProvider>()
            .strings
            .guidanceAppleSuggestionTitle,
        message: message,
        action:
            context.watch<AppSettingsProvider>().strings.guidanceNextMealAction,
        onAction: onScan,
      );
}

class _GoalReachedCard extends StatelessWidget {
  final bool isDark;
  final String message;

  const _GoalReachedCard({required this.isDark, required this.message});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF202023) : const Color(0xFFF1F1F3),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
              color:
                  isDark ? const Color(0xFF444449) : const Color(0xFFD6D6DA)),
        ),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3A3A3F) : const Color(0xFFE2E2E5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.celebration_rounded,
                color:
                    isDark ? const Color(0xFFE4E4E7) : const Color(0xFF444449)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    context
                        .watch<AppSettingsProvider>()
                        .strings
                        .guidanceGoalReachedTitle,
                    style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF242428),
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(message,
                    style: TextStyle(
                        color: isDark
                            ? const Color(0xFFBDBDC3)
                            : const Color(0xFF64646B),
                        fontSize: 12,
                        height: 1.3)),
              ],
            ),
          ),
        ]),
      );
}

class _EmptyGuidanceShell extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String message;
  final String action;
  final VoidCallback onAction;
  const _EmptyGuidanceShell(
      {required this.isDark,
      required this.icon,
      required this.title,
      required this.message,
      required this.action,
      required this.onAction});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF202023) : const Color(0xFFF1F1F3),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
              color:
                  isDark ? const Color(0xFF444449) : const Color(0xFFD6D6DA)),
        ),
        child: Row(children: [
          Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF3A3A3F)
                      : const Color(0xFFE2E2E5),
                  borderRadius: BorderRadius.circular(16)),
              child: Icon(icon,
                  color: isDark
                      ? const Color(0xFFE4E4E7)
                      : const Color(0xFF444449))),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF242428),
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(message,
                    style: TextStyle(
                        color: isDark
                            ? const Color(0xFFBDBDC3)
                            : const Color(0xFF64646B),
                        fontSize: 12,
                        height: 1.3)),
                const SizedBox(height: 9),
                TextButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.camera_alt_rounded, size: 16),
                    label: Text(action),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: isDark
                            ? const Color(0xFFE4E4E7)
                            : const Color(0xFF444449),
                        textStyle:
                            const TextStyle(fontWeight: FontWeight.w800))),
              ])),
        ]),
      );
}

class _GuidanceLoadingCard extends StatelessWidget {
  final bool isDark;
  const _GuidanceLoadingCard({required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        height: 142,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF202023) : const Color(0xFFF1F1F3),
          borderRadius: BorderRadius.circular(26),
        ),
        child: const Center(
            child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.4, color: Color(0xFF77777D)))),
      );
}
