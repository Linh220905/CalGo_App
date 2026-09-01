import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/onboarding_data.dart';
import '../../../widgets/premium_ui.dart';

// ─────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────
const _kInk = Color(0xFF111111);
const _kMuted = Color(0xFF111111);
const _kSurface = Color(0xFFFAFAFA);
const _kBorder = Color(0xFFEDEDED);
const _kTrack = Color(0xFFECECEC);

class AnalysisResultStep extends StatefulWidget {
  const AnalysisResultStep({super.key});

  @override
  State<AnalysisResultStep> createState() => _AnalysisResultStepState();
}

class _AnalysisResultStepState extends State<AnalysisResultStep> {
  bool _analyzing = true;
  Timer? _analysisTimer;
  Completer<void>? _analysisDelay;

  @override
  void initState() {
    super.initState();
    _prepareResult();
  }

  Future<void> _prepareResult() async {
    final provider = context.read<OnboardingProvider>();
    // Keep a deliberate analysis window so the personalized plan feels
    // considered; calculation and persistence still happen underneath.
    final delay = Completer<void>();
    _analysisDelay = delay;
    _analysisTimer = Timer(const Duration(milliseconds: 10500), () {
      if (!delay.isCompleted) delay.complete();
    });

    try {
      await Future.wait([provider.prepareAnalysis(), delay.future]);
      if (mounted) setState(() => _analyzing = false);
    } finally {
      _analysisTimer?.cancel();
      _analysisTimer = null;
      if (identical(_analysisDelay, delay)) _analysisDelay = null;
    }
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    final delay = _analysisDelay;
    if (delay != null && !delay.isCompleted) delay.complete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_analyzing) {
      return const _AnalyzingPhase();
    }
    return const _ResultPhase();
  }
}

// ═══════════════════════════════════════════════════════════════
// PHASE 1: ANALYZING — mascot lắc, text đổi, dots chạy
// ═══════════════════════════════════════════════════════════════

class _AnalyzingPhase extends StatefulWidget {
  const _AnalyzingPhase();

  @override
  State<_AnalyzingPhase> createState() => _AnalyzingPhaseState();
}

class _AnalyzingPhaseState extends State<_AnalyzingPhase>
    with TickerProviderStateMixin {
  late final AnimationController _rockController;
  late final AnimationController _bounceController;
  late final AnimationController _dotsController;
  late final AnimationController _shimmerController;
  int _messageIndex = 0;
  Timer? _messageTimer;

  static const _messageCount = 5;

  @override
  void initState() {
    super.initState();

    // Rock left-right ±5°
    _rockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Subtle bounce 4px
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Dots animation
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // Cycle messages every 2s
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted && _messageIndex < _messageCount - 1) {
        setState(() => _messageIndex++);
      }
    });
  }

  @override
  void dispose() {
    _rockController.dispose();
    _bounceController.dispose();
    _dotsController.dispose();
    _shimmerController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;
    final messages = [
      s.analyzingMessage1,
      s.analyzingMessage2,
      s.analyzingMessage3,
      s.analyzingMessage4,
      s.analyzingMessage5,
    ];
    final currentMessage = _messageIndex < messages.length
        ? messages[_messageIndex]
        : messages.last;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),

            // ── Cycling analysis copy ──
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              reverseDuration: const Duration(milliseconds: 180),
              switchInCurve: const Cubic(0.23, 1, 0.32, 1),
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.18),
                      end: Offset.zero,
                    ).animate(animation),
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.98,
                        end: 1.0,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                );
              },
              child: Padding(
                key: ValueKey<int>(_messageIndex),
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    final position = (_shimmerController.value * 3.4) - 1.7;
                    return ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment(position - 1, 0),
                        end: Alignment(position + 1, 0),
                        colors: const [
                          Color(0xFF111111),
                          Color(0xFF111111),
                          Color(0xFFA3A3A8),
                          Color(0xFF111111),
                          Color(0xFF111111),
                        ],
                        stops: const [0, 0.36, 0.5, 0.64, 1],
                      ).createShader(bounds),
                      child: child,
                    );
                  },
                  child: Text(
                    currentMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      color: _kInk,
                      letterSpacing: -0.25,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),

            // ── Mascot with rock + bounce ──
            AnimatedBuilder(
              animation: Listenable.merge([_rockController, _bounceController]),
              builder: (context, child) {
                // Rock: ±5° using easeInOut curve
                final rockT = Curves.easeInOut.transform(_rockController.value);
                final angle = (rockT - 0.5) * 2 * 5 * (math.pi / 180); // ±5°

                // Bounce: 4px vertical
                final bounceT = Curves.easeInOut.transform(
                  _bounceController.value,
                );
                final dy = (bounceT - 0.5) * 2 * -4; // -4 to +4

                return Transform.translate(
                  offset: Offset(0, dy),
                  child: Transform.rotate(angle: angle, child: child),
                );
              },
              child: Image.asset(
                'assets/images/apple_mascot/apple_analyze.png',
                width: 160,
                height: 160,
              ),
            ),
            const SizedBox(height: 36),

            // ── Animated dots ──
            AnimatedBuilder(
              animation: _dotsController,
              builder: (context, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    // Stagger each dot by 0.2
                    final delay = i * 0.2;
                    final t = ((_dotsController.value - delay) % 1.0).clamp(
                      0.0,
                      1.0,
                    );
                    // Smooth pulse: scale up then down
                    final scale = 1.0 + 0.4 * math.sin(t * math.pi);
                    final opacity = 0.3 + 0.7 * math.sin(t * math.pi);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: _kInk,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),

            const Spacer(flex: 4),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PHASE 2: RESULT — kết quả phân tích (giữ nguyên logic cũ)
// ═══════════════════════════════════════════════════════════════

class _ResultPhase extends StatelessWidget {
  const _ResultPhase();

  @override
  Widget build(BuildContext context) {
    final d = context.watch<OnboardingProvider>().data;
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;
    final name = d.name ?? s.defaultUserName;
    final kcal = d.targetCaloriesPerDay;
    final protein = d.targetProteinG;
    final carb = d.targetCarbG;
    final fat = d.targetFatG;
    final bmi = d.bmi;
    final bmiCat = bmi < 18.5
        ? s.bmiUnderweight
        : bmi < 23
        ? s.bmiNormal
        : bmi < 27.5
        ? s.bmiOverweight
        : s.bmiObese;
    final isHealthy = bmi >= 18.5 && bmi < 23;
    final workoutDays = _workoutDays(d.activityLevel, s);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──
                    Animate(
                      effects: const [
                        FadeEffect(duration: Duration(milliseconds: 500)),
                        SlideEffect(
                          begin: Offset(0, -0.08),
                          end: Offset.zero,
                          duration: Duration(milliseconds: 500),
                        ),
                      ],
                      child: _Header(name: name),
                    ),
                    const SizedBox(height: 24),

                    // ── Hero: calo + macro ──
                    _CalorieHeroCard(
                          kcal: kcal,
                          protein: protein,
                          carb: carb,
                          fat: fat,
                        )
                        .animate()
                        .fadeIn(duration: 450.ms, delay: 150.ms)
                        .slideY(begin: 0.04, end: 0),
                    const SizedBox(height: 14),

                    // ── BMI + tập luyện ──
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.monitor_heart_outlined,
                            label: 'BMI',
                            value: bmi > 0 ? bmi.toStringAsFixed(1) : '--',
                            tag: isHealthy ? s.bmiNormal : bmiCat,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.fitness_center_rounded,
                            label: s.workoutLabel,
                            value: workoutDays,
                            tag: s.perWeekText,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 450.ms, delay: 300.ms),
                    const SizedBox(height: 14),

                    // ── Hành trình ──
                    _ProgressCard(
                          currentWeight: d.weightKg ?? 72,
                          targetWeight: d.targetWeightKg ?? 65,
                          weeks: d.targetWeeks ?? 14,
                        )
                        .animate()
                        .fadeIn(duration: 450.ms, delay: 450.ms)
                        .slideY(begin: 0.04, end: 0),
                    const SizedBox(height: 14),

                    // ── Lời khuyên ──
                    _MotivationCard(
                          goalType: d.goalType,
                          remainingKg: _remainingKg(d),
                        )
                        .animate()
                        .fadeIn(duration: 450.ms, delay: 600.ms)
                        .slideY(begin: 0.04, end: 0),
                    const SizedBox(height: 22),

                    // ── Chữ ký ──
                    _TaoSignature().animate().fadeIn(
                      duration: 450.ms,
                      delay: 750.ms,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: PremiumButton(
                label: s.nextStepButton,
                onPressed: () => context.read<OnboardingProvider>().nextStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _remainingKg(OnboardingData d) {
    final w = d.weightKg ?? 0;
    final t = d.targetWeightKg ?? 0;
    if (d.goalType == GoalType.lose) return (w - t).abs();
    if (d.goalType == GoalType.gain) return (t - w).abs();
    return 0;
  }

  String _workoutDays(ActivityLevel? level, AppLocalizations s) {
    switch (level) {
      case ActivityLevel.sedentary:
        return s.workoutDaysText('2-3');
      case ActivityLevel.light:
      case ActivityLevel.moderate:
        return s.workoutDaysText('3-4');
      case ActivityLevel.active:
        return s.workoutDaysText('4-5');
      case ActivityLevel.veryActive:
        return s.workoutDaysText('5-6');
      default:
        return s.workoutDaysText('3-4');
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// HEADER
// ═══════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final String name;
  const _Header({required this.name});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;
    return Row(
      children: [
        Image.asset(
          'assets/images/apple_mascot/apple_hello.png',
          height: 56,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.analysisHello(name),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _kInk,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                s.analysisPlanReady,
                style: const TextStyle(fontSize: 14, color: _kMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HERO CARD — calo + macro
// ═══════════════════════════════════════════════════════════════

class _CalorieHeroCard extends StatelessWidget {
  final double kcal;
  final double protein;
  final double carb;
  final double fat;

  const _CalorieHeroCard({
    required this.kcal,
    required this.protein,
    required this.carb,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;

    return _FlatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.dailyCalorieTargetTitle,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _kMuted,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: kcal),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutExpo,
                builder: (context, value, _) => Text(
                  value > 0 ? value.toStringAsFixed(0) : '--',
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w300,
                    color: _kInk,
                    letterSpacing: -1.5,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  s.kcalPerDayUnit,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _kMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: _kBorder),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MacroStat(
                  label: 'Protein',
                  value: protein > 0 ? '${protein.toStringAsFixed(0)}g' : '--',
                ),
              ),
              Container(width: 1, height: 32, color: _kBorder),
              Expanded(
                child: _MacroStat(
                  label: 'Carb',
                  value: carb > 0 ? '${carb.toStringAsFixed(0)}g' : '--',
                ),
              ),
              Container(width: 1, height: 32, color: _kBorder),
              Expanded(
                child: _MacroStat(
                  label: 'Fat',
                  value: fat > 0 ? '${fat.toStringAsFixed(0)}g' : '--',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroStat extends StatelessWidget {
  final String label;
  final String value;
  const _MacroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _kInk,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: _kMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STAT CARD (BMI / Tập luyện)
// ═══════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String tag;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return _FlatCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: _kInk),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _kInk,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(tag, style: const TextStyle(fontSize: 11.5, color: _kMuted)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PROGRESS CARD
// ═══════════════════════════════════════════════════════════════

class _ProgressCard extends StatelessWidget {
  final double currentWeight;
  final double targetWeight;
  final int weeks;

  const _ProgressCard({
    required this.currentWeight,
    required this.targetWeight,
    required this.weeks,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;

    return _FlatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.yourJourneyTitle,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _kMuted,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _JourneyPoint(
                  icon: Icons.monitor_weight_outlined,
                  label: s.journeyCurrent,
                  value: s.weightKgValue(currentWeight.toStringAsFixed(0)),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 16, color: _kMuted),
              Expanded(
                child: _JourneyPoint(
                  icon: Icons.flag_outlined,
                  label: s.journeyTarget,
                  value: s.weightKgValue(targetWeight.toStringAsFixed(0)),
                  emphasize: true,
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 16, color: _kMuted),
              Expanded(
                child: _JourneyPoint(
                  icon: Icons.schedule_rounded,
                  label: s.journeyTimeframe,
                  value: s.weeksUnit(weeks),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 84,
            width: double.infinity,
            child: CustomPaint(
              painter: _LineChartPainter(
                startValue: currentWeight,
                endValue: targetWeight,
                lineColor: _kInk,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Container(
                    height: 5,
                    color: _kTrack,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.35,
                      child: Container(color: _kInk),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                s.completedPercent(35),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kInk,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JourneyPoint extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool emphasize;

  const _JourneyPoint({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: emphasize ? _kInk : _kMuted),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: _kMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: _kInk,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final double startValue;
  final double endValue;
  final Color lineColor;

  _LineChartPainter({
    required this.startValue,
    required this.endValue,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final w = size.width;
    const padding = 6.0;
    final drawH = h - padding * 2;
    final descending = startValue > endValue;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withOpacity(0.10), lineColor.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final path = Path();
    final fillPath = Path();
    const points = 24;

    for (int i = 0; i <= points; i++) {
      final t = i / points;
      final x = padding + t * (w - padding * 2);
      final eased = Curves.easeInOutCubic.transform(t);
      final y = padding + (descending ? eased : (1 - eased)) * drawH;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, h);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(w - padding, h);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    final startY = padding + (descending ? 0 : drawH);
    final endY = padding + (descending ? drawH : 0);

    canvas.drawCircle(
      Offset(padding, startY),
      3.5,
      Paint()..color = lineColor.withOpacity(0.35),
    );
    canvas.drawCircle(Offset(w - padding, endY), 4, Paint()..color = lineColor);
    canvas.drawCircle(
      Offset(w - padding, endY),
      7,
      Paint()..color = lineColor.withOpacity(0.15),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════
// MOTIVATION
// ═══════════════════════════════════════════════════════════════

class _MotivationCard extends StatelessWidget {
  final GoalType? goalType;
  final double remainingKg;

  const _MotivationCard({required this.goalType, required this.remainingKg});

  String _message(AppLocalizations s) {
    switch (goalType) {
      case GoalType.lose:
        return s.motivationAdviceLose(remainingKg.toStringAsFixed(0));
      case GoalType.gain:
        return s.motivationAdviceGain;
      case GoalType.maintain:
        return s.motivationAdviceMaintain;
      default:
        return s.motivationAdviceDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kInk,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.taoAdviceLabel,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _message(s),
            style: const TextStyle(
              fontSize: 14.5,
              color: Colors.white,
              height: 1.55,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAO SIGNATURE
// ═══════════════════════════════════════════════════════════════

class _TaoSignature extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _kInk.withOpacity(0.06),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Icon(Icons.eco_rounded, size: 14, color: _kInk),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            s.taoReminder,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: _kMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SHARED FLAT CARD
// ═══════════════════════════════════════════════════════════════

class _FlatCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _FlatCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder),
      ),
      child: child,
    );
  }
}
