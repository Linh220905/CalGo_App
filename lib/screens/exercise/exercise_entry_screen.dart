import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/app_settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import '../../utils/exercise_calorie_calculator.dart';
import '../../widgets/quick_add_sheet.dart';

class ExerciseEntryScreen extends StatefulWidget {
  final ExerciseEntryType type;

  const ExerciseEntryScreen({super.key, required this.type});

  @override
  State<ExerciseEntryScreen> createState() => _ExerciseEntryScreenState();
}

class _ExerciseEntryScreenState extends State<ExerciseEntryScreen> {
  ExerciseIntensity _intensity = ExerciseIntensity.moderate;
  int _durationMinutes = 30;
  late final TextEditingController _durationController;
  final TextEditingController _manualCaloriesController =
      TextEditingController();
  bool _saving = false;
  String? _error;

  bool get _isManual => widget.type == ExerciseEntryType.manual;
  String get _activityType => switch (widget.type) {
    ExerciseEntryType.running => 'running',
    ExerciseEntryType.walking => 'walking',
    ExerciseEntryType.cycling => 'cycling',
    ExerciseEntryType.swimming => 'swimming',
    ExerciseEntryType.workout => 'workout',
    ExerciseEntryType.manual => 'manual',
  };

  @override
  void initState() {
    super.initState();
    _durationController = TextEditingController(text: '30');
  }

  @override
  void dispose() {
    _durationController.dispose();
    _manualCaloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final isDark = settings.isDarkMode;
    final text = isDark ? Colors.white : const Color(0xFF111111);
    final muted = isDark ? const Color(0xFFA3A0AA) : const Color(0xFF6B7280);
    final bg = isDark ? const Color(0xFF141318) : const Color(0xFFFAFAFB);
    final weightKg =
        context.watch<AuthProvider>().user?.currentWeightKg ??
        context.watch<HomeProvider>().summary.currentWeightKg;
    final estimatedCalories = _isManual
        ? double.tryParse(_manualCaloriesController.text) ?? 0
        : ExerciseCalorieCalculator.estimateActiveCalories(
            activityType: _activityType,
            intensity: _intensity,
            weightKg: weightKg,
            durationMinutes: _durationMinutes,
          );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: text),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_headerIcon, color: text, size: 23),
            const SizedBox(width: 9),
            Text(
              _title(settings.strings),
              style: TextStyle(
                color: text,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            if (!_isManual) ...[
              _SectionTitle(
                icon: Icons.auto_awesome,
                label: settings.strings.intensityTitle,
                color: text,
              ),
              const SizedBox(height: 12),
              _IntensityCard(
                activityType: _activityType,
                selected: _intensity,
                isDark: isDark,
                onSelected: (value) => setState(() => _intensity = value),
              ),
              const SizedBox(height: 28),
            ],
            _SectionTitle(
              icon: _isManual
                  ? Icons.local_fire_department_outlined
                  : Icons.schedule_rounded,
              label: _isManual
                  ? settings.strings.burnedCaloriesTitle
                  : settings.strings.durationTitle,
              color: text,
            ),
            const SizedBox(height: 12),
            if (_isManual)
              _NumberField(
                controller: _manualCaloriesController,
                suffix: settings.strings.kcalSuffix,
                hint: settings.strings.manualCaloriesHint,
                isDark: isDark,
                onChanged: (_) => setState(() {}),
              )
            else ...[
              Row(
                children: [15, 30, 60, 90]
                    .map(
                      (minutes) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: minutes == 90 ? 0 : 8,
                          ),
                          child: _DurationChip(
                            minutes: minutes,
                            selected: _durationMinutes == minutes,
                            isDark: isDark,
                            onTap: () => _setDuration(minutes),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              _NumberField(
                controller: _durationController,
                suffix: settings.strings.minutesSuffix,
                hint: settings.strings.durationHint,
                isDark: isDark,
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null && parsed > 0 && parsed <= 1440) {
                    setState(() => _durationMinutes = parsed);
                  }
                },
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF24212A)
                    : const Color(0xFFFFF4ED),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF3A2A23)
                      : const Color(0xFFFFDCC8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Color(0xFFF97316),
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isManual
                              ? settings.strings.willAddToToday
                              : settings.strings.estimatedActiveCalories,
                          style: TextStyle(color: muted, fontSize: 12.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${estimatedCalories.round()} ${settings.strings.kcalSuffix}',
                          style: TextStyle(
                            color: text,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isManual)
                    Text(
                      '${ExerciseCalorieCalculator.metFor(_activityType, _intensity)} MET',
                      style: const TextStyle(
                        color: Color(0xFFF97316),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
            ),
            if (!_isManual) ...[
              const SizedBox(height: 10),
              Text(
                weightKg > 0
                    ? settings.strings.exerciseCalcWeightNote(weightKg.toStringAsFixed(1))
                    : settings.strings.exerciseUpdateWeightPrompt,
                style: TextStyle(color: muted, fontSize: 12.5, height: 1.4),
              ),
              const SizedBox(height: 8),
              Text(
                settings.strings.exerciseHealthSyncWarning,
                style: TextStyle(color: muted, fontSize: 12.5, height: 1.4),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(
                _error!,
                style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              height: 58,
              child: FilledButton(
                onPressed: _saving || (!_isManual && weightKg <= 0)
                    ? null
                    : () => _save(estimatedCalories, settings.strings),
                style: FilledButton.styleFrom(
                  backgroundColor: text,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  disabledBackgroundColor: isDark
                      ? Colors.white12
                      : Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        settings.strings.saveWorkoutButton,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _title(dynamic strings) => switch (widget.type) {
    ExerciseEntryType.running => strings.exerciseRunning,
    ExerciseEntryType.walking => strings.exerciseWalking,
    ExerciseEntryType.cycling => strings.exerciseCycling,
    ExerciseEntryType.swimming => strings.exerciseSwimming,
    ExerciseEntryType.workout => strings.filterWorkout,
    ExerciseEntryType.manual => strings.exerciseManual,
  };

  IconData get _headerIcon => switch (widget.type) {
    ExerciseEntryType.running => Icons.directions_run_rounded,
    ExerciseEntryType.walking => Icons.directions_walk_rounded,
    ExerciseEntryType.cycling => Icons.directions_bike_rounded,
    ExerciseEntryType.swimming => Icons.pool_rounded,
    ExerciseEntryType.workout => Icons.fitness_center_rounded,
    ExerciseEntryType.manual => Icons.edit_note_rounded,
  };

  void _setDuration(int minutes) {
    _durationController.text = '$minutes';
    setState(() => _durationMinutes = minutes);
  }

  Future<void> _save(double estimatedCalories, dynamic strings) async {
    FocusScope.of(context).unfocus();
    if (_isManual && (estimatedCalories <= 0 || estimatedCalories > 5000)) {
      setState(() => _error = strings.exerciseCalorieRangeError);
      return;
    }
    if (!_isManual && (_durationMinutes <= 0 || _durationMinutes > 1440)) {
      setState(() => _error = strings.exerciseDurationRangeError);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final entry = await context.read<HomeProvider>().recordExercise(
        activityType: _activityType,
        intensity: _isManual ? null : _intensity.name,
        durationMinutes: _isManual ? null : _durationMinutes,
        caloriesBurned: _isManual ? estimatedCalories : null,
      );
      if (!mounted) return;
      Navigator.pop(context, entry.caloriesBurned.round());
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = strings.exerciseSaveNetworkError;
      });
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionTitle({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 9),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _IntensityCard extends StatelessWidget {
  final String activityType;
  final ExerciseIntensity selected;
  final bool isDark;
  final ValueChanged<ExerciseIntensity> onSelected;

  const _IntensityCard({
    required this.activityType,
    required this.selected,
    required this.isDark,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppSettingsProvider>().strings;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF212027) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF302E38) : const Color(0xFFE8E8EA),
        ),
      ),
      child: Column(
        children:
            const [
                  ExerciseIntensity.high,
                  ExerciseIntensity.moderate,
                  ExerciseIntensity.low,
                ]
                .map(
                  (intensity) => _IntensityOption(
                    intensity: intensity,
                    title: _intensityTitle(intensity, strings),
                    description: _description(intensity, strings),
                    selected: selected == intensity,
                    isDark: isDark,
                    onTap: () => onSelected(intensity),
                  ),
                )
                .toList(),
      ),
    );
  }

  String _intensityTitle(ExerciseIntensity value, dynamic strings) => switch (value) {
    ExerciseIntensity.low => strings.intensityLow,
    ExerciseIntensity.moderate => strings.intensityModerate,
    ExerciseIntensity.high => strings.intensityHigh,
  };

  String _description(ExerciseIntensity value, dynamic strings) {
    if (activityType == 'running') {
      return switch (value) {
        ExerciseIntensity.low => strings.exerciseRunLowDesc,
        ExerciseIntensity.moderate => strings.exerciseRunModDesc,
        ExerciseIntensity.high => strings.exerciseRunHighDesc,
      };
    }
    if (activityType == 'walking') {
      return switch (value) {
        ExerciseIntensity.low => strings.exerciseWalkLowDesc,
        ExerciseIntensity.moderate => strings.exerciseWalkModDesc,
        ExerciseIntensity.high => strings.exerciseWalkHighDesc,
      };
    }
    if (activityType == 'cycling') {
      return switch (value) {
        ExerciseIntensity.low => strings.exerciseCycleLowDesc,
        ExerciseIntensity.moderate => strings.exerciseCycleModDesc,
        ExerciseIntensity.high => strings.exerciseCycleHighDesc,
      };
    }
    if (activityType == 'swimming') {
      return switch (value) {
        ExerciseIntensity.low => strings.exerciseSwimLowDesc,
        ExerciseIntensity.moderate => strings.exerciseSwimModDesc,
        ExerciseIntensity.high => strings.exerciseSwimHighDesc,
      };
    }
    return switch (value) {
      ExerciseIntensity.low => strings.exerciseWorkoutLowDesc,
      ExerciseIntensity.moderate => strings.exerciseWorkoutModDesc,
      ExerciseIntensity.high => strings.exerciseWorkoutHighDesc,
    };
  }
}

class _IntensityOption extends StatelessWidget {
  final ExerciseIntensity intensity;
  final String title;
  final String description;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _IntensityOption({
    required this.intensity,
    required this.title,
    required this.description,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = isDark ? Colors.white : const Color(0xFF111111);
    final muted = isDark ? const Color(0xFFA3A0AA) : const Color(0xFF6B7280);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? Colors.white10 : const Color(0xFFF3F3F4))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: selected ? Border.all(color: text, width: 1.4) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? text : muted,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(color: muted, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? text : muted, width: 2),
                color: selected ? text : Colors.transparent,
              ),
              child: selected
                  ? Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: isDark ? Colors.black : Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  final int minutes;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _DurationChip({
    required this.minutes,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = isDark ? Colors.white : const Color(0xFF111111);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? text : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: text, width: 1.4),
        ),
        child: Text(
          '$minutes′',
          style: TextStyle(
            color: selected ? (isDark ? Colors.black : Colors.white) : text,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String suffix;
  final String hint;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _NumberField({
    required this.controller,
    required this.suffix,
    required this.hint,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final text = isDark ? Colors.white : const Color(0xFF111111);
    final muted = isDark ? const Color(0xFFA3A0AA) : const Color(0xFF6B7280);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(color: text, fontSize: 26, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: muted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        suffixText: suffix,
        suffixStyle: TextStyle(color: muted, fontWeight: FontWeight.w700),
        filled: true,
        fillColor: isDark ? const Color(0xFF212027) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 19,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: muted),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF302E38) : const Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: text, width: 1.6),
        ),
      ),
    );
  }
}
