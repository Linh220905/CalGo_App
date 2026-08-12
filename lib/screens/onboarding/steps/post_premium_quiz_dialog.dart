import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/onboarding_data.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/onboarding_provider.dart';

const _kInk = Color(0xFF111111);
const _kMuted = Color(0xFF7A7A7A);
const _kSurface = Color(0xFFF8F9FA);
const _kBorder = Color(0xFFECECEC);
const _kAccent = Color(0xFFFF6A3D);
const _kAccentSoft = Color(0xFFFFF1EC);

TextStyle _f(
  double size, {
  FontWeight weight = FontWeight.w500,
  Color color = _kInk,
  double? height,
  double? letterSpacing,
}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );

class PostPremiumQuizDialog extends StatefulWidget {
  final Future<void> Function() onCompleted;

  const PostPremiumQuizDialog({
    super.key,
    required this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function() onCompleted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      enableDrag: false,
      builder: (ctx) => PostPremiumQuizDialog(onCompleted: onCompleted),
    );
  }

  @override
  State<PostPremiumQuizDialog> createState() => _PostPremiumQuizDialogState();
}

class _PostPremiumQuizDialogState extends State<PostPremiumQuizDialog> {
  int _currentStep = 0;
  bool _isGenerating = false;
  bool _goalInitialized = false;
  String? _saveError;

  String _selectedMealPattern = 'three_meals';
  String _selectedVariety = 'rotate_daily';
  String _selectedPriority = 'balanced_macros';

  final List<Map<String, dynamic>> _q1Options = [
    {
      'value': 'three_meals',
      'emoji': '🥣',
      'title': '3 Bữa chính',
      'desc': 'Sáng - Trưa - Tối chuẩn mực, dễ kiểm soát'
    },
    {
      'value': 'three_plus_snack',
      'emoji': '🥗',
      'title': '3 Bữa chính + 1 Bữa phụ',
      'desc': 'Có thêm snack nhẹ chống đói buổi chiều'
    },
    {
      'value': 'intermittent_fasting_16_8',
      'emoji': '🥑',
      'title': '2 Bữa chính (Intermittent Fasting)',
      'desc': 'Theo chế độ nhịn ăn gián đoạn 16:8'
    },
    {
      'value': 'four_five_small',
      'emoji': '🍱',
      'title': '4 - 5 Bữa nhỏ',
      'desc': 'Chia nhỏ năng lượng đều đặn trong ngày'
    },
  ];

  final List<Map<String, dynamic>> _q2Options = [
    {
      'value': 'repeat_simple',
      'emoji': '🔁',
      'title': 'Lặp lại tối giản',
      'desc': 'Nấu 1 lần ăn 2-3 bữa, tiết kiệm thời gian'
    },
    {
      'value': 'rotate_daily',
      'emoji': '🎲',
      'title': 'Đổi món liên tục',
      'desc': 'Mỗi ngày 1 thực đơn mới, không lo ngán'
    },
    {
      'value': 'vietnamese_local',
      'emoji': '🛒',
      'title': 'Ưu tiên món ăn Việt',
      'desc': 'Nguyên liệu dễ tìm ở chợ & siêu thị Việt'
    },
  ];

  GoalType get _goal =>
      context.read<OnboardingProvider>().data.goalType ?? GoalType.maintain;

  List<Map<String, dynamic>> get _q3Options => switch (_goal) {
        GoalType.lose => [
            {
              'value': 'satiety',
              'emoji': '🥗',
              'title': 'No lâu, ít calo',
              'desc': 'Ưu tiên protein, rau và món ít dầu để dễ giữ thâm hụt'
            },
            {
              'value': 'calorie_fit',
              'emoji': '🎯',
              'title': 'Khớp calo còn lại',
              'desc': 'Chọn khẩu phần sát ngân sách calo của từng bữa'
            },
            {
              'value': 'smart_swap',
              'emoji': '💡',
              'title': 'Thay món thông minh',
              'desc': 'Gợi ý món nhẹ hơn khi hôm nay đã ăn hơi nhiều'
            },
          ],
        GoalType.gain => [
            {
              'value': 'high_protein_low_fat',
              'emoji': '💪',
              'title': 'Nhiều protein, ít fat',
              'desc': 'Ưu tiên đạm nạc để hỗ trợ tăng cơ mà không đội mỡ'
            },
            {
              'value': 'training_fuel',
              'emoji': '🏋️',
              'title': 'Nhiên liệu tập luyện',
              'desc': 'Cân bằng protein và carb cho buổi tập, phục hồi'
            },
            {
              'value': 'calorie_surplus',
              'emoji': '🍚',
              'title': 'Đủ calo tăng cân',
              'desc': 'Chia bữa dễ ăn để đạt mức calo dư mỗi ngày'
            },
          ],
        GoalType.maintain => [
            {
              'value': 'balanced_macros',
              'emoji': '⚖️',
              'title': 'Cân bằng macro',
              'desc': 'Giữ protein, carb và fat ổn định qua từng ngày'
            },
            {
              'value': 'weight_stability',
              'emoji': '🎯',
              'title': 'Giữ cân ổn định',
              'desc': 'Ưu tiên món khớp mức calo duy trì hiện tại'
            },
            {
              'value': 'flexible_weekends',
              'emoji': '🎉',
              'title': 'Linh hoạt cuối tuần',
              'desc': 'Cân lại các bữa sau khi có một bữa ăn thoải mái'
            },
          ],
      };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_goalInitialized) return;
    _goalInitialized = true;
    _selectedPriority = switch (_goal) {
      GoalType.lose => 'satiety',
      GoalType.gain => 'high_protein_low_fat',
      GoalType.maintain => 'balanced_macros',
    };
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    setState(() {
      _isGenerating = true;
      _saveError = null;
    });

    try {
      final onboarding = context.read<OnboardingProvider>();
      await onboarding.saveMealCustomization({
        'meal_pattern': _selectedMealPattern,
        'variety_preference': _selectedVariety,
        'assistant_priority': _selectedPriority,
        'setup_version': 1,
      }, accountId: context.read<AuthProvider>().user?.id);
      await widget.onCompleted();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _saveError = 'Không thể lưu cá nhân hóa. Kiểm tra mạng và thử lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(22, 16, 22, bottomPadding + 16),
          child: SingleChildScrollView(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isGenerating ? _buildGeneratingView() : _buildQuizView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizView() {
    return Column(
      key: ValueKey(_currentStep),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Drag Handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Image.asset(
              'assets/images/apple_mascot/apple_thinking.png',
              height: 78,
              fit: BoxFit.contain,
            ),
          ),
        ),

        // Step Indicator & Tag
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _kAccentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: _kAccent),
                  const SizedBox(width: 4),
                  Text(
                    'Cá nhân hóa Premium',
                    style: _f(11, weight: FontWeight.w700, color: _kAccent),
                  ),
                ],
              ),
            ),
            Text(
              'Bước ${_currentStep + 1} / 3',
              style: _f(12, weight: FontWeight.w600, color: _kMuted),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: _kBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(_kInk),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 20),

        // Title & Description
        if (_currentStep == 0) ...[
          Text(
            'Bữa ăn trong ngày của bạn',
            style: _f(22, weight: FontWeight.w800, letterSpacing: -0.4),
          ),
          const SizedBox(height: 6),
          Text(
            'Bạn muốn AI phân bổ lượng Calo hàng ngày theo mấy bữa?',
            style: _f(13, color: _kMuted, height: 1.35),
          ),
          const SizedBox(height: 18),
          ..._q1Options.asMap().entries.map((entry) => _buildOptionCard(
                index: entry.key,
                selected: _selectedMealPattern == entry.value['value'],
                emoji: entry.value['emoji']!,
                title: entry.value['title']!,
                desc: entry.value['desc']!,
                onTap: () => setState(
                  () => _selectedMealPattern = entry.value['value']!,
                ),
              )),
        ] else if (_currentStep == 1) ...[
          Text(
            'Mức độ linh hoạt thực đơn',
            style: _f(22, weight: FontWeight.w800, letterSpacing: -0.4),
          ),
          const SizedBox(height: 6),
          Text(
            'AI nên ưu tiên gợi ý thực đơn theo phong cách nào?',
            style: _f(13, color: _kMuted, height: 1.35),
          ),
          const SizedBox(height: 18),
          ..._q2Options.asMap().entries.map((entry) => _buildOptionCard(
                index: entry.key,
                selected: _selectedVariety == entry.value['value'],
                emoji: entry.value['emoji']!,
                title: entry.value['title']!,
                desc: entry.value['desc']!,
                onTap: () => setState(
                  () => _selectedVariety = entry.value['value']!,
                ),
              )),
        ] else ...[
          Text(
            'Mục tiêu đồng hành Premium',
            style: _f(22, weight: FontWeight.w800, letterSpacing: -0.4),
          ),
          const SizedBox(height: 6),
          Text(
            'Bạn muốn AI trợ lý tập trung hỗ trợ tính năng nào nhất?',
            style: _f(13, color: _kMuted, height: 1.35),
          ),
          const SizedBox(height: 18),
          ..._q3Options.asMap().entries.map((entry) => _buildOptionCard(
                index: entry.key,
                selected: _selectedPriority == entry.value['value'],
                emoji: entry.value['emoji']!,
                title: entry.value['title']!,
                desc: entry.value['desc']!,
                onTap: () => setState(
                  () => _selectedPriority = entry.value['value']!,
                ),
              )),
        ],

        const SizedBox(height: 20),

        if (_saveError != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _saveError!,
              textAlign: TextAlign.center,
              style: _f(11.5, color: Colors.redAccent),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _isGenerating
                  ? null
                  : () async {
                      await widget.onCompleted();
                      if (mounted) Navigator.of(context).pop();
                    },
              child: const Text('Tiếp tục, đồng bộ câu trả lời sau'),
            ),
          ),
          const SizedBox(height: 4),
        ],

        // Action Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kInk,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentStep == 2 ? 'Hoàn tất & Tạo thực đơn' : 'Tiếp tục',
                  style: _f(15, weight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded,
                    size: 18, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required int index,
    required bool selected,
    required String emoji,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? _kSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? _kInk : _kBorder,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : _kSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: _f(14, weight: FontWeight.w700, color: _kInk),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: _f(11.5, color: _kMuted, height: 1.25),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? _kInk : Colors.transparent,
                  border: Border.all(
                    color: selected ? _kInk : _kBorder,
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratingView() {
    return Container(
      key: const ValueKey('generating'),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: _kAccentSoft,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(_kAccent),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'AI CalGo đang thiết lập thực đơn...',
            textAlign: TextAlign.center,
            style: _f(20, weight: FontWeight.w800, letterSpacing: -0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'Đang cá nhân hóa lượng Calo và món ăn phù hợp nhất cho bạn',
            textAlign: TextAlign.center,
            style: _f(13, color: _kMuted, height: 1.35),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  'Đã kích hoạt trợ lý AI thành công',
                  style: _f(11.5, weight: FontWeight.w600, color: _kInk),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
