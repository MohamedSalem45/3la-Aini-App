import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'ala_ainy_orders';
  static const String channelName = 'على عيني - الطلبيات';

  final StreamController<Map<String, dynamic>> _notificationStream =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationStream.stream;

  Future<void> initialize() async {
    // طلب الأذونات
    await _firebaseMessaging.requestPermission(
      alert: true,
      sound: true,
      badge: true,
    );

    // تكوين الإشعارات المحلية
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );

    // استقبال الإشعارات
    FirebaseMessaging.onMessage.listen(_handleForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundNotification);

    // الحصول على الـ Token
    // final token = await _firebaseMessaging.getToken();
    // Token obtained for push notifications
  }

  Future<void> _handleForegroundNotification(RemoteMessage message) async {
    // Debug: Foreground notification received

    if (message.notification != null) {
      // Debug: Notification details received

      // عرض إشعار محلي
      await _showLocalNotification(
        message.notification!.title ?? 'على عيني',
        message.notification!.body ?? '',
        message.data,
      );
    }

    // إرسال البيانات إلى الـ stream
    _notificationStream.add(message.data);
  }

  Future<void> _handleNotificationClick(RemoteMessage message) async {
    // Debug: Notification clicked
    _notificationStream.add(message.data);
  }

  Future<void> _onSelectNotification(NotificationResponse response) async {
    // Debug: Notification selected
    _notificationStream.add({'action': 'notification_clicked'});
  }

  Future<void> _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().hashCode,
      title,
      body,
      platformChannelSpecifics,
      payload: data.toString(),
    );
  }

  // إرسال إشعار محلي عند تحديث الطلبية
  Future<void> notifyOrderStatusChange(
    String orderId,
    String status,
    String message,
  ) async {
    await _showLocalNotification(
      'تحديث الطلبية',
      message,
      {'orderId': orderId, 'status': status},
    );
  }

  // إرسال إشعار بالتوصيل القريب
  Future<void> notifyDeliveryNearby(
    String orderId,
    String driverName,
  ) async {
    await _showLocalNotification(
      'المندوب قريب منك',
      'المندوب $driverName في الطريق إليك الآن',
      {'orderId': orderId, 'action': 'delivery_nearby'},
    );
  }

  // الاشتراك في موضوع معين
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // إلغاء الاشتراك من موضوع
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  void dispose() {
    _notificationStream.close();
  }
}

// معالج الإشعارات في الخلفية
@pragma('vm:entry-point')
Future<void> _handleBackgroundNotification(RemoteMessage message) async {
  // Debug: Background notification received
}
