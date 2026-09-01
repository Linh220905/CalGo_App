import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/app_build_config.dart';
import '../../models/meal_guidance.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/home_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/macro_colors.dart';

class MealGuidanceScreen extends StatefulWidget {
  const MealGuidanceScreen({super.key});

  @override
  State<MealGuidanceScreen> createState() => _MealGuidanceScreenState();
}

class _MealGuidanceScreenState extends State<MealGuidanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HomeProvider>().markMealGuidanceViewed();
        context.read<HomeProvider>().generateMealGuidance();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final isDark = settings.isDarkMode;
    final s = settings.strings;
    final background =
        isDark ? const Color(0xFF121116) : const Color(0xFFF7F7F8);
    final text = isDark ? Colors.white : const Color(0xFF121316);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: context.pop,
          icon: Icon(Icons.arrow_back_rounded, color: text),
        ),
        title: Text(s.guidanceScreenTitle,
            style: TextStyle(
                color: text, fontWeight: FontWeight.w800, fontSize: 17)),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [Color(0xFF121116), Color(0xFF171A17)]
                  : const [Color(0xFFF7F7F8), Color(0xFFF0F0F2)],
            ),
          ),
          child: Consumer<HomeProvider>(
            builder: (context, home, _) => _GuidanceBody(
              guidance: home.mealGuidance,
              loading: home.loadingMealGuidance || !home.hasLoaded,
              refreshing: home.loadingMealGuidance,
              isDark: isDark,
              onRetry: home.refreshMealGuidance,
              onScan: () => context.push('/scan'),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuidanceBody extends StatelessWidget {
  final MealGuidance? guidance;
  final bool loading;
  final bool refreshing;
  final bool isDark;
  final VoidCallback onRetry;
  final VoidCallback onScan;

  const _GuidanceBody({
    required this.guidance,
    required this.loading,
    required this.refreshing,
    required this.isDark,
    required this.onRetry,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final text = isDark ? Colors.white : const Color(0xFF121316);
    final muted = isDark ? const Color(0xFFABAAB2) : const Color(0xFF686971);
    if (loading && guidance == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    final value = guidance;
    if (value == null || value.needsFirstScan || !value.isAvailable) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 56).clamp(0, double.infinity),
            ),
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.restaurant_outlined, size: 36, color: text),
                const SizedBox(height: 16),
                Text(
                    value?.title.isNotEmpty == true
                        ? value!.title
                        : s.guidanceUnavailableTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: text,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                    value?.message.isNotEmpty == true
                        ? value!.message
                        : s.guidanceUnavailableMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, height: 1.4)),
                if (value?.goalReached != true) ...[
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onScan,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(s.guidanceScanMeal),
                    style: FilledButton.styleFrom(
                        backgroundColor: text,
                        foregroundColor: isDark ? Colors.black : Colors.white),
                  ),
                ],
              ]),
            ),
          ),
        ),
      );
    }

    final summary = value.summary!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        // ── Top Header Section ─────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          value.title,
                          style: TextStyle(
                            color: text,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _RecommendationCount(
                        count: value.recommendations.length,
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value.message,
                    style: TextStyle(
                      color: muted,
                      height: 1.4,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Transformation Forecast Card ───────────────────
        if (value.forecast != null)
          _TransformationForecastCard(
            forecast: value.forecast!,
            isDark: isDark,
          ),

        // ── Next Meal Target Summary ───────────────────────
        _ProgressRow(summary: summary, isDark: isDark),

        const SizedBox(height: 24),

        // ── Section Title: Dishes to Consider ──────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              s.guidanceConsiderMeals,
              style: TextStyle(
                color: text,
                fontWeight: FontWeight.w900,
                fontSize: 17,
                letterSpacing: -.3,
              ),
            ),
            const Spacer(),
            Text(
              s.guidanceScanForAccuracy,
              style: TextStyle(
                color: muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Hero Recommended Dish (#1) ──────────────────────
        _DishCard(
          dish: value.recommendations.first,
          order: 1,
          primary: true,
          isDark: isDark,
          onTap: onScan,
        ),

        // ── Alternative Swap Options ───────────────────────
        if (value.recommendations.length > 1) ...[
          const SizedBox(height: 20),
          Text(
            s.guidanceSwapWith,
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.w800,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 10),
          ...value.recommendations
              .skip(1)
              .toList()
              .asMap()
              .entries
              .map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DishCard(
                      dish: entry.value,
                      order: entry.key + 2,
                      primary: false,
                      isDark: isDark,
                      onTap: onScan,
                    ),
                  )),
        ],

        const SizedBox(height: 12),

        // ── Action Buttons & Disclaimer ────────────────────
        OutlinedButton.icon(
          onPressed: onScan,
          icon: const Icon(Icons.camera_alt_outlined, size: 18),
          label: Text(s.guidanceOtherMeal),
          style: OutlinedButton.styleFrom(
            foregroundColor: text,
            side: BorderSide(
              color: isDark ? const Color(0xFF353342) : const Color(0xFFD1D5DB),
            ),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        if (!AppBuildConfig.isTesting) ...[
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: refreshing
                ? null
                : value.hasPremiumAccess
                    ? onRetry
                    : () => _showPremiumRequired(context),
            icon: refreshing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded, size: 18),
            label: Text(s.guidanceChangeSuggestion),
            style: TextButton.styleFrom(
              foregroundColor: muted,
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          s.guidanceDisclaimer,
          textAlign: TextAlign.center,
          style: TextStyle(color: muted, fontSize: 11, height: 1.35),
        ),
      ],
    );
  }

  Future<void> _showPremiumRequired(BuildContext context) async {
    final s = context.read<AppSettingsProvider>().strings;
    final upgrade = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.guidancePremiumSwapTitle),
        content: Text(s.guidancePremiumSwapMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(s.later),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(s.upgradePremium),
          ),
        ],
      ),
    );
    if (upgrade == true && context.mounted) {
      context.push('/premium');
    }
  }
}

class _ProgressRow extends StatelessWidget {
  final MealGuidanceSummary summary;
  final bool isDark;
  const _ProgressRow({required this.summary, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final background = isDark ? const Color(0xFF212027) : Colors.white;
    final border = isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x33000000) : const Color(0x060F172A),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.track_changes_rounded,
                  size: 16, color: text.withOpacity(.78)),
              const SizedBox(width: 6),
              Text(s.guidanceNextMealGoal,
                  style: TextStyle(
                      color: text.withOpacity(.58),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .45)),
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: _Stat(
                    label: s.remainingLabel,
                    value: s.guidanceDishCalories(
                        summary.caloriesRemaining.clamp(0, 9999).round()),
                    text: text)),
            Container(height: 34, width: 1, color: border),
            Expanded(
                child: _Stat(
                    label: s.proteinNeededLabel,
                    value: '${summary.proteinRemaining.round()}g',
                    text: text)),
          ]),
        ],
      ),
    );
  }
}

class _RecommendationCount extends StatelessWidget {
  final int count;
  final bool isDark;

  const _RecommendationCount({required this.count, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final color = isDark ? const Color(0xFFE2E2E5) : const Color(0xFF28282C);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(s.dishCount(count),
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w900)),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color text;
  const _Stat({required this.label, required this.value, required this.text});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  color: text.withOpacity(.56),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  color: text, fontSize: 15, fontWeight: FontWeight.w800)),
        ]),
      );
}

class _DishCard extends StatelessWidget {
  final MealGuidanceDish dish;
  final int order;
  final bool primary;
  final bool isDark;
  final VoidCallback onTap;
  const _DishCard(
      {required this.dish,
      required this.order,
      required this.primary,
      required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final background = isDark ? const Color(0xFF212027) : Colors.white;
    final border = primary
        ? (isDark ? const Color(0xFF454254) : const Color(0xFF0F172A))
        : (isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0));
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted = text.withOpacity(.6);
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(primary ? 18 : 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border, width: primary ? 1.4 : 1),
              boxShadow: primary
                  ? [
                      BoxShadow(
                        color: isDark
                            ? const Color(0x40000000)
                            : const Color(0x0C0F172A),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null),
          child: primary
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    _DishIcon(dish: dish, isDark: isDark, size: 34),
                    const SizedBox(width: 9),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF37363F)
                              : const Color(0xFFF0F0F2),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                            dish.isFamiliar
                                ? s.familiarMacroLabel
                                : s.numberOneChoice,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: text,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .35)),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.camera_alt_outlined, color: text, size: 21),
                  ]),
                  const SizedBox(height: 11),
                  Text(dish.name,
                      style: TextStyle(
                          color: text,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.45)),
                  const SizedBox(height: 12),
                  Row(children: [
                    _DishMetric(
                        label: s.energyLabel,
                        value: s.guidanceDishCalories(dish.calories.round()),
                        text: text),
                    Container(
                        width: 1, height: 30, color: muted.withOpacity(.35)),
                    _DishMetric(
                        label: s.proteinLabel,
                        value: s.guidanceDishProtein(dish.protein.round()),
                        text: text),
                  ]),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 7,
                    runSpacing: 6,
                    children: [
                      _DishTag(
                          label: s.guidanceDishCarbs(dish.carbs.round()),
                          text: text,
                          icon: MacroColors.carbIcon,
                          tint: MacroColors.carb),
                      _DishTag(
                          label: s.guidanceDishFat(dish.fat.round()),
                          text: text,
                          icon: MacroColors.fatIcon,
                          tint: MacroColors.fat),
                      _DishTag(
                          label: _fitLabel(dish.fit, s),
                          text: text,
                          icon: Icons.check_circle_outline_rounded,
                          tint: const Color(0xFF22A06B)),
                      if (dish.isFamiliar)
                        _DishTag(
                            label: s.familiarLabel,
                            text: text,
                            icon: Icons.history_rounded,
                            tint: const Color(0xFF7C6CE7)),
                      if (dish.prepTimeMin != null)
                        _DishTag(
                            label: s.guidancePrepTime(dish.prepTimeMin!),
                            text: text,
                            icon: Icons.schedule_rounded,
                            tint: const Color(0xFF3B82F6)),
                      if (dish.priceVnd != null)
                        _DishTag(
                            label: s.guidancePrice(
                                (dish.priceVnd! / 1000).round().toString()),
                            text: text,
                            icon: Icons.payments_outlined,
                            tint: const Color(0xFF16A085)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: muted.withOpacity(.22)),
                  ),
                  Text(dish.reason,
                      style: TextStyle(
                          color: text,
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w600)),
                  if (dish.adjustment.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2B2A31)
                            : const Color(0xFFF6F6F7),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(s.dishTip(dish.adjustment),
                          style: TextStyle(
                              color: text, fontSize: 12, height: 1.3)),
                    ),
                  ],
                ])
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(
                      width: 28,
                      child: Text(order.toString().padLeft(2, '0'),
                          style: TextStyle(
                              color: muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w800)),
                    ),
                    _DishIcon(dish: dish, isDark: isDark, size: 32),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(dish.name,
                          style: TextStyle(
                              color: text,
                              fontSize: 15,
                              height: 1.25,
                              fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.camera_alt_outlined, color: text, size: 20),
                  ]),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 68),
                    child: Text(
                        s.dishMacroSummary(dish.calories.round(),
                            dish.protein.round().toString()),
                        style: TextStyle(
                            color: muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 68),
                    child: Text(dish.reason,
                        style: TextStyle(
                            color: text.withOpacity(.72),
                            fontSize: 12,
                            height: 1.35)),
                  ),
                  if (dish.adjustment.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 68),
                      child: Text(s.dishTip(dish.adjustment),
                          style: TextStyle(
                              color: muted, fontSize: 11.5, height: 1.3)),
                    ),
                  ],
                ]),
        ),
      ),
    );
  }
}

class _DishMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color text;
  const _DishMetric(
      {required this.label, required this.value, required this.text});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(
                    color: text.withOpacity(.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .35)),
            const SizedBox(height: 3),
            Text(value,
                style: TextStyle(
                    color: text, fontSize: 15, fontWeight: FontWeight.w900)),
          ]),
        ),
      );
}

class _DishTag extends StatelessWidget {
  final String label;
  final Color text;
  final IconData? icon;
  final Color? tint;

  const _DishTag(
      {required this.label, required this.text, this.icon, this.tint});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: (tint ?? text).withOpacity(.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: tint ?? text.withOpacity(.72)),
              const SizedBox(width: 4),
            ],
            Text(label,
                style: TextStyle(
                    color: text.withOpacity(.78),
                    fontSize: 11,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      );
}

class _DishIcon extends StatelessWidget {
  final MealGuidanceDish dish;
  final bool isDark;
  final double size;

  const _DishIcon(
      {required this.dish, required this.isDark, required this.size});

  @override
  Widget build(BuildContext context) {
    final accent = _dishAccent(dish);
    final icon = _dishIcon(dish);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent.withOpacity(isDark ? .20 : .12),
        borderRadius: BorderRadius.circular(size * .30),
      ),
      child: Icon(icon, size: size * .52, color: accent),
    );
  }
}

Color _dishAccent(MealGuidanceDish dish) {
  const palette = [
    Color(0xFF1C9A72),
    Color(0xFFE17B56),
    Color(0xFF6E7FD8),
    Color(0xFFE0A12B),
  ];
  final key = dish.id.isEmpty ? dish.name : dish.id;
  final score = key.codeUnits.fold<int>(0, (sum, value) => sum + value);
  return palette[score % palette.length];
}

IconData _dishIcon(MealGuidanceDish dish) {
  final name = dish.name.toLowerCase();
  if (name.contains('salad') || name.contains('rau')) {
    return Icons.eco_rounded;
  }
  if (name.contains('phở') || name.contains('bún') || name.contains('mì')) {
    return Icons.ramen_dining_rounded;
  }
  if (name.contains('cơm') || name.contains('gạo')) {
    return Icons.rice_bowl_rounded;
  }
  if (name.contains('gà') || name.contains('thịt') || name.contains('bò')) {
    return Icons.set_meal_rounded;
  }
  return Icons.restaurant_rounded;
}

String _fitLabel(String fit, AppLocalizations s) => switch (fit) {
      'great' => s.fitGoalGreat,
      'adjust' => s.fitGoalAdjust,
      _ => s.fitGoalGood,
    };

class _TransformationForecastCard extends StatelessWidget {
  final ProgressForecast forecast;
  final bool isDark;

  const _TransformationForecastCard({
    required this.forecast,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF212027) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);
    final primaryText = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryText =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final goalLabel = forecast.goalType == 'lose'
        ? 'Giảm cân'
        : (forecast.goalType == 'gain'
            ? 'Tăng cơ / Tăng cân'
            : 'Duy trì vóc dáng');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x33000000) : const Color(0x060F172A),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Goal Badge + Status Tag
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 15,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dự báo tiến trình • $goalLabel',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (forecast.statusTag.isNotEmpty)
                Flexible(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 132),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2E2B38)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF3F3C4B)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        forecast.statusTag,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.5,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                          color: primaryText,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Forecast Big Stats line (if weeks or target weight available)
          if (forecast.projectedWeeksToGoal != null &&
              forecast.targetWeightKg != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${forecast.projectedWeeksToGoal}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: primaryText,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'tuần nữa',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: secondaryText,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '→ Chạm mốc ${forecast.targetWeightKg}kg',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF22C55E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Main Forecast Encouraging Message
          Text(
            forecast.forecastMessage,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
