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
  Future<void>? _initializationFuture;
  bool? _recapHasMeals;

  /// The app router is wired by main.dart so a notification tap can deep-link
  /// into the actual recap screen instead of only writing a debug log.
  static void Function(String? payload)? onNotificationTap;

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

  Future<void> init() {
    if (_initialized) return Future.value();
    return _initializationFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _initializeInternal();
    } catch (e, stackTrace) {
      // Allow a later app resume to retry if iOS temporarily rejected a
      // platform-channel call while the app was starting.
      _initialized = false;
      debugPrint('Notification initialization error: $e\n$stackTrace');
    } finally {
      _initializationFuture = null;
    }
  }

  Future<void> _initializeInternal() async {

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
        onNotificationTap?.call(details.payload);
      },
    );

    final launchDetails =
        await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      onNotificationTap?.call(launchDetails?.notificationResponse?.payload);
    }

    _initialized = true;
    final permissionGranted = await requestPermission();
    debugPrint('Notification permission granted: $permissionGranted');
    await scheduleDailyMealReminders();
    await scheduleDailyRecapNotification(
      hasMeals: _recapHasMeals ?? false,
    );
  }

  /// Rebuilds the daily schedule when the app returns from the background.
  /// This recovers from a failed first initialization and keeps the next
  /// lunch reminder available after an iOS restore/update.
  Future<void> ensureDailyMealRemindersScheduled() async {
    await init();
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
      presentBanner: true,
      presentList: true,
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

  /// Schedule a one-shot 22:00 reminder only for a day on which the user has
  /// actually scanned food. It is deliberately not a repeating notification:
  /// Home refreshes this flag each day and cancels it when there are no scans.
  Future<void> scheduleDailyRecapNotification({required bool hasMeals}) async {
    _recapHasMeals = hasMeals;
    if (!_initialized) return;

    if (!hasMeals) {
      await _notificationsPlugin.cancel(104);
      return;
    }

    final s = await _strings();
    final lang = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'calgo_daily_recap',
        s.notificationChannelName,
        channelDescription: s.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
      ),
    );

    await _notificationsPlugin.cancel(104);
    await _scheduleDailyNotification(
      id: 104,
      title: lang == 'vi' ? 'CalGo Tổng kết ngày' : 'CalGo Daily recap',
      body: lang == 'vi'
          ? 'Báo cáo dinh dưỡng hôm nay đã sẵn sàng. Mở CalGo để xem.'
          : 'Your nutrition recap is ready. Open CalGo to review it.',
      hour: 22,
      minute: 0,
      details: details,
      payload: 'daily_recap',
      repeatDaily: false,
    );
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

    final displayName =
        (name != null && name.trim().isNotEmpty) ? name.trim() : null;

    String salutation;
    if (displayName != null) {
      salutation = '$displayName ơi,';
    } else if (isFemale) {
      salutation = 'Bạn gái xinh đẹp ơi,';
    } else if (isMale) {
      salutation = 'Bạn nam năng động ơi,';
    } else {
      salutation = 'Bạn thân mến,';
    }

    if (mealType == 'breakfast') {
      if (isLose) {
        return {
          'title': 'Buổi sáng rạng rỡ cùng CalGo',
          'body':
              '$salutation Dù bận rộn đến đâu bạn cũng nhớ ăn một bữa sáng nhẹ nhàng đủ chất nha. Cùng nhau bắt đầu ngày mới thật tích cực để hướng tới vóc dáng thon gọn nhé.',
        };
      } else if (isGain) {
        return {
          'title': 'Nạp năng lượng buổi sáng cùng CalGo',
          'body':
              '$salutation Hãy bắt đầu ngày mới thật sung sức với bữa sáng giàu đạm nha. Đừng quên chụp một tấm ảnh món ăn để theo dõi đủ lượng dinh dưỡng cho cơ bắp nhé.',
        };
      } else {
        return {
          'title': 'Chào ngày mới tràn đầy năng lượng',
          'body':
              '$salutation Một bữa sáng thơm ngon và cân bằng đang chờ bạn thưởng thức. Mở CalGo chụp ảnh lưu lại bữa ăn ngon miệng ngay nào.',
        };
      }
    } else if (mealType == 'lunch') {
      if (isLose) {
        return {
          'title': 'Đến giờ ăn trưa rồi bạn ơi',
          'body':
              '$salutation Bạn đã làm việc vất vả cả buổi sáng rồi. Hãy thưởng thức một bữa trưa lành mạnh và chụp ảnh món ăn để CalGo theo dõi calo giúp bạn nhé.',
        };
      } else if (isGain) {
        return {
          'title': 'Tiếp thêm năng lượng bữa trưa',
          'body':
              '$salutation Bữa trưa thơm ngon đang chờ bạn tiếp sức. Hãy chụp ảnh món ăn để CalGo giúp bạn kiểm tra lượng protein nạp vào nhé.',
        };
      } else {
        return {
          'title': 'Thưởng thức bữa trưa ngon miệng',
          'body':
              '$salutation Đến giờ nghỉ trưa rồi, bạn hãy ăn uống thong thả và chụp một tấm ảnh xinh xắn để lưu lại nhật ký dinh dưỡng hôm nay nhé.',
        };
      }
    } else {
      // dinner
      if (isLose) {
        return {
          'title': 'Bữa tối nhẹ nhàng cùng CalGo',
          'body':
              '$salutation Hôm nay bạn đã cố gắng rất tuyệt vời. Hãy chọn một bữa tối thanh nhẹ và chụp ảnh món ăn để hoàn thành mục tiêu giảm mỡ ngày hôm nay nhé.',
        };
      } else if (isGain) {
        return {
          'title': 'Chốt hạ dinh dưỡng bữa tối',
          'body':
              '$salutation Bữa tối ngon lành sẽ giúp cơ bắp phục hồi sau một ngày làm việc. Chụp ảnh bữa tối cùng CalGo để ghi nhận sự nỗ lực của bạn nào.',
        };
      } else {
        return {
          'title': 'Bữa tối ấm áp cùng CalGo',
          'body':
              '$salutation Cùng khép lại một ngày tuyệt vời với bữa tối ấm áp nhé. Bạn mở CalGo chụp ảnh món ăn để hoàn thành nhật ký calo ngày hôm nay nào.',
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
    String? payload,
    bool repeatDaily = true,
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
        payload: payload,
        matchDateTimeComponents: repeatDaily ? DateTimeComponents.time : null,
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
        presentBanner: true,
        presentList: true,
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
