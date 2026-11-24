import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:suchigo_user_app/config/app_config.dart';
import 'package:suchigo_user_app/features/notifications/view/notification_screen.dart';
import 'package:suchigo_user_app/features/orders/view/order_history_screen.dart';
import 'package:suchigo_user_app/features/orders/view/track_pickup_screen.dart';
import 'package:suchigo_user_app/helpers/sp_helper.dart';
import 'package:suchigo_user_app/services/web_api_services.dart';
import 'package:suchigo_user_app/utils/sp_keys.dart' as sp_keys;
import 'package:suchigo_user_app/utils/urls.dart';

/// Top-level background message handler required by Firebase Messaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('[FCM Background] Message ID: ${message.messageId}');
    debugPrint('[FCM Background] Title: ${message.notification?.title}');
    debugPrint('[FCM Background] Body: ${message.notification?.body}');
    debugPrint('[FCM Background] Data: ${message.data}');
  } catch (e) {
    debugPrint('[FCM Background] Error handling background message: $e');
  }
}

class PushNotificationService {
  static final PushNotificationService instance =
      PushNotificationService._internal();

  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'suchigo_high_importance_channel',
    'SuchiGo Notifications',
    description:
        'Important notifications regarding pickups, waste collections, and status updates',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  bool _isInitialized = false;

  /// Initializes Firebase messaging, local notification channels, and listeners.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      // 1. Request notification permissions from user
      await requestPermission();

      // 2. Configure local notification channel for Android foreground notifications
      await _setupLocalNotifications();

      // 3. Register background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 4. Foreground notification listener
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 5. Notification opened listener (app running in background)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // 6. Check if app was opened from terminated state by a notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[FCM] App launched from terminated state via notification: ${initialMessage.data}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleNotificationTap(initialMessage);
        });
      }

      // 7. Token refresh listener
      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint('[FCM] Token refreshed: $newToken');
        syncDeviceToken(explicitToken: newToken);
      });

      // 8. Fetch current token and sync with backend
      await syncDeviceToken();
    } catch (e) {
      debugPrint('[FCM] Error initializing PushNotificationService: $e');
    }
  }

  /// Request permissions for iOS and Android 13+
  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    debugPrint('[FCM] User granted permission: ${settings.authorizationStatus}');
    return settings;
  }

  /// Configure local notifications plugin and create notification channels
  Future<void> _setupLocalNotifications() async {
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

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onSelectLocalNotification,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_channel);
    }

    // Set foreground notification presentation options for iOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Handles incoming FCM message when the app is in the FOREGROUND
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('[FCM Foreground] Received: ${message.notification?.title} - ${message.notification?.body}');
    debugPrint('[FCM Foreground] Payload data: ${message.data}');

    final notification = message.notification;
    final android = message.notification?.android;

    final title = notification?.title ??
        message.data['title']?.toString() ??
        'SuchiGo Notification';
    final body = notification?.body ?? message.data['body']?.toString() ?? '';

    // Show heads-up notification using local notifications
    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final payloadString = jsonEncode(message.data);

    await _localNotifications.show(
      notificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payloadString,
    );
  }

  /// User tapped a local notification that was shown in the foreground
  void _onSelectLocalNotification(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      try {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(jsonDecode(payload) as Map);
        _navigateToDestination(data);
      } catch (e) {
        debugPrint('[FCM] Error decoding local notification payload: $e');
        _navigateToDefault();
      }
    } else {
      _navigateToDefault();
    }
  }

  /// User tapped a notification banner from background or lock screen
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[FCM Click] Navigating with payload: ${message.data}');
    _navigateToDestination(message.data);
  }

  /// Routes to the matching screen based on notification payload data
  void _navigateToDestination(Map<String, dynamic> data) {
    final navContext = AppConfig.navKey.currentContext;
    if (navContext == null) return;

    final rawPickupId = data['pickup_id'] ?? data['pickupId'] ?? data['id'];
    final rawOrderId = data['order_id'] ?? data['orderId'] ?? data['order_number'];
    final pickupId = int.tryParse(rawPickupId?.toString() ?? '');
    final orderId = int.tryParse(rawOrderId?.toString() ?? '') ?? pickupId;

    final targetScreen = data['screen']?.toString().toLowerCase();
    final type = data['type']?.toString().toLowerCase();

    if (pickupId != null && pickupId > 0) {
      Navigator.pushNamed(
        navContext,
        TrackPickupScreen.routeName,
        arguments: TrackPickupScreenArgs(
          pickupId: pickupId,
          orderId: orderId,
        ),
      );
      return;
    }

    if (targetScreen == 'orders' ||
        targetScreen == 'order_history' ||
        type == 'order' ||
        type == 'pickup') {
      Navigator.pushNamed(
        navContext,
        OrderHistoryScreen.routeName,
      );
      return;
    }

    if (targetScreen == 'notifications' || type == 'notification') {
      Navigator.pushNamed(
        navContext,
        NotificationScreen.routeName,
      );
      return;
    }

    // Default to notifications screen
    _navigateToDefault();
  }

  void _navigateToDefault() {
    final navContext = AppConfig.navKey.currentContext;
    if (navContext != null) {
      Navigator.pushNamed(
        navContext,
        NotificationScreen.routeName,
      );
    }
  }

  /// Fetches the current FCM device token
  Future<String?> getDeviceToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await SpHelper.saveString('KEY_FCM_TOKEN', token);
      }
      return token;
    } catch (e) {
      debugPrint('[FCM] Failed to get device token: $e');
      return null;
    }
  }

  /// Sends the FCM token to the backend server to associate with the current user
  Future<void> syncDeviceToken({String? explicitToken}) async {
    try {
      final token = explicitToken ?? await getDeviceToken();
      if (token == null || token.isEmpty) return;

      debugPrint('[FCM] Registering FCM token with server: $token');
      await SpHelper.saveString('KEY_FCM_TOKEN', token);

      final authToken = await SpHelper.getString(sp_keys.keyToken);
      if (authToken == null || authToken.trim().isEmpty) {
        debugPrint('[FCM] User not yet logged in, token saved locally for sync on login');
        return;
      }

      // Send fcm_token to the backend profile edit endpoint
      await WebAPIService().initTokenToHeader();
      final response = await WebAPIService().dio.patch(
        urlProfileEdit,
        data: {'fcm_token': token},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[FCM] Successfully registered device token with server');
      } else {
        debugPrint('[FCM] Server token registration response: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[FCM] Could not sync device token with server: $e');
    }
  }
}
