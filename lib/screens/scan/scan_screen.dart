import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/scan_service.dart';

const List<String> _kAiMessages = [
  'Đang nhận diện món ăn...',
  'Đã nhận diện món ăn',
  'Đang phân tích nguyên liệu...',
  'Xác định thành phần dinh dưỡng...',
  'Đang tính toán calories...',
  'Ước lượng khẩu phần ăn...',
  'AI đang tổng hợp kết quả...',
  'Chuẩn bị báo cáo...',
];

const Color _kScanGreen = Color(0xFF4ADE80);

Future<String> _readAndEncodeImage(String path) async {
  final bytes = await File(path).readAsBytes();
  return base64Encode(bytes);
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _scanAnimationController;
  CameraController? _cameraController;

  File? _selectedImageFile;
  bool _isCameraStarting = true;
  bool _isTakingPicture = false;
  bool _isAnalyzing = false;
  int _aiMsgIndex = 0;
  Timer? _aiTimer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissionAndStartCamera();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _scanAnimationController.dispose();
    _aiTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      final controller = _cameraController;
      _cameraController = null;
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed &&
        _selectedImageFile == null) {
      _requestPermissionAndStartCamera();
    }
  }

  Future<void> _requestPermissionAndStartCamera() async {
    if (!mounted || _selectedImageFile != null) return;

    setState(() {
      _isCameraStarting = true;
      _errorMessage = null;
    });

    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (!mounted) return;
    if (!status.isGranted) {
      setState(() {
        _isCameraStarting = false;
        _errorMessage = status.isPermanentlyDenied
            ? 'Quyền Máy ảnh đã bị từ chối. Hãy mở Cài đặt và cấp quyền Máy ảnh cho CalGo!'
            : 'CalGo cần quyền Máy ảnh để quét món ăn.';
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('no_camera', 'Không tìm thấy camera');
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();

      if (!mounted || _selectedImageFile != null) {
        await controller.dispose();
        return;
      }

      await _cameraController?.dispose();
      setState(() {
        _cameraController = controller;
        _isCameraStarting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isCameraStarting = false;
        _errorMessage =
            'Không thể khởi động camera. Vui lòng đóng màn hình và thử lại!';
      });
    }
  }

  Widget _buildCameraPreview() {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: const Color(0xFF111111),
        child: Center(
          child: _isCameraStarting
              ? const CircularProgressIndicator(color: _kScanGreen)
              : const Icon(
                  Icons.camera_alt_outlined,
                  size: 64,
                  color: Color(0xFF333333),
                ),
        ),
      );
    }

    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final previewSize = controller.value.previewSize!;
          final previewAspectRatio = previewSize.height / previewSize.width;
          final screenAspectRatio =
              constraints.maxWidth / constraints.maxHeight;
          return Transform.scale(
            scale: previewAspectRatio / screenAspectRatio,
            child: Center(child: CameraPreview(controller)),
          );
        },
      ),
    );
  }

  void _startAiStatusSequence() {
    setState(() {
      _isAnalyzing = true;
      _aiMsgIndex = 0;
      _errorMessage = null;
    });

    _aiTimer?.cancel();
    _aiTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) return;
      setState(() {
        if (_aiMsgIndex < _kAiMessages.length - 1) {
          _aiMsgIndex++;
        }
      });
    });
  }

  void _stopAiStatusSequence() {
    _aiTimer?.cancel();
    if (mounted) {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _analyzeImage(File file) async {
    final scanService = context.read<ScanService>();
    final authProvider = context.read<AuthProvider>();
    try {
      setState(() {
        _selectedImageFile = file;
      });
      final base64Str = await compute(_readAndEncodeImage, file.path);
      _startAiStatusSequence();
      final result = await scanService.scanMeal(base64Str);
      _stopAiStatusSequence();
      if (mounted) {
        authProvider.refreshUser();
        context.pushReplacement('/result/${result.id}');
      }
    } catch (e) {
      _handleScanError(e);
    }
  }

  Future<void> _showStillImageAndReleaseCamera(File file) async {
    final controller = _cameraController;
    if (!mounted) return;

    // Detach CameraPreview from the widget tree before disposing its
    // controller. Disposing first can render one red error frame while the
    // preview still references the old controller.
    setState(() {
      _selectedImageFile = file;
      _cameraController = null;
    });
    await WidgetsBinding.instance.endOfFrame;
    await controller?.dispose();
  }

  Future<void> _pickGalleryImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image == null || !mounted) return;
      final file = File(image.path);
      await _showStillImageAndReleaseCamera(file);
      await _analyzeImage(file);
    } catch (e) {
      _handleScanError(e);
    }
  }

  Future<void> _captureAndAnalyze() async {
    final controller = _cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture ||
        _isTakingPicture) {
      return;
    }
    setState(() => _isTakingPicture = true);
    try {
      final image = await controller.takePicture();
      if (!mounted) return;
      final file = File(image.path);
      await _showStillImageAndReleaseCamera(file);
      await _analyzeImage(file);
    } catch (e) {
      _handleScanError(e);
    } finally {
      if (mounted) setState(() => _isTakingPicture = false);
    }
  }

  void _handleScanError(Object e) {
    _stopAiStatusSequence();
    final errStr = e.toString().toLowerCase();
    if (errStr.contains('401') || errStr.contains('unauthorized')) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Bạn chưa đăng nhập. Vui lòng đăng nhập bằng Google để sử dụng tính năng này!';
        });
      }
    } else if (errStr.contains('camera_access_denied') ||
        errStr.contains('permission') ||
        errStr.contains('denied')) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Chưa được cấp quyền Máy ảnh. Vui lòng bật quyền Máy ảnh cho CalGo trong Cài đặt điện thoại!';
        });
      }
    } else if (errStr.contains('insufficient_credits') ||
        errStr.contains('credits') ||
        errStr.contains('402')) {
      if (mounted) {
        _showInsufficientCreditsDialog();
      }
    } else if (errStr.contains('timeout') ||
        errStr.contains('socketexception') ||
        errStr.contains('connection')) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Kết nối mạng yếu hoặc quá thời gian chờ. Vui lòng kiểm tra lại 4G/Wi-Fi!';
        });
      }
    } else {
      if (mounted) {
        final cleanMsg = e
            .toString()
            .replaceAll('ApiException', '')
            .replaceAll('Exception:', '')
            .trim();
        _errorMessage =
            'Không thể phân tích ảnh ($cleanMsg). Vui lòng thử lại!';
        setState(() {});
      }
    }
  }

  void _showInsufficientCreditsDialog() {
    final settings = context.read<AppSettingsProvider>();
    final s = settings.strings;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor:
            settings.isDarkMode ? const Color(0xFF212027) : Colors.white,
        title: Row(
          children: [
            const Icon(Icons.flash_off_rounded,
                color: Color(0xFFF97316), size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                s.outOfCreditsTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: settings.isDarkMode
                      ? Colors.white
                      : const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          s.outOfCreditsMessage,
          style: TextStyle(
            fontSize: 14,
            color: settings.isDarkMode
                ? const Color(0xFF8E8D9A)
                : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel,
                style: const TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/pricing');
            },
            child: Text(s.buyMore,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Camera / Captured Image Preview Viewport ─────
            Positioned.fill(
              child: _selectedImageFile != null
                  ? Image.file(_selectedImageFile!, fit: BoxFit.cover)
                  : _buildCameraPreview(),
            ),

            // ── Scanner Laser Line & Corner Brackets Overlay ──
            Positioned(
              left: 36,
              right: 36,
              top: MediaQuery.of(context).size.height * 0.18,
              height: MediaQuery.of(context).size.height * 0.45,
              child: Stack(
                children: [
                  // Top-Left Corner
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.white, width: 3.5),
                          left: BorderSide(color: Colors.white, width: 3.5),
                        ),
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(8)),
                      ),
                    ),
                  ),
                  // Top-Right Corner
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.white, width: 3.5),
                          right: BorderSide(color: Colors.white, width: 3.5),
                        ),
                        borderRadius:
                            BorderRadius.only(topRight: Radius.circular(8)),
                      ),
                    ),
                  ),
                  // Bottom-Left Corner
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white, width: 3.5),
                          left: BorderSide(color: Colors.white, width: 3.5),
                        ),
                        borderRadius:
                            BorderRadius.only(bottomLeft: Radius.circular(8)),
                      ),
                    ),
                  ),
                  // Bottom-Right Corner
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white, width: 3.5),
                          right: BorderSide(color: Colors.white, width: 3.5),
                        ),
                        borderRadius:
                            BorderRadius.only(bottomRight: Radius.circular(8)),
                      ),
                    ),
                  ),

                  // Animated Green Laser Scan Line
                  AnimatedBuilder(
                    animation: _scanAnimationController,
                    builder: (context, child) {
                      return Positioned(
                        top: (MediaQuery.of(context).size.height * 0.44) *
                            _scanAnimationController.value,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: _kScanGreen,
                            boxShadow: [
                              BoxShadow(
                                color: _kScanGreen.withOpacity(0.8),
                                blurRadius: 12,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Instruction Text Header ────────────────────────
            if (!_isAnalyzing)
              Positioned(
                top: 24,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    Text(
                      s.scanInstructionHeader,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.scanInstructionSub,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.75),
                        shadows: const [
                          Shadow(blurRadius: 6, color: Colors.black54)
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            // ── Top Navigation Bar (Close Button) ─────────────
            Positioned(
              top: 16,
              left: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.4),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
            ),

            // ── Bottom Action Controls / AI Progress Loader ────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                      Colors.black,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0x66EF4444),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEF4444)),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_isAnalyzing) ...[
                      // Pulsing AI Status Message Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: _kScanGreen,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: _kScanGreen,
                                    blurRadius: 8,
                                    spreadRadius: 2),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _kAiMessages[_aiMsgIndex],
                              key: ValueKey<int>(_aiMsgIndex),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      // Camera & Gallery Pickers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Gallery Pick Button
                          GestureDetector(
                            onTap: _pickGalleryImage,
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white.withOpacity(0.18),
                              child: const Icon(Icons.photo_library_outlined,
                                  color: Colors.white, size: 24),
                            ),
                          ),

                          // Camera Capture Button
                          GestureDetector(
                            onTap: _captureAndAnalyze,
                            child: Container(
                              width: 76,
                              height: 76,
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isTakingPicture
                                      ? Colors.white54
                                      : Colors.transparent,
                                  border:
                                      Border.all(color: Colors.black, width: 3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 52), // Balancing spacing
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
