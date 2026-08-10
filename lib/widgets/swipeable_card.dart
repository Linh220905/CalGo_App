import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';

class SwipeableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;
  final String? confirmMessage;

  const SwipeableCard({
    super.key,
    required this.child,
    required this.onDelete,
    this.confirmMessage,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  static const double _deleteWidth = 80;
  static const double _swipeThreshold = 60;
  static const double _resetThreshold = 30;

  bool _open = false;
  bool _confirmOpen = false;
  double _dx = 0;

  void _onPanStart(DragStartDetails d) {
    _dx = _open ? _deleteWidth : 0;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final newDx = (_dx - d.delta.dx).clamp(0, _deleteWidth).toDouble();
    if (newDx == _dx) return;
    _dx = newDx;
    setState(() {});
  }

  void _onPanEnd(DragEndDetails _) {
    if (_open) {
      if (_dx < _deleteWidth - _resetThreshold) {
        setState(() {
          _open = false;
          _dx = 0;
        });
      } else {
        setState(() {
          _dx = _deleteWidth;
        });
      }
      return;
    }
    if (_dx >= _swipeThreshold) {
      setState(() {
        _open = true;
        _dx = _deleteWidth;
      });
    } else {
      setState(() {
        _dx = 0;
      });
    }
  }

  void _handleDeletePress() {
    setState(() {
      _open = false;
      _dx = 0;
    });
    if (widget.confirmMessage != null) {
      setState(() => _confirmOpen = true);
    } else {
      widget.onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Delete button (always right-aligned within stack width)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: AnimatedOpacity(
                opacity: _open ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: _handleDeletePress,
                  child: Container(
                    width: _deleteWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.delete_outline_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),
            // Foreground card
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              transform: Matrix4.identity()
                ..translate(_open ? -_deleteWidth : 0.0),
              transformAlignment: Alignment.centerLeft,
              width: cardWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GestureDetector(
                  onHorizontalDragStart: _onPanStart,
                  onHorizontalDragUpdate: _onPanUpdate,
                  onHorizontalDragEnd: _onPanEnd,
                  onTap: _open
                      ? () => setState(() {
                            _open = false;
                            _dx = 0;
                          })
                      : null,
                  child: widget.child,
                ),
              ),
            ),
            // Confirm dialog overlay
            if (_confirmOpen)
              GestureDetector(
                onTap: () => setState(() => _confirmOpen = false),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 50,
                              offset: const Offset(0, 25),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.warning_rounded,
                                  color: Color(0xFFEF4444), size: 24),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.confirmMessage ?? s.deleteMealQuestion,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _confirmOpen = false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(s.cancel,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => _confirmOpen = false);
                                      widget.onDelete();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDC2626),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(s.deleteAction,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
