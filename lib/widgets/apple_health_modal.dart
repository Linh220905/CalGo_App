import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  // Write Permissions State
  final Map<String, bool> _writePermissions = {
    'Bài tập': true,
    'Bước': true,
    'Cân nặng': true,
    'Chất béo Bão hòa': true,
    'Chất đạm': true,
    'Chất xơ': true,
    'Chỉ số Khối Cơ thể (BMI)': true,
    'Chiều cao': true,
    'Đường Thực phẩm': true,
    'Natri': true,
    'Năng lượng hoạt động': true,
    'Năng lượng thực phẩm': true,
    'Nước': true,
    'Tinh bột': true,
    'Tổng Chất béo': true,
  };

  // Read Permissions State
  final Map<String, bool> _readPermissions = {
    'Bài tập': true,
    'Bước': true,
    'Cân nặng': true,
    'Chỉ số Khối Cơ thể (BMI)': true,
    'Chiều cao': true,
    'Năng lượng hoạt động': true,
  };

  bool get _allEnabled {
    final writeAll = _writePermissions.values.every((v) => v);
    final readAll = _readPermissions.values.every((v) => v);
    return writeAll && readAll;
  }

  void _toggleAll() {
    final newValue = !_allEnabled;
    setState(() {
      _writePermissions.updateAll((key, val) => newValue);
      _readPermissions.updateAll((key, val) => newValue);
    });
  }

  IconData _getIconForMetric(String key) {
    switch (key) {
      case 'Bài tập':
        return Icons.fitness_center_rounded;
      case 'Bước':
        return Icons.directions_walk_rounded;
      case 'Cân nặng':
        return Icons.monitor_weight_outlined;
      case 'Chỉ số Khối Cơ thể (BMI)':
        return Icons.accessibility_new_rounded;
      case 'Chiều cao':
        return Icons.height_rounded;
      case 'Năng lượng hoạt động':
        return Icons.local_fire_department_rounded;
      case 'Nước':
        return Icons.water_drop_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }

  Color _getIconColorForMetric(String key) {
    switch (key) {
      case 'Bài tập':
        return const Color(0xFFF97316); // Orange
      case 'Bước':
        return const Color(0xFFF97316); // Orange
      case 'Cân nặng':
      case 'Chỉ số Khối Cơ thể (BMI)':
      case 'Chiều cao':
        return const Color(0xFFA855F7); // Purple
      case 'Năng lượng hoạt động':
        return const Color(0xFFEF4444); // Red
      case 'Nước':
        return const Color(0xFF0EA5E9); // Blue
      default:
        return const Color(0xFF22C55E); // Green
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? const Color(0xFF1E1C24) : const Color(0xFFF2F2F7);
    final cardBg = widget.isDark ? const Color(0xFF2A2834) : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final sectionHeaderColor = widget.isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Bar (Từ chối | Truy cập sức khỏe | Cho phép)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                bottom: BorderSide(
                  color: widget.isDark ? const Color(0xFF383644) : const Color(0xFFE2E8F0),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Từ chối',
                    style: TextStyle(
                      color: Color(0xFF007AFF),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Text(
                  'Truy cập sức khỏe',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Cho phép',
                    style: TextStyle(
                      color: Color(0xFF007AFF),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Scroll Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                // Apple Health Logo Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF2D55).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFFF2D55),
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sức khỏe',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '"CaloCalo" muốn truy cập và cập nhật dữ liệu Sức khỏe của bạn.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: mutedColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // "Bật tất cả" Tile
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      'Bật tất cả',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    trailing: CupertinoSwitch(
                      value: _allEnabled,
                      activeTrackColor: const Color(0xFF34C759),
                      onChanged: (val) => _toggleAll(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Section 1: CHO PHÉP CALOCALO GHI
                _buildSectionHeader('CHO PHÉP "CALOCALO" GHI', sectionHeaderColor),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: _writePermissions.entries.map((entry) {
                      final isLast = entry.key == _writePermissions.keys.last;
                      return Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _getIconColorForMetric(entry.key).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getIconForMetric(entry.key),
                                color: _getIconColorForMetric(entry.key),
                                size: 18,
                              ),
                            ),
                            title: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            trailing: CupertinoSwitch(
                              value: entry.value,
                              activeTrackColor: const Color(0xFF34C759),
                              onChanged: (val) {
                                setState(() {
                                  _writePermissions[entry.key] = val;
                                });
                              },
                            ),
                          ),
                          if (!isLast)
                            Divider(
                              height: 1,
                              indent: 56,
                              color: widget.isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Giải thích ứng dụng: CaloCalo ghi bữa ăn, cân nặng, chiều cao, BMI, số bước, năng lượng hoạt động và bài tập vào Apple Health để dữ liệu của bạn ở cùng một nơi.',
                    style: TextStyle(
                      fontSize: 12,
                      color: mutedColor,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Section 2: CHO PHÉP CALOCALO ĐỌC
                _buildSectionHeader('CHO PHÉP "CALOCALO" ĐỌC', sectionHeaderColor),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: _readPermissions.entries.map((entry) {
                      final isLast = entry.key == _readPermissions.keys.last;
                      return Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _getIconColorForMetric(entry.key).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getIconForMetric(entry.key),
                                color: _getIconColorForMetric(entry.key),
                                size: 18,
                              ),
                            ),
                            title: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            trailing: CupertinoSwitch(
                              value: entry.value,
                              activeTrackColor: const Color(0xFF34C759),
                              onChanged: (val) {
                                setState(() {
                                  _readPermissions[entry.key] = val;
                                });
                              },
                            ),
                          ),
                          if (!isLast)
                            Divider(
                              height: 1,
                              indent: 56,
                              color: widget.isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Giải thích ứng dụng: CaloCalo đọc số bước, năng lượng hoạt động, cân nặng, chiều cao, BMI và bài tập của bạn để giữ mục tiêu calo hằng ngày chính xác.',
                    style: TextStyle(
                      fontSize: 12,
                      color: mutedColor,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
