import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../l10n/generated/app_localizations.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<AppLocalizations> _strings() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('app_language');
    final device =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final codes = AppLocalizations.supportedLocales
        .map((locale) => locale.languageCode)
        .toSet();
    final code = codes.contains(saved)
        ? saved!
        : codes.contains(device)
            ? device
            : 'en';
    return lookupAppLocalizations(Locale(code));
  }

  Future<void> init() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    } catch (_) {
      // Fallback timezone initialization if local location fails
      try {
        tz.initializeTimeZones();
      } catch (e) {
        debugPrint('Timezone init error: $e');
      }
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification clicked: ${details.payload}');
      },
    );

    _initialized = true;
    await requestPermission();
    await scheduleDailyMealReminders();
  }

  Future<bool> requestPermission() async {
    bool granted = false;
    try {
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        granted =
            await androidImplementation.requestNotificationsPermission() ??
                false;
      }

      final iosImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        granted = await iosImplementation.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
    return granted;
  }

  Future<void> scheduleDailyMealReminders() async {
    if (!_initialized) return;

    final s = await _strings();

    final androidDetails = AndroidNotificationDetails(
      'calgo_daily_reminders',
      s.notificationChannelName,
      channelDescription: s.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Cancel existing scheduled notifications to avoid duplicates
    await _notificationsPlugin.cancelAll();

    // 1. Sáng (07:30)
    await _scheduleDailyNotification(
      id: 101,
      title: s.notificationBreakfastTitle,
      body: s.notificationBreakfastBody,
      hour: 7,
      minute: 30,
      details: details,
    );

    // 2. Trưa (12:00)
    await _scheduleDailyNotification(
      id: 102,
      title: s.notificationLunchTitle,
      body: s.notificationLunchBody,
      hour: 12,
      minute: 0,
      details: details,
    );

    // 3. Tối (18:30)
    await _scheduleDailyNotification(
      id: 103,
      title: s.notificationDinnerTitle,
      body: s.notificationDinnerBody,
      hour: 18,
      minute: 30,
      details: details,
    );

    debugPrint(
        'Successfully scheduled 3 daily meal reminders (07:30, 12:00, 18:30)');
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required NotificationDetails details,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling notification $id ($hour:$minute): $e');
    }
  }

  /// Show instantaneous notification for testing / welcome
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    final s = await _strings();
    final androidDetails = AndroidNotificationDetails(
      'calgo_instant',
      s.notificationDirectChannel,
      importance: Importance.high,
      priority: Priority.high,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}
