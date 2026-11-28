import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Background message handler (app closed / background-ல இருக்கும்போது வேலை செய்யும்).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const String _baseUrl =
      'https://nivetha-fastapi-backend-dm9u.onrender.com';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  StreamSubscription<String>? _tokenRefreshSub;

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

    // 6. Token refresh listener
    await _tokenRefreshSub?.cancel();
    // ignore: deprecated_member_use
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) async {
      await syncTokenWithBackend(fcmToken: newToken);
    });

    // 7. Already logged-in user இருந்தா startup-லயே token sync பண்ணும்
    await syncTokenWithBackend();
  }

  /// Customer Login ஆன உடனேயும் app start ஆகும்போதும் இதை call பண்ணு
  Future<void> syncTokenWithBackend({
    String? authToken,
    String? fcmToken,
  }) async {
    try {
      final jwt = (authToken != null && authToken.isNotEmpty)
          ? authToken
          : await _readSavedJwt();
      if (jwt == null || jwt.isEmpty) return;

      // ignore: deprecated_member_use
      final token = (fcmToken != null && fcmToken.isNotEmpty)
          ? fcmToken
          // ignore: deprecated_member_use
          : await _messaging.getToken();
      if (token == null || token.isEmpty) return;

      debugPrint('FCM_TOKEN: $token');

      final dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      await dio.post(
        '/api/v1/notifications/register-token',
        data: {
          'fcm_token': token,
          'platform': 'android',
        },
        options: Options(
          headers: {'Authorization': 'Bearer $jwt'},
        ),
      );
      debugPrint('FCM_TOKEN_SYNCED_TO_BACKEND');
    } catch (e) {
      debugPrint('FCM_TOKEN_SYNC_ERROR: $e');
    }
  }

  Future<String?> _readSavedJwt() async {
    for (final key in ['access_token', 'token', 'auth_token']) {
      final secureVal = await _secureStorage.read(key: key);
      if (secureVal != null && secureVal.isNotEmpty) return secureVal;
    }
    final prefs = await SharedPreferences.getInstance();
    for (final key in ['access_token', 'token', 'auth_token']) {
      final prefVal = prefs.getString(key);
      if (prefVal != null && prefVal.isNotEmpty) return prefVal;
    }
    return null;
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
    final type = data['type']?.toString();
    if (screen == 'bookings' || type == 'booking_status') {
      _navigatorKey?.currentState?.pushNamed('/my-bookings');
    } else {
      _navigatorKey?.currentState?.pushNamedAndRemoveUntil('/home', (r) => false);
    }
  }
}