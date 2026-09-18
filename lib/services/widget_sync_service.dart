import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:live_activities/live_activities.dart';
import 'notification_service.dart';

class WidgetSyncService {
  WidgetSyncService._();
  static final WidgetSyncService instance = WidgetSyncService._();

  static const String appGroupId = 'group.com.calgo.calgo';
  static const String iOSWidgetName = 'CalGoWidget';
  static const String androidWidgetName = 'CalGoWidgetProvider';

  final LiveActivities _liveActivities = LiveActivities();
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

      // 2. Update Live Activity / Lock Screen Banner
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
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        await NotificationService.instance.updateAndroidLiveNotification(
          caloriesLeft: caloriesLeft,
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
      if (!areActivitiesEnabled) {
        debugPrint('Live Activities are not enabled on device');
        return;
      }

      if (!isEnabled) {
        await _liveActivities.endAllActivities();
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

      // createOrUpdateActivity handles creating if missing or updating existing activity by unique ID
      await _liveActivities.createOrUpdateActivity(
        'calgo_live_activity',
        activityData,
        removeWhenAppIsKilled: false,
      );
    } catch (e) {
      debugPrint('Live Activity update error: $e');
    }
  }

  Future<void> stopAllLiveActivities() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _liveActivities.endAllActivities();
      }
    } catch (e) {
      debugPrint('Live Activity stop error: $e');
    }
  }
}
