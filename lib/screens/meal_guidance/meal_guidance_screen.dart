import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/app_build_config.dart';
import '../../models/meal_guidance.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/home_provider.dart';
import '../../l10n/generated/app_localizations.dart';

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
  final bool isDark;
  final VoidCallback onRetry;
  final VoidCallback onScan;

  const _GuidanceBody({
    required this.guidance,
    required this.loading,
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _GuidanceHero(isDark: isDark, onScan: onScan),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(value.title,
                  style: TextStyle(
                      color: text,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.7)),
            ),
            const SizedBox(width: 12),
            _RecommendationCount(
                count: value.recommendations.length, isDark: isDark),
          ],
        ),
        const SizedBox(height: 8),
        Text(value.message,
            style: TextStyle(color: muted, height: 1.45, fontSize: 14)),
        const SizedBox(height: 22),
        _ProgressRow(summary: summary, isDark: isDark),
        const SizedBox(height: 30),
        LayoutBuilder(
          builder: (context, constraints) {
            final headingStyle = TextStyle(
              color: text,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            );
            final note = Text(
              s.guidanceScanForAccuracy,
              style: TextStyle(
                color: muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            );
            if (constraints.maxWidth < 340) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.guidanceConsiderMeals, style: headingStyle),
                  const SizedBox(height: 4),
                  note,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(s.guidanceConsiderMeals, style: headingStyle),
                ),
                const SizedBox(width: 12),
                Flexible(child: note),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        _DishCard(
          dish: value.recommendations.first,
          order: 1,
          primary: true,
          isDark: isDark,
          onTap: onScan,
        ),
        if (value.recommendations.length > 1) ...[
          const SizedBox(height: 24),
          Text(s.guidanceSwapWith,
              style: TextStyle(
                  color: text, fontWeight: FontWeight.w800, fontSize: 15)),
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
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: onScan,
          icon: const Icon(Icons.camera_alt_outlined, size: 18),
          label: Text(s.guidanceOtherMeal),
          style: OutlinedButton.styleFrom(
            foregroundColor: text,
            side: BorderSide(
                color:
                    isDark ? const Color(0xFF4B4A52) : const Color(0xFFD7D7DC)),
            minimumSize: const Size.fromHeight(50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        if (!AppBuildConfig.isTesting) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: value.hasPremiumAccess
                ? onRetry
                : () => _showPremiumRequired(context),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(s.guidanceChangeSuggestion),
            style: TextButton.styleFrom(foregroundColor: text),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          s.guidanceDisclaimer,
          textAlign: TextAlign.center,
          style: TextStyle(color: muted, fontSize: 11.5, height: 1.3),
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

class _GuidanceHero extends StatelessWidget {
  final bool isDark;
  final VoidCallback onScan;

  const _GuidanceHero({required this.isDark, required this.onScan});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    const foreground = Colors.white;
    final muted = Colors.white.withOpacity(.72);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 17, 14, 17),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF2B2B2F), Color(0xFF171719)]
              : const [Color(0xFF252529), Color(0xFF09090A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .22 : .14),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.13),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(.16)),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.guidanceTodayTitle,
                    style: TextStyle(
                        color: foreground,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.2)),
                const SizedBox(height: 4),
                Text(s.guidanceTodaySubtitle,
                    style: TextStyle(
                        color: muted,
                        fontSize: 11.5,
                        height: 1.3,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onScan,
            tooltip: s.guidanceScanRealMeal,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(.13),
              foregroundColor: foreground,
            ),
            icon: const Icon(Icons.camera_alt_outlined, size: 20),
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final MealGuidanceSummary summary;
  final bool isDark;
  const _ProgressRow({required this.summary, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final background =
        isDark ? const Color(0xFF202023) : const Color(0xFFF0F0F2);
    final border = isDark ? const Color(0xFF45454B) : const Color(0xFFD6D6DA);
    final text = isDark ? Colors.white : const Color(0xFF121316);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
      decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border)),
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
    final background = isDark ? const Color(0xFF201F25) : Colors.white;
    final border = primary
        ? (isDark ? Colors.white : const Color(0xFF17171A))
        : (isDark ? const Color(0xFF34333B) : const Color(0xFFE4E4E8));
    final text = isDark ? Colors.white : const Color(0xFF121316);
    final muted = text.withOpacity(.58);
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.all(primary ? 16 : 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border, width: primary ? 1.4 : 1),
              boxShadow: primary
                  ? [
                      BoxShadow(
                        color: (isDark ? Colors.black : const Color(0xFF111827))
                            .withOpacity(isDark ? .18 : .07),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null),
          child: primary
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
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
                          style: TextStyle(
                              color: text,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .35)),
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
                          text: text),
                      _DishTag(
                          label: s.guidanceDishFat(dish.fat.round()),
                          text: text),
                      _DishTag(label: _fitLabel(dish.fit, s), text: text),
                      if (dish.isFamiliar)
                        _DishTag(label: s.familiarLabel, text: text),
                      if (dish.prepTimeMin != null)
                        _DishTag(
                            label: s.guidancePrepTime(dish.prepTimeMin!),
                            text: text),
                      if (dish.priceVnd != null)
                        _DishTag(
                            label: s.guidancePrice(
                                (dish.priceVnd! / 1000).round().toString()),
                            text: text),
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
                      child: Text('0$order',
                          style: TextStyle(
                              color: muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w800)),
                    ),
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
                    padding: const EdgeInsets.only(left: 28),
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
                    padding: const EdgeInsets.only(left: 28),
                    child: Text(dish.reason,
                        style: TextStyle(
                            color: text.withOpacity(.72),
                            fontSize: 12,
                            height: 1.35)),
                  ),
                  if (dish.adjustment.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 28),
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

  const _DishTag({required this.label, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: text.withOpacity(.07),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                color: text.withOpacity(.72),
                fontSize: 11,
                fontWeight: FontWeight.w800)),
      );
}

String _fitLabel(String fit, AppLocalizations s) => switch (fit) {
      'great' => s.fitGoalGreat,
      'adjust' => s.fitGoalAdjust,
      _ => s.fitGoalGood,
    };
