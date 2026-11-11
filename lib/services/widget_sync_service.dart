import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';
import 'package:live_activities/live_activities.dart';
import 'notification_service.dart';

class WidgetSyncService with WidgetsBindingObserver {
  WidgetSyncService._();
  static final WidgetSyncService instance = WidgetSyncService._();

  static const String appGroupId = 'group.com.calgo.calgo';
  static const String iOSWidgetName = 'CalGoWidget';
  static const String androidWidgetName = 'CalGoWidgetProvider';

  static void Function(String path)? onWidgetDeepLink;

  final LiveActivities _liveActivities = LiveActivities();
  bool _initialized = false;
  Future<void>? _initializationFuture;
  Map<String, dynamic>? _lastLiveActivityData;
  bool _lastLiveActivityEnabled = true;
  bool _isUpdatingLiveActivity = false;
  Map<String, dynamic>? _pendingActivityData;
  bool? _pendingIsEnabled;

  Future<void> init() {
    if (_initialized) return Future.value();
    return _initializationFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HomeWidget.setAppGroupId(appGroupId);
        await _liveActivities.init(appGroupId: appGroupId);
      }

      // HomeWidget uses the same URI launch contract on both platforms.
      // Android widget PendingIntents are delivered through its onNewIntent
      // listener, so this must not be restricted to iOS.
      final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (initialUri != null) {
        _handleDeepLinkUri(initialUri);
      }

      // Listen for widget clicks while the app is already running.
      HomeWidget.widgetClicked.listen((uri) {
        if (uri != null) {
          _handleDeepLinkUri(uri);
        }
      });

      _initialized = true;
      WidgetsBinding.instance.addObserver(this);
    } catch (e) {
      debugPrint('WidgetSyncService init error: $e');
    } finally {
      _initializationFuture = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed ||
        !_initialized ||
        _lastLiveActivityData == null) {
      return;
    }

    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final lastSyncDate = _lastLiveActivityData?['syncDate'] as String?;
    if (lastSyncDate != null && lastSyncDate != todayStr) {
      // Calendar day changed! Reset consumed values for the fresh day
      final target = (_lastLiveActivityData?['targetCalories'] as num?)?.toInt() ?? 2000;
      final targetProtein = (_lastLiveActivityData?['targetProtein'] as num?)?.toInt() ?? 130;
      final targetCarbs = (_lastLiveActivityData?['targetCarbs'] as num?)?.toInt() ?? 200;
      final targetFat = (_lastLiveActivityData?['targetFat'] as num?)?.toInt() ?? 60;
      _lastLiveActivityData = {
        'caloriesLeft': target,
        'targetCalories': target,
        'consumedCalories': 0,
        'proteinLeft': targetProtein,
        'targetProtein': targetProtein,
        'consumedProtein': 0,
        'carbsLeft': targetCarbs,
        'targetCarbs': targetCarbs,
        'consumedCarbs': 0,
        'fatLeft': targetFat,
        'targetFat': targetFat,
        'consumedFat': 0,
        'syncDate': todayStr,
      };

      // Also refresh Home Screen widget data for new day
      unawaited(HomeWidget.saveWidgetData<String>('sync_date', todayStr));
      unawaited(HomeWidget.saveWidgetData<int>('calories_left', target));
      unawaited(HomeWidget.saveWidgetData<int>('consumed_calories', 0));
      unawaited(HomeWidget.saveWidgetData<int>('protein_left', targetProtein));
      unawaited(HomeWidget.saveWidgetData<int>('consumed_protein', 0));
      unawaited(HomeWidget.saveWidgetData<int>('carbs_left', targetCarbs));
      unawaited(HomeWidget.saveWidgetData<int>('consumed_carbs', 0));
      unawaited(HomeWidget.saveWidgetData<int>('fat_left', targetFat));
      unawaited(HomeWidget.saveWidgetData<int>('consumed_fat', 0));
      unawaited(HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      ));
    }

    // HomeScreen de-duplicates identical nutrition values. Re-submit the
    // latest state on every foreground transition so a dismissed Android
    // ongoing notification or iOS Live Activity is recreated.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      unawaited(
        _updateLiveActivity(
          activityData: Map<String, dynamic>.from(_lastLiveActivityData!),
          isEnabled: _lastLiveActivityEnabled,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final data = _lastLiveActivityData!;
      unawaited(
        NotificationService.instance.updateAndroidLiveNotification(
          caloriesLeft: (data['caloriesLeft'] as num?)?.toInt() ?? 0,
          proteinLeft: (data['proteinLeft'] as num?)?.toInt() ?? 0,
          carbsLeft: (data['carbsLeft'] as num?)?.toInt() ?? 0,
          fatLeft: (data['fatLeft'] as num?)?.toInt() ?? 0,
          isEnabled: _lastLiveActivityEnabled,
        ),
      );
    }
  }

  void _handleDeepLinkUri(Uri uri) {
    debugPrint('WidgetSyncService deepLink received: $uri');
    final host = uri.host.isNotEmpty ? uri.host : uri.path.replaceAll('/', '');
    if (host == 'scan') {
      onWidgetDeepLink?.call('/scan');
    } else if (host == 'barcode' || host == 'barcode-scan') {
      onWidgetDeepLink?.call('/barcode-scan');
    } else if (host == 'home') {
      onWidgetDeepLink?.call('/home');
    }
  }

  /// Syncs calories and macros to Home Screen Widget and Lock Screen Live Activity
  Future<void> syncNutritionData({
    required int caloriesLeft,
    required int targetCalories,
    required int consumedCalories,
    required int proteinLeft,
    int targetProtein = 130,
    int consumedProtein = 0,
    required int carbsLeft,
    int targetCarbs = 200,
    int consumedCarbs = 0,
    required int fatLeft,
    int targetFat = 60,
    int consumedFat = 0,
    bool isLiveActivityEnabled = true,
  }) async {
    try {
      await init();

      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final activityData = <String, dynamic>{
        'caloriesLeft': caloriesLeft,
        'targetCalories': targetCalories,
        'consumedCalories': consumedCalories,
        'proteinLeft': proteinLeft,
        'targetProtein': targetProtein,
        'consumedProtein': consumedProtein,
        'carbsLeft': carbsLeft,
        'targetCarbs': targetCarbs,
        'consumedCarbs': consumedCarbs,
        'fatLeft': fatLeft,
        'targetFat': targetFat,
        'consumedFat': consumedFat,
        'syncDate': todayStr,
      };
      _lastLiveActivityData = activityData;
      _lastLiveActivityEnabled = isLiveActivityEnabled;

      // 1. Update Home Screen Widget via HomeWidget (UserDefaults App Group)
      await HomeWidget.saveWidgetData<String>('sync_date', todayStr);
      await HomeWidget.saveWidgetData<int>('calories_left', caloriesLeft);
      await HomeWidget.saveWidgetData<int>('target_calories', targetCalories);
      await HomeWidget.saveWidgetData<int>(
        'consumed_calories',
        consumedCalories,
      );
      await HomeWidget.saveWidgetData<int>('protein_left', proteinLeft);
      await HomeWidget.saveWidgetData<int>('target_protein', targetProtein);
      await HomeWidget.saveWidgetData<int>('consumed_protein', consumedProtein);
      await HomeWidget.saveWidgetData<int>('carbs_left', carbsLeft);
      await HomeWidget.saveWidgetData<int>('target_carbs', targetCarbs);
      await HomeWidget.saveWidgetData<int>('consumed_carbs', consumedCarbs);
      await HomeWidget.saveWidgetData<int>('fat_left', fatLeft);
      await HomeWidget.saveWidgetData<int>('target_fat', targetFat);
      await HomeWidget.saveWidgetData<int>('consumed_fat', consumedFat);

      await HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );

      // 2. Update Live Activity / Lock Screen Banner
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _updateLiveActivity(
          activityData: activityData,
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
    required Map<String, dynamic> activityData,
    required bool isEnabled,
  }) async {
    if (_isUpdatingLiveActivity) {
      _pendingActivityData = activityData;
      _pendingIsEnabled = isEnabled;
      return;
    }
    _isUpdatingLiveActivity = true;

    try {
      final areActivitiesSupported = await _liveActivities
          .areActivitiesSupported();
      if (!areActivitiesSupported) {
        debugPrint('Live Activities are not supported on device');
        return;
      }

      final areActivitiesEnabled = await _liveActivities.areActivitiesEnabled();
      if (!areActivitiesEnabled) {
        debugPrint('Live Activities are not enabled on device settings');
        return;
      }

      if (!isEnabled) {
        await _liveActivities.endAllActivities();
        return;
      }

      // Check for and terminate any duplicate/overlapping activities
      final activeIds = await _liveActivities.getAllActivitiesIds();
      if (activeIds.length > 1) {
        for (var i = 1; i < activeIds.length; i++) {
          try {
            await _liveActivities.endActivity(activeIds[i]);
          } catch (_) {}
        }
      }

      // Calculate duration until next midnight so ActivityKit knows when it turns stale
      final now = DateTime.now();
      final nextMidnight = DateTime(now.year, now.month, now.day + 1);
      final diff = nextMidnight.difference(now);
      final staleIn = diff.inMinutes >= 1 ? diff : const Duration(minutes: 5);

      try {
        await _liveActivities.createOrUpdateActivity(
          'calgo_live_activity',
          activityData,
          removeWhenAppIsKilled: false,
          staleIn: staleIn,
        );
      } catch (err) {
        debugPrint(
          'createOrUpdateActivity failed ($err), fallback create fresh activity',
        );
        await _liveActivities.endAllActivities();
        await _liveActivities.createActivity(
          'calgo_live_activity',
          activityData,
          removeWhenAppIsKilled: false,
          staleIn: staleIn,
        );
      }
    } catch (e) {
      debugPrint('Live Activity update error: $e');
    } finally {
      _isUpdatingLiveActivity = false;
      if (_pendingActivityData != null && _pendingIsEnabled != null) {
        final nextData = _pendingActivityData!;
        final nextEnabled = _pendingIsEnabled!;
        _pendingActivityData = null;
        _pendingIsEnabled = null;
        unawaited(_updateLiveActivity(activityData: nextData, isEnabled: nextEnabled));
      }
    }
  }

  Future<void> stopAllLiveActivities() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _liveActivities.endAllActivities();
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        await NotificationService.instance.cancelLiveActivityNotification();
      }
    } catch (e) {
      debugPrint('Live Activity stop error: $e');
    }
  }
}
