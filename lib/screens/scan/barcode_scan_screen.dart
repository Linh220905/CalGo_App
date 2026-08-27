import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../services/scan_service.dart';
import '../../providers/gamification_provider.dart';

const Color _kScanGreen = Color(0xFF22C55E);

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _isProcessing = false;
  bool _isFlashOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    await _controller.toggleTorch();
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcodeStr = barcodes.first.rawValue;
    if (barcodeStr == null || barcodeStr.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final scanService = context.read<ScanService>();
      final result = await scanService.scanBarcode(barcodeStr.trim());

      if (!mounted) return;
      if (result.expEarned > 0) {
        context
            .read<GamificationProvider>()
            .registerScanReward(result.expEarned);
      }
      unawaited(context.read<GamificationProvider>().refreshRecap());
      context.go('/result/${result.id}');
    } catch (e) {
      if (!mounted) return;

      String errorMsg =
          "Chưa tìm thấy dữ liệu cho mã vạch này. Bạn hãy thử chụp trực tiếp ảnh món ăn nhé! 📸";
      final eStr = e.toString().toLowerCase();
      if (eStr.contains("404") ||
          eStr.contains("không tìm thấy") ||
          eStr.contains("chưa có")) {
        errorMsg =
            "Chưa tìm thấy dữ liệu cho mã vạch này. Bạn hãy thử chụp trực tiếp ảnh món ăn nhé! 📸";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 3),
        ),
      );

      // Re-enable scanning after short delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Realtime Camera Barcode Scanner ────
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // ── Scanner Overlay Frame ────
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const Text(
                        "Quét mã vạch",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleFlash,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: _isFlashOn ? Colors.yellow : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Center Scan Frame Box
                Center(
                  child: Container(
                    width: 280,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: _kScanGreen, width: 2.5),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black.withOpacity(0.1),
                    ),
                    child: Stack(
                      children: [
                        if (_isProcessing)
                          const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: _kScanGreen),
                                SizedBox(height: 12),
                                Text(
                                  "Đang tra cứu mã vạch...",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  "Di chuyển camera vào mã vạch trên bao bì",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),

                const Spacer(),

                // Switch to Camera Image Scan Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Chuyển sang chụp ảnh món",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
