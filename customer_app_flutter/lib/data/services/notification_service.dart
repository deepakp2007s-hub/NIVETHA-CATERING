import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Background message handler (app closed / background-ல இருக்கும்போது வேலை செய்யும்).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'nivetha_catering_channel',
    'Nivetha Catering Updates',
    description: 'Booking status and catering updates',
    importance: Importance.high,
  );

  GlobalKey<NavigatorState>? _navigatorKey;

  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;

    // 1. Android 13+ (Vivo T4x) Notification permission கேட்கும்
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Local notifications setup (App open-ல இருக்கும்போதும் banner காட்ட)
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 3. App open-ல இருக்கும்போது notification வந்தா மேல banner காட்டும்
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _localNotifications.show(
          id: notification.hashCode,
          title: notification.title ?? 'Nivetha Catering',
          body: notification.body ?? '',
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // 4. App background-ல இருக்கும்போது notification தொட்டா ஆப் திறக்கும்
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _navigateFromData(message.data);
    });

    // 5. App முழுசா close ஆகியிருக்கும்போது notification தொட்டு திறந்தா
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _navigateFromData(initialMessage.data);
      });
    }

    // 6. FCM Token print (Test பண்ண & Backend-க்கு அனுப்ப)
    try {
      // ignore: deprecated_member_use
      final token = await _messaging.getToken();
      debugPrint('FCM_TOKEN: $token');
    } catch (e) {
      debugPrint('FCM_TOKEN_ERROR: $e');
    }
  }

  void _handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) {
      _navigatorKey?.currentState?.pushNamedAndRemoveUntil('/home', (r) => false);
      return;
    }
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _navigateFromData(data);
    } catch (_) {
      _navigatorKey?.currentState?.pushNamedAndRemoveUntil('/home', (r) => false);
    }
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final screen = data['screen']?.toString();
    if (screen == 'bookings') {
      _navigatorKey?.currentState?.pushNamed('/my-bookings');
    } else {
      _navigatorKey?.currentState?.pushNamedAndRemoveUntil('/home', (r) => false);
    }
  }
}