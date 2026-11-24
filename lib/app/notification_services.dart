import 'dart:io';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shoploc/app/core/utils/object_factory.dart';

class NotificationService with WidgetsBindingObserver {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  /// Current badge count
  int _badgeCount = 0;

  /// ---------------- INIT ----------------
  /// Call from main() → NotificationService.instance.init();
  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);

    /// 🔐 Request permission
    final settings = await _requestPermissions();
    _logPermissionState(settings);

    final bool isGranted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    await _initLocalNotifications();
    await _createAndroidChannel();
    await _setIOSForegroundOptions();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    /// 🚫 Permission NOT granted → STOP
    if (!isGranted) {
      debugPrint("🚫 Notification permission denied. Token will NOT be saved.");

      await _firebaseMessaging.deleteToken();
      ObjectFactory().prefs.setFcmToken(fcmToken: null);
      await clearBadge();
      return;
    }

    /// 🔄 Token refresh listener (ONLY if permission granted)
    _firebaseMessaging.onTokenRefresh.listen((token) {
      debugPrint("🔄 FCM Token refreshed: $token");
      ObjectFactory().prefs.setFcmToken(fcmToken: token);
    });

    /// 🍏 iOS APNs token check (must be non-null on a real device)
    if (Platform.isIOS) {
      final apns = await _getApnsTokenWithRetry();
      debugPrint(apns == null
          ? "❌ APNs token NULL → pushes cannot arrive (simulator or setup issue)"
          : "✅ APNs token OK: $apns");
    }

    /// ⏳ Delay (MIUI / OEM safe)
    await Future.delayed(const Duration(seconds: 3));

    final token = await _getTokenWithRetry();
    if (token != null) {
      debugPrint("📱 FCM Token: $token");
      ObjectFactory().prefs.setFcmToken(fcmToken: token);
    } else {
      debugPrint("❌ FCM Token is NULL");
    }

    /// 📩 Message listeners
    FirebaseMessaging.onMessage.listen((m) {
      debugPrint("🟢 FOREGROUND: id=${m.messageId}");
      _logMessage(m);
      _onForegroundMessage(m);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((m) {
      debugPrint("🟡 OPENED FROM BACKGROUND: id=${m.messageId}");
      _logMessage(m);
      _onMessageTap(m);
    });

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint("🔴 OPENED FROM KILLED STATE: id=${initialMessage.messageId}");
      _logMessage(initialMessage);
      _onMessageTap(initialMessage);
    }
  }

  /// ---------------- DEBUG HELPERS ----------------
  void _logMessage(RemoteMessage m) {
    debugPrint("   title: ${m.notification?.title}");
    debugPrint("   body: ${m.notification?.body}");
    debugPrint("   data: ${m.data}");
    debugPrint("   apple badge (aps.badge): ${m.notification?.apple?.badge}");
    debugPrint("   android count: ${m.notification?.android?.count}");
  }

  void _logPermissionState(NotificationSettings s) {
    debugPrint(
        "🔐 Permission → status=${s.authorizationStatus} alert=${s.alert} badge=${s.badge} sound=${s.sound}");
  }

  /// ---------------- PERMISSIONS ----------------
  Future<NotificationSettings> _requestPermissions() async {
    return await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// ---------------- LOCAL NOTIFICATIONS ----------------
  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint("🔔 Notification tapped: ${response.payload}");
        _clearAll();
      },
    );
  }

  Future<void> _createAndroidChannel() async {
    if (!Platform.isAndroid) return;

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Important notifications',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _setIOSForegroundOptions() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// ---------------- TOKEN (RETRY SAFE) ----------------
  Future<String?> _getTokenWithRetry() async {
    for (int i = 0; i < 3; i++) {
      try {
        final token = await _firebaseMessaging.getToken();
        if (token != null) return token;
      } catch (e) {
        debugPrint("⚠️ Token retry ${i + 1} failed: $e");
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    return null;
  }

  Future<String?> _getApnsTokenWithRetry() async {
    for (int i = 0; i < 3; i++) {
      try {
        final token = await _firebaseMessaging.getAPNSToken();
        if (token != null) return token;
      } catch (e) {
        debugPrint("⚠️ APNs retry ${i + 1} failed: $e");
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    return null;
  }

  /// ---------------- BADGE ----------------
  /// Set badge to a specific number (0 clears it)
  Future<void> setBadge(int count) async {
    _badgeCount = count < 0 ? 0 : count;
    try {
      await AppBadgePlus.updateBadge(_badgeCount);
      debugPrint("🔢 Badge set to $_badgeCount");
    } catch (e) {
      debugPrint("⚠️ Badge update failed: $e");
    }
  }

  Future<void> incrementBadge() => setBadge(_badgeCount + 1);

  Future<void> clearBadge() => setBadge(0);

  int get badgeCount => _badgeCount;

  /// ---------------- MESSAGE HANDLING ----------------
  void _onForegroundMessage(RemoteMessage message) {
    // Badge: prefer aps.badge, then data['badge'], else increment
    final apsBadge = int.tryParse(message.notification?.apple?.badge ?? '');
    final dataBadge = int.tryParse(message.data['badge']?.toString() ?? '');
    setBadge(apsBadge ?? dataBadge ?? _badgeCount + 1);

    // iOS already shows the push in foreground (presentation options above),
    // so only show a local notification on Android to avoid duplicates.
    if (Platform.isAndroid) {
      _showNotification(message);
    }
  }

  void _onMessageTap(RemoteMessage message) {
    debugPrint("📲 Notification tapped: ${message.data}");
    _clearAll();
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const android = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: android,
      iOS: ios,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }

  /// ---------------- UTILS ----------------
  /// Clears shown notifications AND resets the badge.
  /// If you want the badge to reflect real unread counts instead,
  /// remove `clearBadge()` here and call `setBadge(unreadCount)` yourself.
  Future<void> _clearAll() async {
    await _localNotifications.cancelAll();
    await clearBadge();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _clearAll();
    }
  }
}

/// ---------------- BACKGROUND HANDLER ----------------
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("📦 BACKGROUND: id=${message.messageId}");
  debugPrint("   title: ${message.notification?.title}");
  debugPrint("   data: ${message.data}");
  debugPrint("   apple badge (aps.badge): ${message.notification?.apple?.badge}");

  // Android: update badge from data payload (iOS uses aps.badge from backend)
  final serverBadge = int.tryParse(message.data['badge']?.toString() ?? '');
  if (serverBadge != null) {
    try {
      await AppBadgePlus.updateBadge(serverBadge);
    } catch (e) {
      debugPrint("⚠️ Background badge update failed: $e");
    }
  }
}