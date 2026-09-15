import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double rotation;
  double rotationSpeed;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class ConfettiCelebrationOverlay extends StatefulWidget {
  final Widget child;
  final bool isPlaying;

  const ConfettiCelebrationOverlay({
    super.key,
    required this.child,
    required this.isPlaying,
  });

  @override
  State<ConfettiCelebrationOverlay> createState() =>
      _ConfettiCelebrationOverlayState();
}

class _ConfettiCelebrationOverlayState extends State<ConfettiCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();

  static const List<Color> _colors = [
    Color(0xFFFF595E),
    Color(0xFFFFCA3A),
    Color(0xFF8AC926),
    Color(0xFF1982C4),
    Color(0xFF6A4C93),
    Color(0xFFFF924C),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..addListener(_updateParticles);

    if (widget.isPlaying) {
      _startConfetti();
    }
  }

  @override
  void didUpdateWidget(covariant ConfettiCelebrationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isPlaying && widget.isPlaying) {
      _startConfetti();
    }
  }

  void _startConfetti() {
    _particles.clear();
    for (int i = 0; i < 70; i++) {
      _particles.add(
        ConfettiParticle(
          x: _random.nextDouble(),
          y: -0.1 - _random.nextDouble() * 0.4,
          vx: (_random.nextDouble() - 0.5) * 0.008,
          vy: 0.008 + _random.nextDouble() * 0.012,
          size: 6 + _random.nextDouble() * 8,
          color: _colors[_random.nextInt(_colors.length)],
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
        ),
      );
    }
    _controller.forward(from: 0);
  }

  void _updateParticles() {
    for (var p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.rotation += p.rotationSpeed;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_controller.isAnimating)
          IgnorePointer(
            child: CustomPaint(
              painter: _ConfettiPainter(particles: _particles),
            ),
          ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final px = p.x * size.width;
      final py = p.y * size.height;

      if (py > size.height + 20) continue;

      final paint = Paint()..color = p.color;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
