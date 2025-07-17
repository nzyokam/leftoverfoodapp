import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // 👇 INIT for local notifications
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  // 👇 LOCAL notification
  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'food_share_channel',
      'Food Share Notifications',
      channelDescription: 'Notifications for food sharing activities',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // 👇 REMOTE PUSH: call your Edge Function or backend
  static Future<void> sendPushNotification({
    required String token,
    required String title,
    required String body,
  }) async {
    final response = await http.post(
      Uri.parse('https://<your-edge-or-backend-url>.com/send-push'), // <-- Replace this
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'token': token,
        'title': title,
        'body': body,
      }),
    );

    if (response.statusCode != 200) {
      print('Push notification failed: ${response.body}');
    }
  }
}
