import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../models/gamification.dart';

// ── Color constants matching CalGo design system ─────────────────
const _kProteinColor = Color(0xFFFF5C5C);
const _kCarbColor = Color(0xFFF59E0B);
const _kFatColor = Color(0xFF3B82F6);
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
    builder: (_) => DailyRecapSheet(recap: recap, onFinish: onFinish),
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
    final textColor =
        settings.isDarkMode ? Colors.white : const Color(0xFF0F172A);

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

  const DailyRecapSheet({super.key, required this.recap, this.onFinish});

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
    final textMuted =
        isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B);

    return AnimatedBuilder(
      animation: _entryCtrl,
      builder: (context, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(
            CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic)),
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
                                style:
                                    TextStyle(fontSize: 13, color: textMuted),
                              ),
                            ],
                          ),
                        ),
                        // EXP badge
                        _ExpBadge(
                            expAnim: _expAnim,
                            exp: recap.expEarned,
                            isDark: isDark),
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
                        textMuted: textMuted),

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
                            textMuted: textMuted),
                        const SizedBox(width: 8),
                        _MacroBar(
                            label: 'Carbs',
                            pct: recap.carbPct,
                            color: _kCarbColor,
                            isDark: isDark,
                            cardBg: cardBg,
                            border: border,
                            textDark: textDark,
                            textMuted: textMuted),
                        const SizedBox(width: 8),
                        _MacroBar(
                            label: 'Chất béo',
                            pct: recap.fatPct,
                            color: _kFatColor,
                            isDark: isDark,
                            cardBg: cardBg,
                            border: border,
                            textDark: textDark,
                            textMuted: textMuted),
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
                          textMuted: textMuted),
                    ],

                    // ── Tomorrow Tip ─────────────────────────────
                    if (recap.tomorrowTip != null) ...[
                      const SizedBox(height: 10),
                      _TomorrowTipCard(
                          tip: recap.tomorrowTip!,
                          isDark: isDark,
                          cardBg: cardBg,
                          border: border,
                          textMuted: textMuted),
                    ],

                    const SizedBox(height: 24),

                    // ── Action Buttons ───────────────────────────
                    _ActionButtons(
                        recap: recap,
                        isDark: isDark,
                        textDark: textDark,
                        onFinish: widget.onFinish),
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

  const _ExpBadge(
      {required this.expAnim, required this.exp, required this.isDark});

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
                color:
                    isDark ? const Color(0xFF166534) : const Color(0xFFBBF7D0),
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
    final trackColor =
        isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);

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
                      progress: pct, color: ringColor, trackColor: trackColor),
                ),
                Icon(
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
    final trackColor =
        isDark ? const Color(0xFF2C2A34) : const Color(0xFFF1F5F9);

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
            child: const Icon(Icons.auto_awesome_rounded,
                size: 18, color: Color(0xFF8B5CF6)),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: textDark,
                    height: 1.5,
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
    final borderTip =
        isDark ? const Color(0xFF3D3510) : const Color(0xFFFDE68A);

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
                Text(
                  'Gợi ý cho ngày mai',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD97706),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: TextStyle(
                    fontSize: 13,
                    color: textMuted,
                    height: 1.5,
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

// ── Action Buttons ───────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final DailyRecap recap;
  final bool isDark;
  final Color textDark;
  final VoidCallback? onFinish;

  const _ActionButtons({
    required this.recap,
    required this.isDark,
    required this.textDark,
    this.onFinish,
  });

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
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              onFinish?.call();
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
                  borderRadius: BorderRadius.circular(18)),
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
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to stats
                },
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
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  // Share logic
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
                      borderRadius: BorderRadius.circular(14)),
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

  _RingPainter(
      {required this.progress, required this.color, required this.trackColor});

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
