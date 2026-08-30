import 'package:flutter/material.dart';
import 'tao_widget.dart';

void showExpGainPrompt(
  BuildContext context, {
  required int exp,
  required String reason,
}) {
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

class _ExpToastWidgetState extends State<_ExpToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _entry;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..forward();
    _entry = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
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
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 12,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.96, end: 1).animate(_entry),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF20252A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF4ADE80).withValues(alpha: 0.6)
                    : const Color(0xFF22C55E).withValues(alpha: 0.55),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 52,
                  height: 52,
                  child: TaoWidget(expression: TaoExpression.happy, size: 52),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Bạn nhận được +${widget.exp} EXP',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Điểm đã được cộng từ ${widget.reason.toLowerCase()}.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFB8C2CC)
                              : const Color(0xFF64748B),
                          fontSize: 11,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: widget.onDismissed,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(58, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Nhận',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
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
