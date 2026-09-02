import 'dart:math' as math;
import 'dart:async';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../models/gamification.dart';
import '../../utils/macro_colors.dart';
import '../../utils/stats_localization.dart';
import '../../utils/weight_forecast.dart';
import '../onboarding/steps/premium_paywall_step.dart';

// ── Color constants matching CalGo design system ─────────────────
const _kProteinColor = MacroColors.protein;
const _kCarbColor = MacroColors.carb;
const _kFatColor = MacroColors.fat;
const _kExpColor = Color(0xFF22C55E);
const _kFireColor = Color(0xFFF97316);

/// Shows the daily recap as a full-screen bottom sheet.
Future<void> showDailyRecap(
  BuildContext context, {
  required DailyRecap recap,
  VoidCallback? onFinish,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) =>
        DailyRecapSheet(recap: recap, onFinish: onFinish, isModal: true),
  );
}

/// Route target used by the 22:00 notification. The sheet remains available
/// from Home, while this page gives notification taps a stable destination.
class DailyRecapPage extends StatefulWidget {
  const DailyRecapPage({super.key});

  @override
  State<DailyRecapPage> createState() => _DailyRecapPageState();
}

class _DailyRecapPageState extends State<DailyRecapPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(context.read<GamificationProvider>().refreshRecap());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final gamification = context.watch<GamificationProvider>();
    final textColor = settings.isDarkMode
        ? Colors.white
        : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: settings.isDarkMode
          ? const Color(0xFF141318)
          : const Color(0xFFFAFAFB),
      appBar: AppBar(
        title: const Text('Tổng kết cuối ngày'),
        foregroundColor: textColor,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: gamification.recapLoading && gamification.recap == null
          ? const Center(child: CircularProgressIndicator())
          : gamification.recap == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  'Tổng kết sẽ sẵn sàng sau 22:00, khi bạn đã có dữ liệu quét trong ngày.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor, fontSize: 15),
                ),
              ),
            )
          : DailyRecapSheet(
              recap: gamification.recap!,
              isModal: false,
              onFinish: () {
                unawaited(gamification.finishRecap());
              },
            ),
    );
  }
}

class DailyRecapSheet extends StatefulWidget {
  final DailyRecap recap;
  final VoidCallback? onFinish;
  final bool isModal;

  const DailyRecapSheet({
    super.key,
    required this.recap,
    this.onFinish,
    this.isModal = true,
  });

  @override
  State<DailyRecapSheet> createState() => _DailyRecapSheetState();
}

class _DailyRecapSheetState extends State<DailyRecapSheet>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final AnimationController _expCtrl;
  late final Animation<double> _expAnim;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();

    _expCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _expAnim = CurvedAnimation(parent: _expCtrl, curve: Curves.easeOutCubic);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _expCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final isDark = settings.isDarkMode;
    final recap = widget.recap;

    final bg = isDark ? const Color(0xFF141318) : const Color(0xFFFAFAFB);
    final cardBg = isDark ? const Color(0xFF212027) : Colors.white;
    final border = isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark
        ? const Color(0xFF8E8D9A)
        : const Color(0xFF64748B);

    return AnimatedBuilder(
      animation: _entryCtrl,
      builder: (context, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic),
            ),
        child: FadeTransition(opacity: _entryCtrl, child: child),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tổng kết hôm nay',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: textDark,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${recap.mealCount} bữa đã ghi',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // EXP badge
                        _ExpBadge(
                          expAnim: _expAnim,
                          exp: recap.expEarned,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Calorie Ring Card ────────────────────────
                    _CaloRingCard(
                      recap: recap,
                      isDark: isDark,
                      cardBg: cardBg,
                      border: border,
                      textDark: textDark,
                      textMuted: textMuted,
                    ),

                    const SizedBox(height: 12),

                    // ── Macro Row ────────────────────────────────
                    Row(
                      children: [
                        _MacroBar(
                          label: 'Protein',
                          pct: recap.proteinPct,
                          color: _kProteinColor,
                          isDark: isDark,
                          cardBg: cardBg,
                          border: border,
                          textDark: textDark,
                          textMuted: textMuted,
                        ),
                        const SizedBox(width: 8),
                        _MacroBar(
                          label: 'Carbs',
                          pct: recap.carbPct,
                          color: _kCarbColor,
                          isDark: isDark,
                          cardBg: cardBg,
                          border: border,
                          textDark: textDark,
                          textMuted: textMuted,
                        ),
                        const SizedBox(width: 8),
                        _MacroBar(
                          label: 'Chất béo',
                          pct: recap.fatPct,
                          color: _kFatColor,
                          isDark: isDark,
                          cardBg: cardBg,
                          border: border,
                          textDark: textDark,
                          textMuted: textMuted,
                        ),
                      ],
                    ),

                    // ── AI Comment ───────────────────────────────
                    if (recap.aiComment != null) ...[
                      const SizedBox(height: 16),
                      _AiCommentCard(
                        comment: recap.aiComment!,
                        isDark: isDark,
                        cardBg: cardBg,
                        border: border,
                        textDark: textDark,
                        textMuted: textMuted,
                      ),
                    ],

                    // ── Tomorrow Tip ─────────────────────────────
                    if (recap.tomorrowTip != null) ...[
                      const SizedBox(height: 10),
                      _TomorrowTipCard(
                        tip: recap.tomorrowTip!,
                        isDark: isDark,
                        cardBg: cardBg,
                        border: border,
                        textMuted: textMuted,
                      ),
                    ],

                    // ── Target Timeline Estimation Card ──────────
                    const SizedBox(height: 16),
                    TargetTimelineCard(
                      recap: recap,
                      isDark: isDark,
                      cardBg: cardBg,
                      border: border,
                      textDark: textDark,
                      textMuted: textMuted,
                    ),

                    const SizedBox(height: 24),

                    // ── Action Buttons ───────────────────────────
                    _ActionButtons(
                      recap: recap,
                      isDark: isDark,
                      textDark: textDark,
                      isModal: widget.isModal,
                      onFinish: widget.onFinish,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── EXP Badge ────────────────────────────────────────────────────
class _ExpBadge extends StatelessWidget {
  final Animation<double> expAnim;
  final int exp;
  final bool isDark;

  const _ExpBadge({
    required this.expAnim,
    required this.exp,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: expAnim,
      builder: (_, __) => Transform.scale(
        scale: 0.7 + 0.3 * expAnim.value,
        child: Opacity(
          opacity: expAnim.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D2B14) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF166534)
                    : const Color(0xFFBBF7D0),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '+$exp',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _kExpColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const Text(
                  'EXP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _kExpColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Calorie Ring Card ────────────────────────────────────────────
class _CaloRingCard extends StatelessWidget {
  final DailyRecap recap;
  final bool isDark;
  final Color cardBg, border, textDark, textMuted;

  const _CaloRingCard({
    required this.recap,
    required this.isDark,
    required this.cardBg,
    required this.border,
    required this.textDark,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    final pct = recap.caloPct.clamp(0.0, 1.0);
    final ringColor = pct >= 1.0
        ? _kExpColor
        : isDark
        ? Colors.white
        : const Color(0xFF0F172A);
    final trackColor = isDark
        ? const Color(0xFF2C2A34)
        : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x22000000) : const Color(0x0A0F172A),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ring
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(80, 80),
                  painter: _RingPainter(
                    progress: pct,
                    color: ringColor,
                    trackColor: trackColor,
                  ),
                ),
                const Icon(
                  Icons.local_fire_department_rounded,
                  size: 26,
                  color: _kFireColor,
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${recap.totalCalo} kcal',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                    letterSpacing: -0.8,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'đã ăn hôm nay',
                  style: TextStyle(fontSize: 13, color: textMuted),
                ),
                const SizedBox(height: 8),
                Text(
                  '${recap.caloPercentDisplay}% mục tiêu ${recap.targetCalo} kcal',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: pct >= 0.9 ? _kExpColor : textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Macro Bar ────────────────────────────────────────────────────
class _MacroBar extends StatelessWidget {
  final String label;
  final double pct;
  final Color color;
  final bool isDark;
  final Color cardBg, border, textDark, textMuted;

  const _MacroBar({
    required this.label,
    required this.pct,
    required this.color,
    required this.isDark,
    required this.cardBg,
    required this.border,
    required this.textDark,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = pct.clamp(0.0, 100.0);
    final trackColor = isDark
        ? const Color(0xFF2C2A34)
        : const Color(0xFFF1F5F9);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${clamped.round()}%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: clamped >= 80 ? color : textDark,
                letterSpacing: -0.5,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: textMuted)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: (clamped / 100).clamp(0.0, 1.0),
                backgroundColor: trackColor,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AI Comment Card ──────────────────────────────────────────────
class _AiCommentCard extends StatelessWidget {
  final String comment;
  final bool isDark;
  final Color cardBg, border, textDark, textMuted;

  const _AiCommentCard({
    required this.comment,
    required this.isDark,
    required this.cardBg,
    required this.border,
    required this.textDark,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2A34) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nhận xét từ AI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment,
                  style: TextStyle(fontSize: 14, color: textDark, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tomorrow Tip Card ────────────────────────────────────────────
class _TomorrowTipCard extends StatelessWidget {
  final String tip;
  final bool isDark;
  final Color cardBg, border, textMuted;

  const _TomorrowTipCard({
    required this.tip,
    required this.isDark,
    required this.cardBg,
    required this.border,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    final bgTip = isDark ? const Color(0xFF1C1A10) : const Color(0xFFFFFBEB);
    final borderTip = isDark
        ? const Color(0xFF3D3510)
        : const Color(0xFFFDE68A);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgTip,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderTip),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gợi ý cho ngày mai',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD97706),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: TextStyle(fontSize: 13, color: textMuted, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action Buttons ───────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final DailyRecap recap;
  final bool isDark;
  final Color textDark;
  final bool isModal;
  final VoidCallback? onFinish;

  const _ActionButtons({
    required this.recap,
    required this.isDark,
    required this.textDark,
    required this.isModal,
    this.onFinish,
  });

  void _finish(BuildContext context) {
    HapticFeedback.mediumImpact();
    onFinish?.call();
    if (isModal) {
      Navigator.of(context).pop();
    } else {
      context.go('/home');
    }
  }

  Future<void> _shareRecap(BuildContext context) async {
    final recapText = [
      'CalGo – Tổng kết ngày ${recap.dateKey}',
      '🔥 ${recap.totalCalo}/${recap.targetCalo} kcal',
      '🥩 Protein: ${recap.proteinPct.round()}%',
      '🍚 Carbs: ${recap.carbPct.round()}%',
      '🥑 Chất béo: ${recap.fatPct.round()}%',
      '🍽️ ${recap.mealCount} bữa đã ghi',
    ].join('\n');

    final renderObject = context.findRenderObject();
    final box = renderObject is RenderBox && renderObject.hasSize
        ? renderObject
        : null;
    final sharePositionOrigin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;

    try {
      await Share.share(recapText, sharePositionOrigin: sharePositionOrigin);
    } catch (error) {
      debugPrint('Unable to share daily recap: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở bảng chia sẻ.')),
        );
      }
    }
  }

  void _openStats(BuildContext context) {
    final router = GoRouter.of(context);
    if (isModal) Navigator.of(context).pop();
    router.go('/stats');
  }

  @override
  Widget build(BuildContext context) {
    final btnBg = isDark ? Colors.white : const Color(0xFF0F172A);
    final btnFg = isDark ? const Color(0xFF0F172A) : Colors.white;

    return Column(
      children: [
        // Primary CTA
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _finish(context);
            },
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: const Text(
              'Hoàn thành ngày',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: btnBg,
              foregroundColor: btnFg,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Secondary actions row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openStats(context),
                icon: Icon(Icons.bar_chart_rounded, size: 16, color: textDark),
                label: Text(
                  'Báo cáo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF2C2A34)
                        : const Color(0xFFE2E8F0),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _shareRecap(context);
                },
                icon: Icon(Icons.share_outlined, size: 16, color: textDark),
                label: Text(
                  'Chia sẻ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF2C2A34)
                        : const Color(0xFFE2E8F0),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Ring Painter ─────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 10) / 2;
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;
    canvas.drawCircle(c, r, trackPaint);
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8.0
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Target Timeline Card ─────────────────────────────────────────
class TargetTimelineCard extends StatelessWidget {
  final DailyRecap? recap;
  final double? todayCalories;
  final double? calorieTarget;
  final bool isDark;
  final Color cardBg;
  final Color border;
  final Color textDark;
  final Color textMuted;

  const TargetTimelineCard({
    super.key,
    this.recap,
    this.todayCalories,
    this.calorieTarget,
    required this.isDark,
    required this.cardBg,
    required this.border,
    required this.textDark,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isPremiumUser = user?.hasPremiumAccess ?? false;
    final strings = context.watch<AppSettingsProvider>().strings;

    final currentWeight = user?.currentWeightKg;
    final targetWeight = user?.targetWeightKg;

    if (currentWeight == null || targetWeight == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.weightTargetForecastTitle,
              style: TextStyle(color: textDark, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              strings.notEnoughWeightData,
              style: TextStyle(color: textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final todayCal =
        todayCalories ?? (recap != null ? recap!.totalCalo.toDouble() : 0.0);
    final targetCal = (user != null && user.dailyCalorieTarget > 0)
        ? user.dailyCalorieTarget
        : (calorieTarget ??
              (recap != null && recap!.targetCalo > 0
                  ? recap!.targetCalo.toDouble()
                  : 2000.0));
    final safeFloor = switch (user?.gender?.toLowerCase()) {
      'male' => 1500.0,
      'female' => 1200.0,
      _ => 1350.0,
    };
    final forecast = WeightForecastCalculator.calculate(
      currentWeight: currentWeight,
      targetWeight: targetWeight,
      calories: todayCal,
      calorieTarget: targetCal,
      goal: user?.goal,
      tdee: user?.tdee,
      weeklyGoalKg: user?.weeklyGoalKg,
      safeFloorCalories: safeFloor,
    );
    final statusTitle = StatsLocalization.forecastStatusTitle(
      context,
      forecast,
    );
    final statusColor = forecast.isReached
        ? const Color(0xFF10B981)
        : forecast.status == WeightForecastStatus.noData
        ? const Color(0xFF64748B)
        : forecast.isWarning
        ? const Color(0xFFDC2626)
        : forecast.isMovingAway
        ? const Color(0xFFEA580C)
        : forecast.status == WeightForecastStatus.maintenance
        ? const Color(0xFF64748B)
        : const Color(0xFF10B981);
    final statusIcon = forecast.isReached
        ? Icons.check_circle_rounded
        : forecast.status == WeightForecastStatus.noData
        ? Icons.info_outline_rounded
        : forecast.isWarning
        ? Icons.health_and_safety_rounded
        : forecast.isMovingAway
        ? Icons.warning_amber_rounded
        : forecast.status == WeightForecastStatus.maintenance
        ? Icons.trending_flat_rounded
        : forecast.isMovingDown
        ? Icons.trending_down_rounded
        : Icons.trending_up_rounded;
    final estimatedWeeks = forecast.estimatedWeeks;
    final statusBody = StatsLocalization.forecastStatusBody(
      context,
      forecast,
      periodLabel: StatsLocalization.caloriePeriodLabel(
        context,
        weekly: recap == null,
      ),
      weeksLabel: estimatedWeeks == null
          ? strings.notEnoughWeightData
          : strings.weeksUnit(estimatedWeeks),
      recommendedCalories: targetCal.round(),
    );

    final int chartMaxWeeks = math.min(12, math.max(6, estimatedWeeks ?? 8));
    final List<double> projectedPoints = [];
    for (int w = 0; w <= chartMaxWeeks; w++) {
      final projected = currentWeight + (forecast.weeklyWeightChangeKg * w);
      projectedPoints.add(projected);
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Stack(
        children: [
          // Underlying Card Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Icon(Icons.timeline_rounded, color: statusColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        strings.weightTargetForecastTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Status Banner
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          statusTitle,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                      if (estimatedWeeks != null && estimatedWeeks > 0)
                        Text(
                          strings.weeksFormat(estimatedWeeks),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: statusColor,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Explanation text
                Text(
                  statusBody,
                  style: TextStyle(fontSize: 13, height: 1.4, color: textMuted),
                ),
                const SizedBox(height: 16),

                // Projection Chart
                SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _ProjectionChartPainter(
                      points: projectedPoints,
                      currentWeight: currentWeight,
                      targetWeight: targetWeight,
                      lineColor: statusColor,
                      isDark: isDark,
                      textMuted: textMuted,
                      currentLabel: strings.currentLabel,
                      weekAbbrev: (w) => strings.weekAbbrev(w),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Free User Glass Lock Overlay
          if (!isPremiumUser)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.5, sigmaY: 5.5),
                  child: Container(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.65)
                        : Colors.white.withValues(alpha: 0.75),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFD97706,
                            ).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            color: Color(0xFFD97706),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          strings.weightTargetForecastTitle,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          strings.premiumBenefitDescriptions,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: textMuted),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PremiumPaywallStep(
                                  onboardingMode: false,
                                  source: 'daily_recap',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.workspace_premium,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            strings.upgradePremium,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE0533C),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Projection Chart Painter ─────────────────────────────────────
class _ProjectionChartPainter extends CustomPainter {
  final List<double> points;
  final double currentWeight;
  final double targetWeight;
  final Color lineColor;
  final bool isDark;
  final Color textMuted;
  final String currentLabel;
  final String Function(int) weekAbbrev;

  _ProjectionChartPainter({
    required this.points,
    required this.currentWeight,
    required this.targetWeight,
    required this.lineColor,
    required this.isDark,
    required this.textMuted,
    required this.currentLabel,
    required this.weekAbbrev,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const double topPadding = 18.0;
    const double bottomPadding = 24.0;
    const double leftPadding = 32.0;
    const double rightPadding = 12.0;

    final double chartW = size.width - leftPadding - rightPadding;
    final double chartH = size.height - topPadding - bottomPadding;

    double minY = points.reduce(math.min);
    double maxY = points.reduce(math.max);
    minY = math.min(minY, targetWeight) - 0.5;
    maxY = math.max(maxY, targetWeight) + 0.5;
    if (maxY == minY) maxY += 1.0;

    double getY(double val) {
      final norm = (val - minY) / (maxY - minY);
      return topPadding + chartH * (1.0 - norm);
    }

    double getX(int idx) {
      if (points.length <= 1) return leftPadding;
      return leftPadding + (chartW * idx / (points.length - 1));
    }

    // 1. Dotted Target Weight Line
    final targetY = getY(targetWeight);
    final dottedPaint = Paint()
      ..color = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const double dashWidth = 4.0;
    const double dashSpace = 3.0;
    double startX = leftPadding;
    while (startX < size.width - rightPadding) {
      canvas.drawLine(
        Offset(startX, targetY),
        Offset(
          math.min(startX + dashWidth, size.width - rightPadding),
          targetY,
        ),
        dottedPaint,
      );
      startX += dashWidth + dashSpace;
    }

    // Target label
    final tp = TextPainter(
      text: TextSpan(
        text: '${targetWeight.toStringAsFixed(1)}kg',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(2, targetY - tp.height / 2));

    // 2. Main Bezier Curve
    final path = Path();
    path.moveTo(getX(0), getY(points[0]));
    for (int i = 0; i < points.length - 1; i++) {
      final x1 = getX(i);
      final y1 = getY(points[i]);
      final x2 = getX(i + 1);
      final y2 = getY(points[i + 1]);
      final cx = (x1 + x2) / 2;
      path.cubicTo(cx, y1, cx, y2, x2, y2);
    }

    // Gradient fill under curve
    final fillPath = Path.from(path)
      ..lineTo(getX(points.length - 1), size.height - bottomPadding)
      ..lineTo(leftPadding, size.height - bottomPadding)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.25),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Draw main stroke
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // 3. Points & Week Labels
    final pointPaint = Paint()..color = lineColor;
    final whiteInnerPaint = Paint()..color = Colors.white;

    for (int i = 0; i < points.length; i++) {
      final px = getX(i);
      final py = getY(points[i]);

      if (i == 0 || i == points.length - 1 || i == (points.length ~/ 2)) {
        canvas.drawCircle(Offset(px, py), 4.5, pointPaint);
        canvas.drawCircle(Offset(px, py), 2.0, whiteInnerPaint);

        final valTp = TextPainter(
          text: TextSpan(
            text: points[i].toStringAsFixed(1),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: lineColor,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        valTp.paint(canvas, Offset(px - valTp.width / 2, py - 14));
      }

      if (i == 0 || i == points.length - 1 || i == (points.length ~/ 2)) {
        final labelText = i == 0 ? currentLabel : weekAbbrev(i);
        final weekTp = TextPainter(
          text: TextSpan(
            text: labelText,
            style: TextStyle(fontSize: 10, color: textMuted),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        weekTp.paint(
          canvas,
          Offset(px - weekTp.width / 2, size.height - bottomPadding + 4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ProjectionChartPainter old) =>
      old.points != points ||
      old.currentWeight != currentWeight ||
      old.targetWeight != targetWeight ||
      old.lineColor != lineColor ||
      old.isDark != isDark ||
      old.textMuted != textMuted;
}
