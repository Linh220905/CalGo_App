import 'package:flutter/material.dart';

class PremiumButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const PremiumButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    return GestureDetector(
      onTapDown: enabled ? (_) => _anim.forward() : null,
      onTapUp: enabled ? (_) => _anim.reverse() : null,
      onTapCancel: () => _anim.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, _) {
          final scale = _scale.value;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color:
                    enabled ? const Color(0xFF111111) : const Color(0xFFECECEC),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: const Color(0xFF111111).withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: widget.onPressed,
                  child: Center(
                    child: widget.loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.label,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: enabled
                                  ? Colors.white
                                  : const Color(0xFF7A7A7A),
                              letterSpacing: -0.2,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: color ?? const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFECECEC).withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 4))
          ]),
      child: child,
    );
  }
}

class InsightCard extends StatelessWidget {
  final String label, value;
  final String? subtitle;
  final IconData? icon;
  final Color? color;

  const InsightCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF111111);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: c.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.withOpacity(0.12))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (icon != null) ...[
          Icon(icon, color: c, size: 20),
          const SizedBox(height: 4)
        ],
        Text(label,
            style: const TextStyle(
                color: Color(0xFF7A7A7A),
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                color: c,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                fontFeatures: const [FontFeature.tabularFigures()])),
        if (subtitle != null) ...[
          const SizedBox(height: 1),
          Text(subtitle!,
              style: const TextStyle(fontSize: 11, color: Color(0xFF7A7A7A)))
        ],
      ]),
    );
  }
}

class OptionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selected ? const Color(0xFFFAFAFA) : const Color(0xFFFFFFFF),
          border: Border.all(
              color:
                  selected ? const Color(0xFF111111) : const Color(0xFFECECEC),
              width: selected ? 1.5 : 1),
        ),
        child: Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? const Color(0xFF111111)
                          : const Color(0xFF111111))),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!,
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF7A7A7A)))
              ],
            ]),
          ),
          if (selected)
            Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                    color: Color(0xFF111111), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 14)),
        ]),
      ),
    );
  }
}
