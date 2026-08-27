import 'package:flutter/material.dart';

void showExpGainToast(BuildContext context, {required int exp, required String reason}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  bool removed = false;

  entry = OverlayEntry(
    builder: (context) => _ExpToastWidget(
      exp: exp,
      reason: reason,
      onDismissed: () {
        if (!removed) {
          removed = true;
          try {
            entry.remove();
          } catch (_) {}
        }
      },
    ),
  );

  overlay.insert(entry);
}

class _ExpToastWidget extends StatefulWidget {
  final int exp;
  final String reason;
  final VoidCallback onDismissed;

  const _ExpToastWidget({
    required this.exp,
    required this.reason,
    required this.onDismissed,
  });

  @override
  State<_ExpToastWidget> createState() => _ExpToastWidgetState();
}

class _ExpToastWidgetState extends State<_ExpToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: const Offset(0, -0.2),
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
    ));

    _ctrl.forward().then((_) {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF166534) : const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '+${widget.exp} EXP',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${widget.reason}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
