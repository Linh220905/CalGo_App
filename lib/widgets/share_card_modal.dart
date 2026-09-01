import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../utils/macro_colors.dart';

class CardMemoryData {
  final String dishName;
  final String? imageUrl;
  final double calories;
  final double carbs;
  final double protein;
  final double fat;
  final String brand;

  const CardMemoryData({
    required this.dishName,
    this.imageUrl,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    this.brand = 'CalGo',
  });
}

class ShareCardModal extends StatefulWidget {
  final CardMemoryData data;

  const ShareCardModal({
    super.key,
    required this.data,
  });

  static Future<void> show(BuildContext context, CardMemoryData data) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ShareCardModal(data: data),
    );
  }

  @override
  State<ShareCardModal> createState() => _ShareCardModalState();
}

class _ShareCardModalState extends State<ShareCardModal> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isProcessing = false;

  Future<Uint8List?> _captureCardBytes() async {
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      // 3.0 pixelRatio ensures high quality 1080p+ square image output
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing share card: $e');
      return null;
    }
  }

  Future<String?> _saveTempFile(Uint8List bytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'calgo_memory_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      debugPrint('Error saving temp share card file: $e');
      return null;
    }
  }

  Future<void> _handleSaveImage() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    final s = context.read<AppSettingsProvider>().strings;

    try {
      final bytes = await _captureCardBytes();
      if (bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(s.shareCreateFailed),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      final filePath = await _saveTempFile(bytes);
      if (filePath != null && mounted) {
        // Trigger native share file sheet so user can save directly to Photos/Gallery or Drive
        await Share.shareXFiles(
          [XFile(filePath)],
          text: widget.data.dishName,
          sharePositionOrigin: _sharePositionOrigin(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(s.shareExported),
              backgroundColor: Color(0xFF16A34A),
            ),
          );
        }
      }
    } catch (error) {
      debugPrint('Error opening image share sheet: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.shareCreateFailed)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleShareNative() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    final s = context.read<AppSettingsProvider>().strings;

    try {
      final bytes = await _captureCardBytes();
      if (bytes == null) return;

      final filePath = await _saveTempFile(bytes);
      if (filePath != null && mounted) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: s.sharePayload(
              widget.data.dishName, widget.data.calories.round()),
          sharePositionOrigin: _sharePositionOrigin(),
        );
      }
    } catch (error) {
      debugPrint('Error opening native share sheet: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.shareCreateFailed)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Rect? _sharePositionOrigin() {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final s = context.watch<AppSettingsProvider>().strings;
    final mediaQuery = MediaQuery.of(context);
    final availableHeight =
        mediaQuery.size.height - mediaQuery.viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.all(12),
      constraints: BoxConstraints(maxHeight: availableHeight * 0.92),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1D24) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white24
                          : Colors.black.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    s.shareResult,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.shareNutritionLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            // Card Preview Area (wrapped in RepaintBoundary)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: RepaintBoundary(
                  key: _cardKey,
                  child: _buildMemoryCardUI(),
                ),
              ),
            ),

            // Action buttons row
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: isDark
                              ? const Color(0xFF2C2A34)
                              : const Color(0xFFF1F5F9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          s.close,
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF475569),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _handleSaveImage,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: Text(
                          s.saveImage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _handleShareNative,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.share_rounded, size: 16),
                        label: Text(
                          s.share,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  /// 1:1 Square Card Memory Widget — Matches Web Template 1 exact design
  Widget _buildMemoryCardUI() {
    final d = widget.data;

    return AspectRatio(
      aspectRatio: 1.0, // 1:1 Square
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Food Image background
          if (d.imageUrl != null && d.imageUrl!.isNotEmpty)
            Image.network(
              d.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholderBackground(),
            )
          else
            _buildPlaceholderBackground(),

          // 2. Bottom Gradient Black Overlay (~48% height)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.12),
                    Colors.black.withOpacity(0.42),
                    Colors.black.withOpacity(0.70),
                    Colors.black.withOpacity(0.88),
                  ],
                  stops: const [0.0, 0.52, 0.65, 0.78, 0.90, 1.0],
                ),
              ),
            ),
          ),

          // 3. Brand Watermark Top-Left
          Positioned(
            left: 16,
            top: 16,
            child: Text(
              d.brand,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 6,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),

          // 4. Bottom Information Block (Divider -> Calorie -> Macros)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Divider Line
                Container(
                  width: 48,
                  height: 1,
                  color: Colors.white.withOpacity(0.2),
                ),
                const SizedBox(height: 12),

                // Hero Calorie Row: 🔥 550 kcal
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '🔥',
                      style: TextStyle(
                        fontSize: 24,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${d.calories.round()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        height: 1.0,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'kcal',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        shadows: const [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Macro Row: Carbs (C), Protein (P), Fat (F)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMacroBadge(
                      label: 'C',
                      value: d.carbs,
                      color: MacroColors.carb,
                      bgColor: MacroColors.carb.withOpacity(0.25),
                    ),
                    const SizedBox(width: 16),
                    _buildMacroBadge(
                      label: 'P',
                      value: d.protein,
                      color: MacroColors.protein,
                      bgColor: MacroColors.protein.withOpacity(0.25),
                    ),
                    const SizedBox(width: 16),
                    _buildMacroBadge(
                      label: 'F',
                      value: d.fat,
                      color: MacroColors.fat,
                      bgColor: MacroColors.fat.withOpacity(0.25),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBadge({
    required String label,
    required double value,
    required Color color,
    required Color bgColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '${value.round()}g',
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            shadows: const [
              Shadow(
                color: Colors.black45,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderBackground() {
    return Container(
      color: const Color(0xFF292832),
      alignment: Alignment.center,
      child: const Icon(
        Icons.restaurant_rounded,
        size: 56,
        color: Colors.white38,
      ),
    );
  }
}
