import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'notification_service.dart';

class TrialNotificationService {
  TrialNotificationService._internal();
  static final TrialNotificationService instance =
      TrialNotificationService._internal();

  /// Schedule transparent trial engagement & reminder notifications
  Future<void> scheduleTrialSequence({
    required int trialDays,
    DateTime? trialEnd,
  }) async {
    try {
      // A purchase can complete before the app's background notification
      // initialization finishes. Await it so the scheduled calls do not race
      // the plugin setup.
      await NotificationService.instance.init();

      // 1. Instant Welcome & Personalized Meal Confirmation
      try {
        await NotificationService.instance.showInstantNotification(
          title: 'Chào mừng bạn đến với CalGo Premium',
          body:
              'Thực đơn cá nhân hóa đã sẵn sàng. Hãy chụp ảnh bữa ăn đầu tiên hôm nay.',
        );
      } catch (e) {
        // A welcome banner failure must not prevent the expiry reminder from
        // being scheduled.
        debugPrint('[TrialNotification] Welcome notification failed: $e');
      }

      final now = tz.TZDateTime.now(tz.local);

      // 2. Day 1: Check-in & Engagement Push (after 24 hours)
      await _scheduleZoned(
        id: 201,
        title: 'Bữa sáng hôm nay',
        body:
            'Hãy chụp ảnh món ăn để CalGo kiểm tra calo và dinh dưỡng cho bạn.',
        scheduledDate: now.add(const Duration(days: 1)),
      );

      // 3. Day 2 (or Day 5 for 7-day trial): Progress Push
      final progressDay = trialDays >= 7 ? 5 : 2;
      await _scheduleZoned(
        id: 202,
        title: 'Bạn đang tiến bộ',
        body:
            'Bạn đã duy trì thói quen kiểm soát calo. Hãy tiếp tục theo dõi đều đặn.',
        scheduledDate: now.add(Duration(days: progressDay)),
      );

      // 4. 24h before trial ends: Transparent Auto-renewal notification
      final reminderDay = trialDays - 1;
      final exactTrialEnd = trialEnd == null
          ? null
          : tz.TZDateTime.from(trialEnd.toUtc(), tz.local);
      final calculatedReminder =
          exactTrialEnd?.subtract(const Duration(hours: 24)) ??
          now.add(Duration(days: reminderDay));
      if (reminderDay > 0 || exactTrialEnd != null) {
        final isAlreadyWithinReminderWindow =
            calculatedReminder.isBefore(now) &&
            exactTrialEnd != null &&
            exactTrialEnd.isAfter(now);
        await _scheduleZoned(
          id: 203,
          title: 'Thông báo từ CalGo',
          body: isAlreadyWithinReminderWindow
              ? 'Thời gian dùng thử miễn phí sẽ kết thúc trong vòng 24 giờ. Bạn có thể kiểm tra gói đăng ký ngay hôm nay.'
              : 'Thời gian dùng thử miễn phí sẽ kết thúc vào ngày mai. Bạn có thể kiểm tra gói đăng ký trước thời điểm này.',
          scheduledDate: isAlreadyWithinReminderWindow
              ? now.add(const Duration(seconds: 5))
              : calculatedReminder,
          payload: 'trial_expiring',
        );
      }

      debugPrint(
        '[TrialNotification] Scheduled $trialDays-day trial push sequence successfully',
      );
    } catch (e) {
      debugPrint('[TrialNotification] Error scheduling sequence: $e');
    }
  }

  Future<void> _scheduleZoned({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
  }) async {
    try {
      final plugin = FlutterLocalNotificationsPlugin();
      const androidDetails = AndroidNotificationDetails(
        'calgo_trial_channel',
        'CalGo Free Trial Notifications',
        channelDescription:
            'Thông báo nhắc nhở và minh bạch thời gian dùng thử Premium',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
      );
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[TrialNotification] Failed zoned schedule for id $id: $e');
    }
  }
}
