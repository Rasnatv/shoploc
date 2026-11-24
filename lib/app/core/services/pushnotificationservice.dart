import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shoploc/app/core/utils/object_factory.dart';
import 'package:shoploc/app/router/app_router.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final _fm = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  /// NotificationBloc listens to this to refresh the list and badge.
  final _foregroundCtrl = StreamController<void>.broadcast();
  Stream<void> get onForegroundMessage => _foregroundCtrl.stream;

  static const _channel = AndroidNotificationChannel(
    'shoploc_default', 'Shoploc Notifications',
    importance: Importance.high,
  );

  Future<void> init() async {
    await _fm.requestPermission();

    await _local.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (r) {
        if (r.payload != null) _handleTap(jsonDecode(r.payload!));
      },
    );
    await _local
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _saveToken(await _fm.getToken());
    _fm.onTokenRefresh.listen(_saveToken);

    FirebaseMessaging.onMessage.listen(_onForeground);
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _handleTap(m.data));

    // App opened from a terminated state by tapping a push
    final initial = await _fm.getInitialMessage();
    if (initial != null) {
      Future.delayed(const Duration(seconds: 1), () => _handleTap(initial.data));
    }
  }

  Future<void> _saveToken(String? token) async {
    if (token == null || token.isEmpty) return;
    ObjectFactory().prefs.setFcmToken(fcmToken: token);
    // TODO: if logged in and the backend has an "update token" endpoint, call it here.
  }

  Future<void> _onForeground(RemoteMessage m) async {
    _foregroundCtrl.add(null);
    final n = m.notification;
    // Android doesn't show pushes in the foreground, so show a local one.
    if (n != null && Platform.isAndroid) {
      await _local.show(
        m.hashCode, n.title, n.body,
        NotificationDetails(
          android: AndroidNotificationDetails(_channel.id, _channel.name,
              importance: Importance.high, priority: Priority.high),
        ),
        payload: jsonEncode(m.data),
      );
    }
  }

  void _handleTap(Map<String, dynamic> data) {
    final router = AppRouter.router;
    switch (data['type']?.toString()) {
      case 'order':
        router.push(AppRouter.orders);
        break;
      case 'product':
        final id = int.tryParse(data['product_id']?.toString() ?? '');
        id != null
            ? router.push(AppRouter.productPath(id))
            : router.push(AppRouter.notifications);
        break;
      default:
        router.push(AppRouter.notifications);
    }
  }
}