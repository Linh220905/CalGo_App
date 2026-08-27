import 'dart:convert';
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

  /// Schedule daily meal reminders customized for user's gender, goal & name
  Future<void> scheduleDailyMealReminders() async {
    if (!_initialized) return;

    final s = await _strings();
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('app_language') ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;

    // Load stored onboarding profile data if present
    String? name;
    String? gender;
    String? goalType;
    final jsonStr = prefs.getString('onboarding_data');
    if (jsonStr != null) {
      try {
        final decoded = jsonDecode(jsonStr);
        if (decoded is Map<String, dynamic>) {
          name = decoded['name'] as String?;
          gender = decoded['gender'] as String?;
          goalType = decoded['goalType'] as String?;
        }
      } catch (_) {}
    }

    final androidDetails = AndroidNotificationDetails(
      'calgo_daily_reminders',
      s.notificationChannelName,
      channelDescription: s.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Cancel existing meal reminders (101-103)
    for (final id in [101, 102, 103]) {
      await _notificationsPlugin.cancel(id);
    }

    final bf = _buildMotivationalContent(
      mealType: 'breakfast',
      name: name,
      gender: gender,
      goalType: goalType,
      lang: lang,
      fallbackTitle: s.notificationBreakfastTitle,
      fallbackBody: s.notificationBreakfastBody,
    );

    final lu = _buildMotivationalContent(
      mealType: 'lunch',
      name: name,
      gender: gender,
      goalType: goalType,
      lang: lang,
      fallbackTitle: s.notificationLunchTitle,
      fallbackBody: s.notificationLunchBody,
    );

    final dn = _buildMotivationalContent(
      mealType: 'dinner',
      name: name,
      gender: gender,
      goalType: goalType,
      lang: lang,
      fallbackTitle: s.notificationDinnerTitle,
      fallbackBody: s.notificationDinnerBody,
    );

    // 1. Sáng (07:30)
    await _scheduleDailyNotification(
      id: 101,
      title: bf['title']!,
      body: bf['body']!,
      hour: 7,
      minute: 30,
      details: details,
    );

    // 2. Trưa (12:00)
    await _scheduleDailyNotification(
      id: 102,
      title: lu['title']!,
      body: lu['body']!,
      hour: 12,
      minute: 0,
      details: details,
    );

    // 3. Tối (18:30)
    await _scheduleDailyNotification(
      id: 103,
      title: dn['title']!,
      body: dn['body']!,
      hour: 18,
      minute: 30,
      details: details,
    );

    debugPrint(
        'Successfully scheduled personalized daily meal reminders (07:30, 12:00, 18:30)');
  }

  Map<String, String> _buildMotivationalContent({
    required String mealType,
    required String? name,
    required String? gender,
    required String? goalType,
    required String lang,
    required String fallbackTitle,
    required String fallbackBody,
  }) {
    if (lang != 'vi') {
      return {'title': fallbackTitle, 'body': fallbackBody};
    }

    final isFemale = gender == 'female';
    final isMale = gender == 'male';
    final isLose = goalType == 'lose';
    final isGain = goalType == 'gain';

    final displayName = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : null;

    String salutation;
    if (displayName != null) {
      salutation = '$displayName ơi ✨';
    } else if (isFemale) {
      salutation = 'Chào cô gái ✨';
    } else if (isMale) {
      salutation = 'Chào bạn 🔥';
    } else {
      salutation = 'Chào bạn ✨';
    }

    if (mealType == 'breakfast') {
      if (isLose) {
        return {
          'title': 'CalGo • Năng Lượng Buổi Sáng 🌅',
          'body': '$salutation Nạp bữa sáng thanh nhẹ, đủ đạm để kích hoạt đốt mỡ & tràn đầy năng lượng hôm nay nhé!',
        };
      } else if (isGain) {
        return {
          'title': 'CalGo • Bữa Sáng Tăng Cơ 💪',
          'body': '$salutation Nạp bữa sáng giàu protein & năng lượng để nuôi dưỡng cơ bắp săn chắc hôm nay nào!',
        };
      } else {
        return {
          'title': 'CalGo • Chào Ngày Mới 🌅',
          'body': '$salutation Một bữa sáng cân bằng dinh dưỡng sẽ giúp bạn duy trì vóc dáng & sức khỏe suốt ngày dài!',
        };
      }
    } else if (mealType == 'lunch') {
      if (isLose) {
        return {
          'title': 'CalGo • Giờ Nghỉ Trưa 🥗',
          'body': '$salutation Đến giờ ăn trưa rồi! Mở CalGo quét món ăn để duy trì kỷ luật & giữ eo thon gọn nhé!',
        };
      } else if (isGain) {
        return {
          'title': 'CalGo • Nạp Đạm Bữa Trưa 🥩',
          'body': '$salutation Đến giờ nạp năng lượng rồi! Quét bữa trưa với CalGo để đảm bảo đủ đạm cho cơ bắp nhé!',
        };
      } else {
        return {
          'title': 'CalGo • Bữa Trưa Khỏe Mạnh 🍱',
          'body': '$salutation Giờ nghỉ trưa rồi nè! Nhớ chụp hình món ăn để CalGo giúp bạn theo dõi dinh dưỡng nhé!',
        };
      }
    } else {
      // dinner
      if (isLose) {
        return {
          'title': 'CalGo • Tổng Kết Ngày 🌙',
          'body': '$salutation Quét bữa tối nhẹ nhàng để chốt mục tiêu giảm mỡ thành công rực rỡ hôm nay nhé!',
        };
      } else if (isGain) {
        return {
          'title': 'CalGo • Chốt Calo Tối 🏋️',
          'body': '$salutation Chụp hình bữa tối để CalGo giúp bạn chốt chỉ số protein & năng lượng phục hồi cơ trọn vẹn!',
        };
      } else {
        return {
          'title': 'CalGo • Bữa Tối Ấm Cúng 🌙',
          'body': '$salutation Buổi tối vui vẻ! Nhớ quét bữa tối để chốt nhật ký calo trọn vẹn hôm nay cùng CalGo nhé!',
        };
      }
    }
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
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}

