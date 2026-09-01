import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';

class AppleHealthModal extends StatefulWidget {
  final bool isDark;

  const AppleHealthModal({
    super.key,
    required this.isDark,
  });

  static Future<bool?> show(BuildContext context, {required bool isDark}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AppleHealthModal(isDark: isDark),
    );
  }

  @override
  State<AppleHealthModal> createState() => _AppleHealthModalState();
}

class _AppleHealthModalState extends State<AppleHealthModal> {
  bool _isLoading = false;
  String? _statusMessage;

  Future<void> _requestNativePermission() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final settings = context.read<AppSettingsProvider>();
    final granted = await settings.connectAppleHealth();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (granted) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _statusMessage =
            'Chưa thể cấp quyền. Hãy đảm bảo bạn đã cấp quyền trong Cài đặt iPhone > Quyền riêng tư & Bật Apple Health.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final isConnected = settings.isAppleHealthConnected;

    final bgColor = widget.isDark ? const Color(0xFF1E1C24) : const Color(0xFFF2F2F7);
    final cardBg = widget.isDark ? const Color(0xFF2A2834) : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handlebar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Apple Health Icon Card
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0x1FFF2D55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFFF2D55),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Đồng bộ Apple Health',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Kết nối trực tiếp với ứng dụng Apple Health trên iPhone để tự động đồng bộ bước chân, calo tiêu thụ và dinh dưỡng hằng ngày.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: mutedColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Status Badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isDark ? const Color(0xFF383644) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isConnected ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                      color: isConnected ? const Color(0xFF34C759) : const Color(0xFFF59E0B),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isConnected ? 'Trạng thái: Đã kết nối' : 'Trạng thái: Chưa kết nối',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isConnected
                                ? 'Ứng dụng đã được cấp quyền đọc & ghi dữ liệu với Apple Health.'
                                : 'Nhấn nút bên dưới để mở hộp thoại ủy quyền từ hệ thống iOS.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (_statusMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _statusMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 13,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _requestNativePermission,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.touch_app_rounded),
                  label: Text(
                    isConnected ? 'Cấp lại quyền / Kết nối lại iOS' : 'Kết nối Apple Health (iOS)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2D55),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              if (isConnected)
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      await settings.setAppleHealthConnected(false);
                      if (!mounted) return;
                      nav.pop(false);
                    },
                    child: const Text(
                      'Ngắt kết nối',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
