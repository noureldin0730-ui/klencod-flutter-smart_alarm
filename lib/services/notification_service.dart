import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _plugin.initialize(initializationSettings);

    // طلب صلاحيات الإشعارات والمنبه الدقيق (للأندرويد 13+)
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();
  }

  static Future<void> scheduleAlarm(DateTime dateTime, int id) async {
    // إعدادات الصوت من فولدر raw
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarms',
      channelDescription: 'Alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true, // عشان يفتح الشاشة فوراً
      playSound: true,
      enableVibration: true, // تفعيل الاهتزاز
      sound: RawResourceAndroidNotificationSound('alarm_sound'), // بيقرا الملف من res/raw
      // لو عايز المنبه يفضل يرن وميقفش لوحده، ممكن تضيف خاصية الـ loop هنا لو حبيت
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id,
      'استيقظ!',
      'افتح الكاميرا عشان تقفل المنبه.',
      tz.TZDateTime.from(dateTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // مهم جداً للمنبهات الدقيقة
    );
  }

  static Future<void> cancelAll() async {
    // إلغاء كل الإشعارات عشان المنبه يقف لما نفتح الكاميرا
    await _plugin.cancelAll();
  }
}