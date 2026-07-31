import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Cal AI style accent — swap this for your app's accent color if different.
const _kAccent = Color(0xFFFF3B30);
const _kInk = Color(0xFF0A0A0A);
const _kMuted = Color(0xFFB0B0B5);
const _kSurface = Color(0xFFF4F4F6);
const _kBorder = Color(0xFFE8E8EB);

class NumberWheelPicker extends StatefulWidget {
  final int min, max, initialValue;
  final String suffix;
  final ValueChanged<int> onChanged;

  const NumberWheelPicker({
    super.key,
    required this.min,
    required this.max,
    required this.initialValue,
    this.suffix = '',
    required this.onChanged,
  });

  @override
  State<NumberWheelPicker> createState() => _NumberWheelPickerState();
}

class _NumberWheelPickerState extends State<NumberWheelPicker> {
  late FixedExtentScrollController _scroll;
  late int _value;
  double _continuous = 0;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue.clamp(widget.min, widget.max);
    _continuous = (_value - widget.min).toDouble();
    _scroll = FixedExtentScrollController(initialItem: _value - widget.min);
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.onChanged(_value));
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    setState(() => _continuous = _scroll.offset / 56);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _step(int delta) {
    final target =
        (_value - widget.min + delta).clamp(0, widget.max - widget.min);
    HapticFeedback.selectionClick();
    _scroll.animateToItem(target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.max - widget.min + 1;
    return SizedBox(
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Faint centerline instead of a boxed pill — reads as a rail, not a button
          // Container( ... ),
          Row(
            children: [
              _StepButton(
                icon: Icons.remove_rounded,
                enabled: _value > widget.min,
                onTap: () => _step(-1),
              ),
              Expanded(
                child: ListWheelScrollView(
                  controller: _scroll,
                  itemExtent: 56,
                  diameterRatio: 1.35,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (i) {
                    HapticFeedback.mediumImpact();
                    _value = widget.min + i;
                    widget.onChanged(_value);
                  },
                  children: List.generate(count, (i) {
                    final val = widget.min + i;
                    final dist = (i - _continuous).abs().clamp(0.0, 3.0);
                    final t = (1 - dist / 3)
                        .clamp(0.0, 1.0); // 1 at center, 0 far away
                    final scale = 0.62 + 0.38 * t;
                    final weight = t > 0.85 ? FontWeight.w800 : FontWeight.w600;
                    return Center(
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: 0.18 + 0.82 * t,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$val',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: weight,
                                    color: _kInk,
                                    letterSpacing: -0.5,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ],
                                  )),
                              if (widget.suffix.isNotEmpty && t > 0.85) ...[
                                const SizedBox(width: 5),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(widget.suffix,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: _kInk,
                                      )),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              _StepButton(
                icon: Icons.add_rounded,
                enabled: _value < widget.max,
                onTap: () => _step(1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepButton(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Material(
        color: enabled ? _kInk : _kSurface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: Icon(icon, size: 18, color: enabled ? Colors.white : _kMuted),
        ),
      ),
    );
  }
}

class RulerPicker extends StatefulWidget {
  final double min, max, initialValue, step;
  final String suffix;
  final ValueChanged<double> onChanged;

  const RulerPicker({
    super.key,
    required this.min,
    required this.max,
    required this.initialValue,
    this.suffix = '',
    this.step = 1,
    required this.onChanged,
  });

  @override
  State<RulerPicker> createState() => _RulerPickerState();
}

class _RulerPickerState extends State<RulerPicker>
    with SingleTickerProviderStateMixin {
  late FixedExtentScrollController _scroll;
  late double _value;
  late int _itemCount;
  late AnimationController _pop;
  double _continuous = 0;

  static const double _tickExtent = 16;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue.clamp(widget.min, widget.max);
    _itemCount = ((widget.max - widget.min) / widget.step).round() + 1;
    final startItem = ((_value - widget.min) / widget.step).round();
    _continuous = startItem.toDouble();
    _scroll = FixedExtentScrollController(initialItem: startItem);
    _scroll.addListener(_onScroll);
    _pop = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 140),
        lowerBound: 0,
        upperBound: 1)
      ..value = 1;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.onChanged(_value));
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    setState(() => _continuous = _scroll.offset / _tickExtent);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _pop.dispose();
    super.dispose();
  }

  void _bump() {
    _pop.forward(from: 0.65);
  }

  @override
  Widget build(BuildContext context) {
    final range = widget.max - widget.min;
    final majorEvery = range > 80 ? 10 : 5;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final rulerScale = (availableHeight / 220).clamp(0.5, 1.0);
        final bigFontSize = (76 * rulerScale).clamp(28.0, 76.0);
        final rulerHeight = (availableHeight * 0.55).clamp(40.0, 96.0);
        final headlineHeight = (availableHeight * 0.4).clamp(32.0, 96.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Big headline value
            SizedBox(
              height: headlineHeight,
              child: Center(
                child: AnimatedBuilder(
                  animation: _pop,
                  builder: (context, child) => Transform.scale(
                    scale: 0.94 + 0.06 * _pop.value,
                    child: child,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _value == _value.roundToDouble()
                            ? '${_value.toInt()}'
                            : _value.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: bigFontSize,
                          fontWeight: FontWeight.w800,
                          color: _kInk,
                          letterSpacing: -3.5,
                          height: 1.0,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (widget.suffix.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            widget.suffix,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _kInk,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: rulerHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ListWheelScrollView(
                    controller: _scroll,
                    itemExtent: _tickExtent,
                    diameterRatio: 8,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (i) {
                      HapticFeedback.mediumImpact();
                      _value = widget.min + i * widget.step;
                      widget.onChanged(_value);
                      _bump();
                    },
                    children: List.generate(_itemCount, (i) {
                      final val = widget.min + i * widget.step;
                      final valInt = val.toInt();
                      final isMajor = valInt % majorEvery == 0;
                      final isMid = valInt % (majorEvery ~/ 2) == 0;

                      final dist = (i - _continuous).abs();
                      final proximity = (1 - (dist / 2.4)).clamp(0.0, 1.0);
                      final baseHeight = isMajor ? 34.0 : (isMid ? 24.0 : 16.0);
                      final height = baseHeight + (26 * proximity);
                      final tickColor = Color.lerp(
                        isMajor ? _kInk.withOpacity(0.45) : _kBorder,
                        _kInk,
                        proximity,
                      );

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isMajor)
                            Opacity(
                              opacity: 0.35 + 0.65 * proximity,
                              child: Text(
                                '$valInt',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: proximity > 0.7 ? _kInk : _kMuted,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 13),
                          const SizedBox(height: 6),
                          Container(
                            width: isMajor ? 2.6 : (isMid ? 2 : 1.4),
                            height: height,
                            decoration: BoxDecoration(
                              color: tickColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  IgnorePointer(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: const BoxDecoration(
                              color: _kInk, shape: BoxShape.circle),
                        ),
                        Container(
                          width: 2.5,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _kInk,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                  color: _kAccent.withOpacity(0.35),
                                  blurRadius: 6),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
