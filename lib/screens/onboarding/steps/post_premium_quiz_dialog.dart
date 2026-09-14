import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/onboarding_data.dart';
import '../../../providers/app_settings_provider.dart';
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
}) => GoogleFonts.plusJakartaSans(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
  letterSpacing: letterSpacing,
);

class PostPremiumQuizDialog extends StatefulWidget {
  final Future<void> Function() onCompleted;

  const PostPremiumQuizDialog({super.key, required this.onCompleted});

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function() onCompleted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      enableDrag: false,
      builder: (ctx) => PostPremiumQuizDialog(onCompleted: onCompleted),
    );
  }

  @override
  State<PostPremiumQuizDialog> createState() => _PostPremiumQuizDialogState();
}

class _PostPremiumQuizDialogState extends State<PostPremiumQuizDialog> {
  AppLocalizations get _s {
    try {
      final settings = Provider.of<AppSettingsProvider>(context, listen: false);
      return settings.strings;
    } catch (_) {
      return AppLocalizations.of(context) ??
          lookupAppLocalizations(const Locale('vi'));
    }
  }

  int _currentStep = 0;
  bool _isGenerating = false;
  bool _goalInitialized = false;
  String? _saveError;

  String _selectedMealPattern = 'three_meals';
  String _selectedVariety = 'rotate_daily';
  String _selectedPriority = 'balanced_macros';

  List<Map<String, dynamic>> _getQ1Options(dynamic s) => [
    {
      'value': 'three_meals',
      'title': s.quizMealPattern3Title,
      'desc': s.quizMealPattern3Desc,
    },
    {
      'value': 'three_plus_snack',
      'title': s.quizMealPattern3SnackTitle,
      'desc': s.quizMealPattern3SnackDesc,
    },
    {
      'value': 'intermittent_fasting_16_8',
      'title': s.quizMealPatternIFTitle,
      'desc': s.quizMealPatternIFDesc,
    },
    {
      'value': 'four_five_small',
      'title': s.quizMealPatternSmallTitle,
      'desc': s.quizMealPatternSmallDesc,
    },
  ];

  List<Map<String, dynamic>> _getQ2Options(dynamic s) => [
    {
      'value': 'repeat_simple',
      'title': s.quizVarietySimpleTitle,
      'desc': s.quizVarietySimpleDesc,
    },
    {
      'value': 'rotate_daily',
      'title': s.quizVarietyRotateTitle,
      'desc': s.quizVarietyRotateDesc,
    },
    {
      'value': 'vietnamese_local',
      'title': s.quizVarietyLocalTitle,
      'desc': s.quizVarietyLocalDesc,
    },
  ];

  GoalType get _goal =>
      context.read<OnboardingProvider>().data.goalType ?? GoalType.maintain;

  List<Map<String, dynamic>> _getQ3Options(dynamic s) => switch (_goal) {
    GoalType.lose => [
      {
        'value': 'satiety',
        'title': s.quizOptSatietyTitle,
        'desc': s.quizOptSatietyDesc,
      },
      {
        'value': 'calorie_fit',
        'title': s.quizOptCalorieFitTitle,
        'desc': s.quizOptCalorieFitDesc,
      },
      {
        'value': 'smart_swap',
        'title': s.quizOptSmartSwapTitle,
        'desc': s.quizOptSmartSwapDesc,
      },
    ],
    GoalType.gain => [
      {
        'value': 'high_protein_low_fat',
        'title': s.quizOptHighProteinTitle,
        'desc': s.quizOptHighProteinDesc,
      },
      {
        'value': 'training_fuel',
        'title': s.quizOptTrainingFuelTitle,
        'desc': s.quizOptTrainingFuelDesc,
      },
      {
        'value': 'calorie_surplus',
        'title': s.quizOptCalorieSurplusTitle,
        'desc': s.quizOptCalorieSurplusDesc,
      },
    ],
    GoalType.maintain => [
      {
        'value': 'balanced_macros',
        'title': s.quizOptBalancedMacrosTitle,
        'desc': s.quizOptBalancedMacrosDesc,
      },
      {
        'value': 'weight_stability',
        'title': s.quizOptWeightStabilityTitle,
        'desc': s.quizOptWeightStabilityDesc,
      },
      {
        'value': 'flexible_weekends',
        'title': s.quizOptFlexibleWeekendsTitle,
        'desc': s.quizOptFlexibleWeekendsDesc,
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
        _saveError = _s.profileSaveFailed;
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
    final s = _s;
    final q1Opts = _getQ1Options(s);
    final q2Opts = _getQ2Options(s);
    final q3Opts = _getQ3Options(s);

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
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            s.quizStepCount(_currentStep + 1),
            style: _f(12, weight: FontWeight.w600, color: _kMuted),
          ),
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
            s.quizMealPatternTitle,
            style: _f(22, weight: FontWeight.w800, letterSpacing: -0.4),
          ),
          const SizedBox(height: 6),
          Text(
            s.quizMealPatternDesc,
            style: _f(13, color: _kMuted, height: 1.35),
          ),
          const SizedBox(height: 18),
          ...q1Opts.asMap().entries.map(
            (entry) => _buildOptionCard(
              index: entry.key,
              selected: _selectedMealPattern == entry.value['value'],
              title: entry.value['title']!,
              desc: entry.value['desc']!,
              onTap: () =>
                  setState(() => _selectedMealPattern = entry.value['value']!),
            ),
          ),
        ] else if (_currentStep == 1) ...[
          Text(
            s.quizVarietyTitle,
            style: _f(22, weight: FontWeight.w800, letterSpacing: -0.4),
          ),
          const SizedBox(height: 6),
          Text(
            s.quizVarietyDesc,
            style: _f(13, color: _kMuted, height: 1.35),
          ),
          const SizedBox(height: 18),
          ...q2Opts.asMap().entries.map(
            (entry) => _buildOptionCard(
              index: entry.key,
              selected: _selectedVariety == entry.value['value'],
              title: entry.value['title']!,
              desc: entry.value['desc']!,
              onTap: () =>
                  setState(() => _selectedVariety = entry.value['value']!),
            ),
          ),
        ] else ...[
          Text(
            s.quizPriorityTitle,
            style: _f(22, weight: FontWeight.w800, letterSpacing: -0.4),
          ),
          const SizedBox(height: 6),
          Text(
            s.quizPriorityDesc,
            style: _f(13, color: _kMuted, height: 1.35),
          ),
          const SizedBox(height: 18),
          ...q3Opts.asMap().entries.map(
            (entry) => _buildOptionCard(
              index: entry.key,
              selected: _selectedPriority == entry.value['value'],
              title: entry.value['title']!,
              desc: entry.value['desc']!,
              onTap: () =>
                  setState(() => _selectedPriority = entry.value['value']!),
            ),
          ),
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
              child: Text(s.quizSyncAnswersLater),
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
                  _currentStep == 2 ? s.quizCompleteAndGenerateMenu : s.continueLabel,
                  style: _f(15, weight: FontWeight.w700, color: Colors.white),
                ),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: _f(14, weight: FontWeight.w700, color: _kInk),
                    ),
                    const SizedBox(height: 2),
                    Text(desc, style: _f(11.5, color: _kMuted, height: 1.25)),
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
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _kInk,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratingView() {
    final s = _s;
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
            s.quizSettingUpMenu,
            textAlign: TextAlign.center,
            style: _f(20, weight: FontWeight.w800, letterSpacing: -0.3),
          ),
          const SizedBox(height: 8),
          Text(
            s.quizPersonalizingCalories,
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
                Text(
                  s.quizFinalizingSetup,
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
