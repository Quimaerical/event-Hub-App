import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../network/api_client.dart';

class FcmService {
  final ApiClient apiClient;

  FcmService({required this.apiClient});

  /// Initializes FCM permissions, retrieves token, and registers foreground handlers.
  Future<void> initialize(BuildContext context) async {
    try {
      final messaging = FirebaseMessaging.instance;

      // 1. Request Push Notification permissions
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // 2. Obtain device FCM token
        final token = await messaging.getToken();
        if (token != null && token.isNotEmpty) {
          await registerTokenWithBackend(token);
        }
      }

      // 3. Listen to foreground incoming messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title ?? 'Nueva Notificación',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (notification.body != null)
                    Text(
                      notification.body!,
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
              backgroundColor: const Color(0xFF0EA5E9),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });
    } catch (e) {
      // Gracefully catch platforms without Firebase configured (e.g. local desktop test)
      debugPrint('FCM Service warning: ${e.toString()}');
    }
  }

  /// Sends the FCM token to the backend Go API endpoint `/auth/fcm-token` or `/perfil/fcm-token`
  Future<void> registerTokenWithBackend(String token) async {
    try {
      await apiClient.dio.post('/auth/fcm-token', data: {'fcm_token': token});
    } catch (_) {
      try {
        await apiClient.dio.post(
          '/perfil/fcm-token',
          data: {'fcm_token': token},
        );
      } catch (e) {
        debugPrint('Error registering FCM token with backend: $e');
      }
    }
  }
}
