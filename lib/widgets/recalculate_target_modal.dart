import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/onboarding_data.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/onboarding_service.dart';
import 'horizontal_ruler_picker.dart';

/// Shows the main Target Nutrition Overview sheet in Profile Settings.
void showTargetNutritionModal(BuildContext context, bool isDark) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _TargetNutritionModalContent(isDark: isDark),
  );
}

class _TargetNutritionModalContent extends StatelessWidget {
  final bool isDark;

  const _TargetNutritionModalContent({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    final bgColor = isDark ? const Color(0xFF1E1C24) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF2C2A34) : const Color(0xFFF1F5F9);

    final dailyTarget = (user?.dailyCalorieTarget ?? 2000).round();
    final weightKg = user?.currentWeightKg ?? 70.0;

    // Approximate Macros calculation
    final proteinG = (weightKg * 2.0).clamp(80.0, dailyTarget * 0.35 / 4).round();
    final fatG = (dailyTarget * 0.25 / 9).round();
    final carbG = ((dailyTarget - (proteinG * 4) - (fatG * 9)) / 4).round().clamp(50, 600);

    final proteinKcal = proteinG * 4;
    final carbKcal = carbG * 4;
    final fatKcal = fatG * 9;
    final totalKcalSum = (proteinKcal + carbKcal + fatKcal).clamp(1, 10000);

    final proteinPct = (proteinKcal / totalKcalSum * 100).round();
    final carbPct = (carbKcal / totalKcalSum * 100).round();
    final fatPct = 100 - proteinPct - carbPct;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle bar
          Center(
            child: Container(
              width: 42,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3F3B4D) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mục tiêu dinh dưỡng',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.4,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close_rounded,
                  color: mutedColor,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Calorie Banner Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Color(0xFF10B981),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CALO MỤC TIÊU HÀNG NGÀY',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$dailyTarget',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'kcal / ngày',
                            style: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'CHỈ SỐ MACROS PHÂN BỔ',
            style: TextStyle(
              color: mutedColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          // Stacked Macro Ratio Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: proteinPct,
                    child: Container(color: const Color(0xFF14B8A6)),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: carbPct,
                    child: Container(color: const Color(0xFFF59E0B)),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: fatPct,
                    child: Container(color: const Color(0xFFF43F5E)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Macro cards list
          _MacroRowItem(
            label: 'Đạm (Protein)',
            amount: '${proteinG}g',
            percentage: '$proteinPct%',
            calories: '$proteinKcal kcal',
            color: const Color(0xFF14B8A6),
            isDark: isDark,
            borderColor: borderColor,
          ),
          const SizedBox(height: 10),
          _MacroRowItem(
            label: 'Tinh bột (Carb)',
            amount: '${carbG}g',
            percentage: '$carbPct%',
            calories: '$carbKcal kcal',
            color: const Color(0xFFF59E0B),
            isDark: isDark,
            borderColor: borderColor,
          ),
          const SizedBox(height: 10),
          _MacroRowItem(
            label: 'Chất béo (Fat)',
            amount: '${fatG}g',
            percentage: '$fatPct%',
            calories: '$fatKcal kcal',
            color: const Color(0xFFF43F5E),
            isDark: isDark,
            borderColor: borderColor,
          ),
          const SizedBox(height: 24),

          // Recalculate Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _openRecalculateWizard(context, isDark, user);
              },
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(
                'Tạo lại mục tiêu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openRecalculateWizard(BuildContext context, bool isDark, User? user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: isDark ? const Color(0xFF121116) : Colors.white,
      builder: (ctx) => RecalculateWizardFlow(isDark: isDark, user: user),
    );
  }
}

class _MacroRowItem extends StatelessWidget {
  final String label;
  final String amount;
  final String percentage;
  final String calories;
  final Color color;
  final bool isDark;
  final Color borderColor;

  const _MacroRowItem({
    required this.label,
    required this.amount,
    required this.percentage,
    required this.calories,
    required this.color,
    required this.isDark,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF262430) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amount ($percentage)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                calories,
                style: TextStyle(
                  fontSize: 11,
                  color: mutedColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The multi-step Recalculate Target Wizard Flow
class RecalculateWizardFlow extends StatefulWidget {
  final bool isDark;
  final User? user;

  const RecalculateWizardFlow({
    super.key,
    required this.isDark,
    required this.user,
  });

  @override
  State<RecalculateWizardFlow> createState() => _RecalculateWizardFlowState();
}

class _RecalculateWizardFlowState extends State<RecalculateWizardFlow> {
  int _currentStep = 0;
  bool _saving = false;

  late OnboardingData _data;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _data = OnboardingData(
      gender: Gender.male,
      age: u?.age ?? 25,
      heightCm: u?.heightCm ?? 170.0,
      weightKg: u?.currentWeightKg ?? 70.0,
      targetWeightKg: u?.targetWeightKg ?? 65.0,
      goalType: GoalType.lose,
      activityLevel: ActivityLevel.moderate,
      lossPerWeekKg: 0.5,
    );
    if (u?.activityLevel != null) {
      _data.activityLevel = switch (u!.activityLevel) {
        'sedentary' => ActivityLevel.sedentary,
        'lightly_active' => ActivityLevel.light,
        'moderately_active' => ActivityLevel.moderate,
        'very_active' => ActivityLevel.active,
        'extremely_active' => ActivityLevel.veryActive,
        _ => ActivityLevel.moderate,
      };
    }
  }

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
      if (_currentStep == 4) {
        // Step 4 is Analysis animation, auto advance after 2 seconds
        Timer(const Duration(milliseconds: 2200), () {
          if (mounted && _currentStep == 4) {
            setState(() => _currentStep = 5);
          }
        });
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0 && _currentStep != 4) {
      setState(() => _currentStep--);
    } else if (_currentStep == 0) {
      Navigator.pop(context);
    }
  }

  Future<void> _saveAndApply() async {
    setState(() => _saving = true);
    final api = context.read<ApiService>();
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    try {
      _data.applyDisplayedDefaults();
      final onboardingService = OnboardingService(api);
      await onboardingService.saveProfile(_data);

      if (mounted) {
        await auth.refreshUser();
        nav.pop();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật mục tiêu calo mới thành công!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Lỗi khi cập nhật mục tiêu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? const Color(0xFF121116) : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: _currentStep == 4
            ? const SizedBox()
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: textColor,
                onPressed: _prevStep,
              ),
        title: Text(
          _currentStep == 5 ? 'Kết quả mục tiêu' : 'Tạo lại mục tiêu (${_currentStep + 1}/5)',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            color: mutedColor,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            if (_currentStep < 5)
              LinearProgressIndicator(
                value: (_currentStep + 1) / 5,
                backgroundColor: widget.isDark ? const Color(0xFF2C2A34) : const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                minHeight: 3,
              ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: _buildStepContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildActivityStep();
      case 1:
        return _buildHeightStep();
      case 2:
        return _buildWeightStep();
      case 3:
        return _buildTargetWeightStep();
      case 4:
        return _buildAnalysisStep();
      case 5:
        return _buildSummaryResultStep();
      default:
        return const SizedBox();
    }
  }

  // Step 0: Activity Level
  Widget _buildActivityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tần suất tập luyện & vận động',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Mức độ hoạt động hàng ngày quyết định lượng calo tiêu thụ (TDEE) của bạn.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            children: [
              _activityTile('Ít vận động (Ngồi văn phòng)', ActivityLevel.sedentary, Icons.chair_alt_rounded),
              _activityTile('Vận động nhẹ (Tập 1-3 ngày/tuần)', ActivityLevel.light, Icons.directions_walk_rounded),
              _activityTile('Vừa phải (Tập 3-5 ngày/tuần)', ActivityLevel.moderate, Icons.fitness_center_rounded),
              _activityTile('Năng động (Tập 6-7 ngày/tuần)', ActivityLevel.active, Icons.directions_run_rounded),
              _activityTile('Vận động cao (Vận động viên/Lao động nặng)', ActivityLevel.veryActive, Icons.bolt_rounded),
            ],
          ),
        ),
        _primaryButton('Tiếp tục', _nextStep),
      ],
    );
  }

  Widget _activityTile(String label, ActivityLevel level, IconData icon) {
    final selected = _data.activityLevel == level;
    final cardBg = selected
        ? const Color(0xFF10B981).withValues(alpha: 0.1)
        : (widget.isDark ? const Color(0xFF1E1C24) : const Color(0xFFF8FAFC));
    final border = selected ? const Color(0xFF10B981) : (widget.isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _data.activityLevel = level),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? const Color(0xFF10B981) : const Color(0xFF64748B), size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // Step 1: Height
  Widget _buildHeightStep() {
    final height = _data.heightCm ?? 170.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chiều cao của bạn',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Dùng để tính chỉ số BMI và nhu cầu năng lượng cơ bản (BMR).',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Text(
                '${height.round()} cm',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 20),
              HorizontalRulerPicker(
                min: 120,
                max: 220,
                initialValue: height,
                isDark: widget.isDark,
                onChanged: (val) => setState(() => _data.heightCm = val),
              ),
            ],
          ),
        ),
        const Spacer(),
        _primaryButton('Tiếp tục', _nextStep),
      ],
    );
  }

  // Step 2: Weight
  Widget _buildWeightStep() {
    final weight = _data.weightKg ?? 70.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cân nặng hiện tại',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Cân nặng thực tế hôm nay của bạn.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Text(
                '${weight.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 20),
              HorizontalRulerPicker(
                min: 30,
                max: 180,
                step: 0.5,
                initialValue: weight,
                isDark: widget.isDark,
                onChanged: (val) => setState(() => _data.weightKg = val),
              ),
            ],
          ),
        ),
        const Spacer(),
        _primaryButton('Tiếp tục', _nextStep),
      ],
    );
  }

  // Step 3: Target Weight & Goal
  Widget _buildTargetWeightStep() {
    final targetW = _data.targetWeightKg ?? 65.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mục tiêu cân nặng',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _goalTypeChip('Giảm cân', GoalType.lose),
            const SizedBox(width: 8),
            _goalTypeChip('Giữ cân', GoalType.maintain),
            const SizedBox(width: 8),
            _goalTypeChip('Tăng cân', GoalType.gain),
          ],
        ),
        const SizedBox(height: 30),
        Center(
          child: Column(
            children: [
              Text(
                '${targetW.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 16),
              HorizontalRulerPicker(
                min: 30,
                max: 180,
                step: 0.5,
                initialValue: targetW,
                isDark: widget.isDark,
                onChanged: (val) => setState(() => _data.targetWeightKg = val),
              ),
            ],
          ),
        ),
        const Spacer(),
        _primaryButton('Tiếp tục', _nextStep),
      ],
    );
  }

  Widget _goalTypeChip(String label, GoalType type) {
    final selected = _data.goalType == type;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: const Color(0xFF10B981),
      labelStyle: TextStyle(
        color: selected ? Colors.white : (widget.isDark ? Colors.white : Colors.black),
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _data.goalType = type),
    );
  }

  // Step 4: Analyzing Animation
  Widget _buildAnalysisStep() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(
              strokeWidth: 5,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            ),
          ),
          SizedBox(height: 32),
          Text(
            'Đang phân tích dữ liệu...',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Tính toán BMR, TDEE và xây dựng tỷ lệ Macros tối ưu cho bạn.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Step 5: Summary Result Step
  Widget _buildSummaryResultStep() {
    final calories = _data.targetCaloriesPerDay.round();
    final bmr = _data.bmr.round();
    final tdee = _data.tdee.round();
    final bmi = _data.bmi;

    final proteinG = _data.targetProteinG.round();
    final fatG = _data.targetFatG.round();
    final carbG = _data.targetCarbG.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mục tiêu calo mới của bạn',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // New Calorie Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MỤC TIÊU KHUYÊN DÙNG',
                style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$calories',
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 8),
                  const Text('kcal / ngày', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 16)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Key Health Metrics Grid
        Row(
          children: [
            Expanded(child: _metricCard('BMI', bmi.toStringAsFixed(1))),
            const SizedBox(width: 10),
            Expanded(child: _metricCard('BMR', '$bmr kcal')),
            const SizedBox(width: 10),
            Expanded(child: _metricCard('TDEE', '$tdee kcal')),
          ],
        ),
        const SizedBox(height: 20),

        const Text(
          'MACROS DỰ KIẾN',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _macroBadge('Đạm', '${proteinG}g', const Color(0xFF14B8A6))),
            const SizedBox(width: 8),
            Expanded(child: _macroBadge('Carb', '${carbG}g', const Color(0xFFF59E0B))),
            const SizedBox(width: 8),
            Expanded(child: _macroBadge('Chất béo', '${fatG}g', const Color(0xFFF43F5E))),
          ],
        ),

        const Spacer(),
        _primaryButton('Lưu & Áp dụng mục tiêu', _saveAndApply, loading: _saving),
      ],
    );
  }

  Widget _metricCard(String title, String value) {
    final bg = widget.isDark ? const Color(0xFF1E1C24) : const Color(0xFFF8FAFC);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _macroBadge(String name, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(name, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback onPressed, {bool loading = false}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
