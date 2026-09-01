import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../services/health_service.dart';

class AppleHealthPermissionStep extends StatefulWidget {
  const AppleHealthPermissionStep({super.key});

  @override
  State<AppleHealthPermissionStep> createState() =>
      _AppleHealthPermissionStepState();
}

class _AppleHealthPermissionStepState
    extends State<AppleHealthPermissionStep> {
  bool _loading = false;

  Future<void> _handleContinue() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await HealthService().requestAuthorization();
    } catch (e) {
      debugPrint('Error requesting HealthKit permission: $e');
    }
    if (mounted) {
      context.read<OnboardingProvider>().nextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppSettingsProvider>().isDarkMode;
    final s = context.watch<AppSettingsProvider>().strings;

    final bgColor = isDark ? const Color(0xFF131217) : Colors.white;
    final circleBg = isDark ? const Color(0xFF1E1B26) : const Color(0xFFF4F4F8);
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final pillBg = isDark ? const Color(0xFF262332) : Colors.white;
    final pillText = isDark ? Colors.white : const Color(0xFF1E1B26);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Illustration Area
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background Circle Blob
                        Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: circleBg,
                          ),
                        ),

                        // Curved Connecting Line & Checkmark
                        Positioned(
                          child: CustomPaint(
                            size: const Size(160, 120),
                            painter: _ConnectionPainter(
                              color: isDark
                                  ? const Color(0xFF475569)
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                        ),

                        // Center Checkmark Badge
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF10B981),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),

                        // Apple Health (Heart) Card - Bottom Left
                        Positioned(
                          left: 20,
                          bottom: 50,
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF272533)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [
                                    Color(0xFFFF2D55),
                                    Color(0xFFFF5E3A),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ).createShader(bounds),
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  size: 42,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Apple Logo Card - Top Right
                        Positioned(
                          right: 30,
                          top: 40,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2C2A38)
                                  : const Color(0xFF1E1B26),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.apple_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Floating Pill Badges
                        // "Walking" - Top Left
                        Positioned(
                          left: 15,
                          top: 45,
                          child: _buildBadge('Walking', pillBg, pillText, isDark),
                        ),

                        // "Running" - Mid Left
                        Positioned(
                          left: 0,
                          top: 95,
                          child: _buildBadge('Running', pillBg, pillText, isDark),
                        ),

                        // "Yoga" - Mid Right
                        Positioned(
                          right: 15,
                          bottom: 110,
                          child: _buildBadge('Yoga', pillBg, pillText, isDark),
                        ),

                        // "Sleep" - Bottom Right
                        Positioned(
                          right: 30,
                          bottom: 60,
                          child: _buildBadge('Sleep', pillBg, pillText, isDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title Header
              Text(
                s.connectAppleHealthTitle,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle Description
              Text(
                s.connectAppleHealthDesc,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 32),

              // Continue Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? Colors.white : const Color(0xFF1E1B26),
                    foregroundColor:
                        isDark ? const Color(0xFF1E1B26) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: isDark
                                ? const Color(0xFF1E1B26)
                                : Colors.white,
                          ),
                        )
                      : Text(
                          s.continueLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
      String label, Color bg, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _ConnectionPainter extends CustomPainter {
  final Color color;

  _ConnectionPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path1 = Path();
    path1.moveTo(25, 100);
    path1.cubicTo(25, 40, 75, 55, 80, 50);
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.moveTo(135, 20);
    path2.cubicTo(135, 70, 85, 65, 80, 70);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
