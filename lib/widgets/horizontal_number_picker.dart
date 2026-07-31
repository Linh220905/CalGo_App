import 'package:flutter/material.dart';

class HorizontalNumberPicker extends StatefulWidget {
  final int min;
  final int max;
  final int initialValue;
  final String suffix;
  final ValueChanged<int> onChanged;
  final Color accentColor;

  const HorizontalNumberPicker({
    super.key,
    required this.min,
    required this.max,
    this.initialValue = 170,
    this.suffix = '',
    required this.onChanged,
    this.accentColor = const Color(0xFF2563EB),
  });

  @override
  State<HorizontalNumberPicker> createState() => _HorizontalNumberPickerState();
}

class _HorizontalNumberPickerState extends State<HorizontalNumberPicker> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue.clamp(widget.min, widget.max);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.max - widget.min;
    final fraction = total > 0 ? (_value - widget.min) / total : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('$_value',
                style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w200,
                    color: widget.accentColor,
                    height: 1)),
            if (widget.suffix.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.only(bottom: 12, left: 4),
                  child: Text(widget.suffix,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: widget.accentColor.withOpacity(0.7)))),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 40,
          child: LayoutBuilder(builder: (ctx, constraints) {
            final w = constraints.maxWidth;
            return GestureDetector(
              onTapDown: (d) => _set(d.localPosition.dx, w),
              onHorizontalDragUpdate: (d) => _set(d.localPosition.dx, w),
              child: Stack(alignment: Alignment.centerLeft, children: [
                Container(
                    height: 6,
                    width: w,
                    decoration: BoxDecoration(
                        color: const Color(0xFFE5E5E5),
                        borderRadius: BorderRadius.circular(3))),
                Container(
                    height: 6,
                    width: w * fraction,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          widget.accentColor.withOpacity(0.4),
                          widget.accentColor
                        ]),
                        borderRadius: BorderRadius.circular(3))),
                Positioned(
                  left: (w * fraction) - 14,
                  child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: widget.accentColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2))
                          ]),
                      child: Center(
                          child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                  color: widget.accentColor,
                                  shape: BoxShape.circle)))),
                ),
              ]),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${widget.min}${widget.suffix}',
              style: const TextStyle(fontSize: 13, color: Color(0xFFD2D2D7))),
          Text('${widget.max}${widget.suffix}',
              style: const TextStyle(fontSize: 13, color: Color(0xFFD2D2D7))),
        ]),
      ],
    );
  }

  void _set(double dx, double w) {
    if (w <= 0) return;
    final f = (dx / w).clamp(0.0, 1.0);
    final v = (widget.min + f * (widget.max - widget.min)).round();
    final clamped = v.clamp(widget.min, widget.max);
    if (clamped != _value) {
      setState(() => _value = clamped);
      widget.onChanged(clamped);
    }
  }
}
