import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails _androidDetails = AndroidNotificationDetails(
    'weather_channel',
    'Météo',
    channelDescription: 'Alertes météo',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const DarwinNotificationDetails _iosDetails = DarwinNotificationDetails();

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: _androidDetails,
    iOS: _iosDetails,
  );

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _notifications.initialize(initSettings);
  }

  Future<void> showWeatherAlert(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'weather_channel',
      'Météo',
      channelDescription: 'Alertes météo',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _notifications.show(0, title, body, details);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      _notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleWeatherAlert(String title, String body, DateTime scheduledDate) async {
    await scheduleNotification(
      id: 1,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
  }
} 