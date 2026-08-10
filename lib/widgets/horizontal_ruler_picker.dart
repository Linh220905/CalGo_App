import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom painted golden laurel branch icon matching the reference design
class LaurelBranchIcon extends StatelessWidget {
  final bool isLeft;
  final Color color;
  final double size;

  const LaurelBranchIcon({
    super.key,
    required this.isLeft,
    this.color = const Color(0xFFEAB308), // Golden Amber
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: isLeft ? 1 : -1,
      child: CustomPaint(
        size: Size(size * 0.75, size),
        painter: _LaurelBranchPainter(color: color),
      ),
    );
  }
}

class _LaurelBranchPainter extends CustomPainter {
  final Color color;
  _LaurelBranchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stemPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final leafPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Stem curve
    final path = Path();
    path.moveTo(size.width * 0.85, size.height * 0.95);
    path.quadraticBezierTo(
      size.width * 0.05,
      size.height * 0.5,
      size.width * 0.75,
      size.height * 0.05,
    );
    canvas.drawPath(path, stemPaint);

    // Leaves along the stem
    final leafPositions = [
      Offset(size.width * 0.65, size.height * 0.82),
      Offset(size.width * 0.35, size.height * 0.62),
      Offset(size.width * 0.28, size.height * 0.42),
      Offset(size.width * 0.45, size.height * 0.22),
      Offset(size.width * 0.70, size.height * 0.08),
    ];

    for (int i = 0; i < leafPositions.length; i++) {
      final pos = leafPositions[i];
      // Upper leaf
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(-0.55 - (i * 0.08));
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(-5, -2), width: 9.5, height: 4.5),
        leafPaint,
      );
      canvas.restore();

      // Lower leaf
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(0.45 + (i * 0.08));
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(5, -2), width: 9.5, height: 4.5),
        leafPaint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Horizontal Ruler Picker Widget
class HorizontalRulerPicker extends StatefulWidget {
  final double min;
  final double max;
  final double initialValue;
  final double step;
  final ValueChanged<double> onChanged;
  final Color needleColor;
  final double itemWidth;

  const HorizontalRulerPicker({
    super.key,
    required this.min,
    required this.max,
    required this.initialValue,
    this.step = 1.0,
    required this.onChanged,
    this.needleColor = const Color(0xFF111111),
    this.itemWidth = 14.0,
  });

  @override
  State<HorizontalRulerPicker> createState() => _HorizontalRulerPickerState();
}

class _HorizontalRulerPickerState extends State<HorizontalRulerPicker> {
  late ScrollController _scrollController;
  late double _currentValue;
  late int _totalItems;
  bool _isUserScrolling = false;
  bool _isSnapping = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue.clamp(widget.min, widget.max);
    _totalItems = ((widget.max - widget.min) / widget.step).round() + 1;
    final initialIndex = ((_currentValue - widget.min) / widget.step).round();
    _scrollController = ScrollController(
      initialScrollOffset: initialIndex * widget.itemWidth,
    );
  }

  @override
  void didUpdateWidget(HorizontalRulerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.min != widget.min ||
        oldWidget.max != widget.max ||
        oldWidget.step != widget.step) {
      _totalItems = ((widget.max - widget.min) / widget.step).round() + 1;
      _currentValue = widget.initialValue.clamp(widget.min, widget.max);
      final index = ((_currentValue - widget.min) / widget.step).round();
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(index * widget.itemWidth);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _isUserScrolling = true;
    } else if (notification is ScrollUpdateNotification) {
      if (!_scrollController.hasClients) return;
      final offset = _scrollController.offset;
      final rawIndex = offset / widget.itemWidth;
      final rawVal = widget.min + (rawIndex * widget.step);
      final clampedVal = rawVal.clamp(widget.min, widget.max);

      // Round to step
      final rounded = (clampedVal / widget.step).round() * widget.step;
      if ((rounded - _currentValue).abs() >= widget.step / 2) {
        try {
          HapticFeedback.selectionClick();
        } catch (_) {}
        setState(() {
          _currentValue = rounded;
        });
        widget.onChanged(rounded);
      }
    } else if (notification is ScrollEndNotification) {
      if (_isUserScrolling && _scrollController.hasClients) {
        _isUserScrolling = false;
        _snapToNearest();
      }
    }
  }

  void _snapToNearest() {
    if (!_scrollController.hasClients || _isSnapping) return;
    final targetIndex = ((_currentValue - widget.min) / widget.step).round();
    final targetOffset = targetIndex * widget.itemWidth;
    if ((_scrollController.offset - targetOffset).abs() > 0.5) {
      _isSnapping = true;
      _scrollController
          .animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
      )
          .whenComplete(() {
        _isSnapping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final sidePadding = containerWidth / 2 - widget.itemWidth / 2;

        return SizedBox(
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notif) {
                  _onScrollNotification(notif);
                  return false;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: sidePadding),
                  itemCount: _totalItems,
                  itemBuilder: (context, index) {
                    final val = widget.min + (index * widget.step);
                    final valInt = val.round();
                    final isMajor = (valInt % 10 == 0);
                    final isMid = (valInt % 5 == 0);

                    final double tickHeight =
                        isMajor ? 36.0 : (isMid ? 24.0 : 15.0);
                    final Color tickColor = isMajor
                        ? const Color(0xFF334155)
                        : (isMid
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFFE2E8F0));
                    final double tickWidth =
                        isMajor ? 2.2 : (isMid ? 1.8 : 1.2);

                    return Container(
                      width: widget.itemWidth,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: tickWidth,
                        height: tickHeight,
                        decoration: BoxDecoration(
                          color: tickColor,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Left edge fade overlay (non-crash alternative to ShaderMask)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 48,
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Color(0x00FFFFFF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ),
              // Right edge fade overlay
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 48,
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0x00FFFFFF), Colors.white],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ),

              // Center Needle Indicator (Orange Vertical Line)
              IgnorePointer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 3.5,
                      height: 42,
                      decoration: BoxDecoration(
                        color: widget.needleColor,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: widget.needleColor.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Full Card Wrapper combining Pill Switcher, Main Card, Laurel Wreaths, Ruler, and Scroll Hint
class HorizontalRulerPickerCard extends StatefulWidget {
  final double min;
  final double max;
  final double initialValue;
  final double step;
  final String primaryUnit; // e.g. 'kg' or 'cm'
  final String secondaryUnit; // e.g. 'lb' or 'ft'
  final double
      conversionFactor; // 1 primaryUnit = X secondaryUnits (e.g. 2.20462)
  final String headerTitle;
  final IconData headerIcon;
  final String scrollHintText;
  final ValueChanged<double> onChanged; // Always returns value in primary unit
  final bool compact;

  const HorizontalRulerPickerCard({
    super.key,
    required this.min,
    required this.max,
    required this.initialValue,
    this.step = 1.0,
    required this.primaryUnit,
    this.secondaryUnit = '',
    this.conversionFactor = 2.20462,
    required this.headerTitle,
    this.headerIcon = Icons.fitness_center_rounded,
    this.scrollHintText = '',
    required this.onChanged,
    this.compact = false,
  });

  @override
  State<HorizontalRulerPickerCard> createState() =>
      _HorizontalRulerPickerCardState();
}

class _HorizontalRulerPickerCardState extends State<HorizontalRulerPickerCard> {
  late bool _isPrimaryUnit;
  late double _currentPrimaryValue;

  @override
  void initState() {
    super.initState();
    _isPrimaryUnit = true;
    _currentPrimaryValue = widget.initialValue.clamp(widget.min, widget.max);
    // The picker visibly starts at this value, so it must also become part of
    // onboarding data even when the user accepts it without scrolling.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onChanged(_currentPrimaryValue);
    });
  }

  @override
  void didUpdateWidget(HorizontalRulerPickerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _currentPrimaryValue = widget.initialValue.clamp(widget.min, widget.max);
    }
  }

  String get _formattedValueString {
    if (_isPrimaryUnit) {
      return '${_currentPrimaryValue.round()}';
    }
    final converted = _currentPrimaryValue * widget.conversionFactor;
    if (widget.conversionFactor < 0.1 ||
        widget.secondaryUnit.toLowerCase() == 'ft') {
      return converted.toStringAsFixed(1);
    }
    return '${converted.round()}';
  }

  String get _displayUnitStr {
    return _isPrimaryUnit ? widget.primaryUnit : widget.secondaryUnit;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Unit Toggle Switch (e.g. kg / lb, cm / ft)
        if (widget.secondaryUnit.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _UnitPillButton(
                  label: widget.primaryUnit,
                  isSelected: _isPrimaryUnit,
                  onTap: () {
                    if (!_isPrimaryUnit) {
                      setState(() => _isPrimaryUnit = true);
                    }
                  },
                ),
                _UnitPillButton(
                  label: widget.secondaryUnit,
                  isSelected: !_isPrimaryUnit,
                  onTap: () {
                    if (_isPrimaryUnit) {
                      setState(() => _isPrimaryUnit = false);
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: widget.compact ? 10 : 20),
        ],

        // Main Rounded Card Container
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              horizontal: widget.compact ? 16 : 20,
              vertical: widget.compact ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C0F172A),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.headerIcon,
                    color: const Color(0xFF1E293B),
                    size: widget.compact ? 19 : 22,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.headerTitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: widget.compact ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: widget.compact ? 10 : 18),

              // Clean Numeric Value Display (Black Tone)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formattedValueString,
                    style: TextStyle(
                      fontSize: widget.compact ? 42 : 52,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0A0A0A),
                      height: 1.0,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _displayUnitStr,
                    style: TextStyle(
                      fontSize: widget.compact ? 16 : 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ],
              ),

              SizedBox(height: widget.compact ? 12 : 20),

              // Horizontal Ruler Picker
              HorizontalRulerPicker(
                min: widget.min,
                max: widget.max,
                initialValue: _currentPrimaryValue,
                step: widget.step,
                needleColor: const Color(0xFF111111),
                onChanged: (newVal) {
                  setState(() {
                    _currentPrimaryValue = newVal.clamp(widget.min, widget.max);
                  });
                  widget.onChanged(_currentPrimaryValue);
                },
              ),
            ],
          ),
        ),

        // Scroll Hint Text Below Card (if provided)
        if (widget.scrollHintText.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            widget.scrollHintText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ],
    );
  }
}

class _UnitPillButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnitPillButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF111111)
              : Colors.transparent, // Black active
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
