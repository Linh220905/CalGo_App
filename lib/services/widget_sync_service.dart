import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:live_activities/live_activities.dart';

class WidgetSyncService {
  WidgetSyncService._();
  static final WidgetSyncService instance = WidgetSyncService._();

  static const String appGroupId = 'group.com.calgo.calgo';
  static const String iOSWidgetName = 'CalGoWidget';
  static const String androidWidgetName = 'CalGoWidgetProvider';

  final LiveActivities _liveActivities = LiveActivities();
  String? _currentActivityId;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HomeWidget.setAppGroupId(appGroupId);
        await _liveActivities.init(appGroupId: appGroupId);
      }
      _initialized = true;
    } catch (e) {
      debugPrint('WidgetSyncService init error: $e');
    }
  }

  /// Syncs calories and macros to Home Screen Widget and Lock Screen Live Activity
  Future<void> syncNutritionData({
    required int caloriesLeft,
    required int targetCalories,
    required int consumedCalories,
    required int proteinLeft,
    required int carbsLeft,
    required int fatLeft,
    bool isLiveActivityEnabled = true,
  }) async {
    try {
      await init();

      // 1. Update Home Screen Widget via HomeWidget (UserDefaults App Group)
      await HomeWidget.saveWidgetData<int>('calories_left', caloriesLeft);
      await HomeWidget.saveWidgetData<int>('target_calories', targetCalories);
      await HomeWidget.saveWidgetData<int>('consumed_calories', consumedCalories);
      await HomeWidget.saveWidgetData<int>('protein_left', proteinLeft);
      await HomeWidget.saveWidgetData<int>('carbs_left', carbsLeft);
      await HomeWidget.saveWidgetData<int>('fat_left', fatLeft);

      await HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );

      // 2. Update Live Activity on iOS Lock Screen
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _updateLiveActivity(
          caloriesLeft: caloriesLeft,
          targetCalories: targetCalories,
          consumedCalories: consumedCalories,
          proteinLeft: proteinLeft,
          carbsLeft: carbsLeft,
          fatLeft: fatLeft,
          isEnabled: isLiveActivityEnabled,
        );
      }
    } catch (e) {
      debugPrint('WidgetSyncService syncNutritionData error: $e');
    }
  }

  Future<void> _updateLiveActivity({
    required int caloriesLeft,
    required int targetCalories,
    required int consumedCalories,
    required int proteinLeft,
    required int carbsLeft,
    required int fatLeft,
    required bool isEnabled,
  }) async {
    try {
      final areActivitiesEnabled = await _liveActivities.areActivitiesEnabled();
      if (!areActivitiesEnabled) return;

      if (!isEnabled) {
        if (_currentActivityId != null) {
          await _liveActivities.endActivity(_currentActivityId!);
          _currentActivityId = null;
        } else {
          await _liveActivities.endAllActivities();
        }
        return;
      }

      final activityData = <String, dynamic>{
        'caloriesLeft': caloriesLeft,
        'targetCalories': targetCalories,
        'consumedCalories': consumedCalories,
        'proteinLeft': proteinLeft,
        'carbsLeft': carbsLeft,
        'fatLeft': fatLeft,
      };

      if (_currentActivityId == null) {
        final allActivities = await _liveActivities.getAllActivitiesIds();
        if (allActivities.isNotEmpty) {
          _currentActivityId = allActivities.first;
          await _liveActivities.updateActivity(_currentActivityId!, activityData);
        } else {
          _currentActivityId = await _liveActivities.createActivity(
            'calgo_live_activity',
            activityData,
            removeWhenAppIsKilled: false,
          );
        }
      } else {
        await _liveActivities.updateActivity(_currentActivityId!, activityData);
      }
    } catch (e) {
      debugPrint('Live Activity update error: $e');
    }
  }

  Future<void> stopAllLiveActivities() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _liveActivities.endAllActivities();
        _currentActivityId = null;
      }
    } catch (e) {
      debugPrint('Live Activity stop error: $e');
    }
  }
}
