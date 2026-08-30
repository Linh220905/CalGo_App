import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'notification_service.dart';

class TrialNotificationService {
  TrialNotificationService._internal();
  static final TrialNotificationService instance =
      TrialNotificationService._internal();

  /// Schedule transparent trial engagement & reminder notifications
  Future<void> scheduleTrialSequence({required int trialDays}) async {
    try {
      // 1. Instant Welcome & Personalized Meal Confirmation
      await NotificationService.instance.showInstantNotification(
        title: 'Chào mừng bạn đến với CalGo Premium',
        body:
            'Thực đơn cá nhân hóa đã sẵn sàng. Hãy chụp ảnh bữa ăn đầu tiên hôm nay.',
      );

      // 2. Day 1: Check-in & Engagement Push (after 24 hours)
      await _scheduleZoned(
        id: 201,
        title: 'Bữa sáng hôm nay',
        body:
            'Hãy chụp ảnh món ăn để CalGo kiểm tra calo và dinh dưỡng cho bạn.',
        scheduledDate: tz.TZDateTime.now(tz.local).add(const Duration(days: 1)),
      );

      // 3. Day 2 (or Day 5 for 7-day trial): Progress Push
      final progressDay = trialDays >= 7 ? 5 : 2;
      await _scheduleZoned(
        id: 202,
        title: 'Bạn đang tiến bộ',
        body:
            'Bạn đã duy trì thói quen kiểm soát calo. Hãy tiếp tục theo dõi đều đặn.',
        scheduledDate:
            tz.TZDateTime.now(tz.local).add(Duration(days: progressDay)),
      );

      // 4. 24h before trial ends: Transparent Auto-renewal notification
      final reminderDay = trialDays - 1;
      if (reminderDay > 0) {
        await _scheduleZoned(
          id: 203,
          title: 'Thông báo từ CalGo',
          body:
              'Thời gian dùng thử miễn phí sẽ kết thúc vào ngày mai. Bạn có thể kiểm tra gói đăng ký trước thời điểm này.',
          scheduledDate:
              tz.TZDateTime.now(tz.local).add(Duration(days: reminderDay)),
        );
      }

      debugPrint(
          '[TrialNotification] Scheduled $trialDays-day trial push sequence successfully');
    } catch (e) {
      debugPrint('[TrialNotification] Error scheduling sequence: $e');
    }
  }

  Future<void> _scheduleZoned({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
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
      const iosDetails = DarwinNotificationDetails();
      const details =
          NotificationDetails(android: androidDetails, iOS: iosDetails);

      await plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('[TrialNotification] Failed zoned schedule for id $id: $e');
    }
  }
}
