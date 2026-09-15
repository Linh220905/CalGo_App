import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../widgets/confetti_celebration_overlay.dart';
import 'discount_offer_paywall_step.dart';

const _kInk = Color(0xFF111111);

TextStyle _f(
  double size, {
  FontWeight weight = FontWeight.w500,
  Color color = _kInk,
  double? height,
  double? letterSpacing,
}) => GoogleFonts.plusJakartaSans(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
  letterSpacing: letterSpacing,
);

class SpinWheelDialog extends StatefulWidget {
  final VoidCallback onDismiss;

  const SpinWheelDialog({super.key, required this.onDismiss});

  static Future<void> show(BuildContext context, {required VoidCallback onDismiss}) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'SpinWheel',
      barrierColor: Colors.black.withValues(alpha: 0.7),
      pageBuilder: (ctx, anim1, anim2) => SpinWheelDialog(onDismiss: onDismiss),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, anim1, anim2, child) =>
          FadeTransition(opacity: anim1, child: child),
    );
  }

  @override
  State<SpinWheelDialog> createState() => _SpinWheelDialogState();
}

class _SpinWheelDialogState extends State<SpinWheelDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  bool _isSpinning = false;
  bool _hasSpun = false;
  bool _showConfetti = false;

  // Slices: 6 parts = 60 deg each
  // Index 4 is the Gift / Jackpot Slice
  final List<_WheelSlice> _slices = const [
    _WheelSlice(label: '30%', isBlack: true),
    _WheelSlice(label: '60%', isBlack: false),
    _WheelSlice(label: 'Quà', isGift: true, isBlack: true),
    _WheelSlice(label: '50%', isBlack: false),
    _WheelSlice(label: '70%', isBlack: true),
    _WheelSlice(label: '↻', isBlack: false),
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500), // Quay chậm, kịch tính hơn
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _startSpin() {
    if (_isSpinning || _hasSpun) return;
    setState(() {
      _isSpinning = true;
      _hasSpun = true;
    });

    // Center of Gift slice (index 2: 120° to 180°) = 150° (5pi/6)
    // Top arrow is at 270° (3pi/2).
    // Rotation angle theta so that (150° + theta) % 360° = 270°
    // theta = 270° - 150° = 120° = (2pi / 3) = 0.6666 * pi
    const fullTurns = 7.0 * 2 * pi;
    const targetOffset = 2 * pi / 3;
    const targetAngle = fullTurns + targetOffset;

    _spinAnimation = Tween<double>(begin: 0, end: targetAngle).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    )..addListener(() => setState(() {}));

    _spinController.forward().then((_) {
      setState(() {
        _isSpinning = false;
        _showConfetti = true;
      });

      // Delay to let user enjoy the confetti celebration, then navigate to One-time Offer
      Timer(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        Navigator.pop(context); // Close wheel dialog
        DiscountOfferPaywallStep.show(context, onDismiss: widget.onDismiss);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ConfettiCelebrationOverlay(
        isPlaying: _showConfetti,
        child: SafeArea(
          child: Column(
            children: [
              // Top Close
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        widget.onDismiss();
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: _kInk,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  s.spinWheelTitle,
                  textAlign: TextAlign.center,
                  style: _f(25, weight: FontWeight.w800, height: 1.25),
                ),
              ),

              const Spacer(flex: 2),

              // Wheel Widget with Pointer (Larger & Premium)
              Center(
                child: GestureDetector(
                  onTap: _isSpinning ? null : _startSpin,
                  child: SizedBox(
                    width: 320,
                    height: 320,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Spinning Wheel Canvas
                        Transform.rotate(
                          angle: _isSpinning || _hasSpun ? _spinAnimation.value : 0,
                          child: CustomPaint(
                            size: const Size(310, 310),
                            painter: _WheelPainter(slices: _slices),
                          ),
                        ),

                        // Center CalGo Mascot Hub
                        Container(
                          width: 66,
                          height: 66,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: _kInk, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Image.asset(
                              'assets/images/apple_mascot/apple_paywall.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        // Top Indicator Arrow Pointer
                        Positioned(
                          top: 0,
                          child: CustomPaint(
                            size: const Size(26, 26),
                            painter: _ArrowPointerPainter(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // Spin / Continue Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSpinning ? null : _startSpin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kInk,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      _hasSpun ? s.claimOfferBtn : s.spinWheelBtn,
                      style: _f(16, weight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelSlice {
  final String label;
  final bool isGift;
  final bool isBlack;

  const _WheelSlice({
    required this.label,
    this.isGift = false,
    required this.isBlack,
  });
}

class _WheelPainter extends CustomPainter {
  final List<_WheelSlice> slices;

  _WheelPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweepAngle = 2 * pi / slices.length;

    // Outer border
    final borderPaint = Paint()
      ..color = _kInk
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    for (int i = 0; i < slices.length; i++) {
      final slice = slices[i];
      final startAngle = i * sweepAngle;

      final slicePaint = Paint()
        ..color = slice.isBlack ? _kInk : Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        slicePaint,
      );

      // Draw text or gift icon
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(startAngle + sweepAngle / 2);

      if (slice.isGift) {
        // High quality gift icon with ribbon details drawn cleanly
        final iconColor = slice.isBlack ? Colors.white : _kInk;
        final iconSpan = TextSpan(
          text: String.fromCharCode(Icons.card_giftcard_rounded.codePoint),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            fontFamily: Icons.card_giftcard_rounded.fontFamily,
            package: Icons.card_giftcard_rounded.fontPackage,
            color: iconColor,
          ),
        );
        final tp = TextPainter(
          text: iconSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(radius * 0.52, -tp.height / 2));
      } else {
        final textSpan = TextSpan(
          text: slice.label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: slice.label == '↻' ? 24 : 18,
            fontWeight: FontWeight.w900,
            color: slice.isBlack ? Colors.white : _kInk,
          ),
        );
        final tp = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(radius * 0.52, -tp.height / 2));
      }

      canvas.restore();
    }

    // Outer circle stroke
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArrowPointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _kInk
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
