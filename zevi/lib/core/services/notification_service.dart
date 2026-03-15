import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

/// FCM background message handler — must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.notification?.title}');
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'zevi_notifications';
  static const _channelName = 'Zevi';
  static const _channelDesc = 'Zevi AI assistant notifications';

  /// Call once from main.dart after Firebase is initialized
  static Future<void> initialize({
    required void Function(String route) onNotificationTap,
  }) async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permissions
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    // Set up local notifications channel (Android)
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);

    // Initialize FlutterLocalNotifications
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        onNotificationTap('/chat');
      },
    );

    // Foreground: show local notification
    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
    });

    // Background tap → opened app
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onNotificationTap('/chat');
    });

    // Cold start tap
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      onNotificationTap('/chat');
    }

    // Post FCM token to backend
    await _registerToken();
  }

  static Future<void> _registerToken() async {
    try {
      String? token;
      if (!kIsWeb && Platform.isIOS) {
        token = await FirebaseMessaging.instance.getAPNSToken();
      }
      token ??= await FirebaseMessaging.instance.getToken();
      debugPrint('[FCM] Token: $token');

      if (token != null) {
        await apiServiceProvider.dio.post(
          '/api/user/profile',
          data: {'fcm_token': token},
        );
      }
    } on DioException catch (e) {
      // Non-fatal: backend may not be available during dev
      debugPrint('[FCM] Token registration skipped: ${e.message}');
    } catch (e) {
      debugPrint('[FCM] Token error: $e');
    }

    // Listen for token refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      try {
        await apiServiceProvider.dio.post(
          '/api/user/profile',
          data: {'fcm_token': newToken},
        );
      } catch (_) {}
    });
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF6C47FF), // AppColors.violet
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title ?? 'Zevi',
      notification.body ?? '',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: '/chat',
    );
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
