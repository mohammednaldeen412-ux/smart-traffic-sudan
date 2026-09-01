import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// نموذج إشعار داخلي للعرض في المقدمة
class InAppNotification {
  final String title;
  final String body;
  final String type; // 'violation' | 'payment' | 'announcement' | 'general'
  final String? resourceId;
  final DateTime receivedAt;

  InAppNotification({
    required this.title,
    required this.body,
    required this.type,
    this.resourceId,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();
}

/// خدمة الإشعارات الشاملة (FCM + In-App)
class NotificationService extends ChangeNotifier {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final StreamController<RemoteMessage> _notificationClickController =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<InAppNotification> _inAppController =
      StreamController<InAppNotification>.broadcast();

  Stream<RemoteMessage> get notificationClicks =>
      _notificationClickController.stream;

  /// Stream للإشعارات الداخلية (تُعرض كـ Banner في المقدمة)
  Stream<InAppNotification> get inAppNotifications => _inAppController.stream;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  final List<InAppNotification> _recentNotifications = [];
  List<InAppNotification> get recentNotifications =>
      List.unmodifiable(_recentNotifications);

  NotificationService() {
    _init();
  }

  Future<void> _init() async {
    // التحقق من الرسالة التي فتحت التطبيق (إذا كان مغلقاً تماماً)
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage);
    }

    // طلب الإذن (مهم لنظام iOS و Android 13+)
    final settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _fcmToken = await _fcm.getToken();
      debugPrint('[FCM] Token: $_fcmToken');
      await _updateTokenInFirestore();
    }

    // الاستماع لتحديث التوكن
    _fcm.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      _updateTokenInFirestore();
    });

    // ─── Foreground Messages: عرض Banner داخلي ───────────────────────────────
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] Foreground: ${message.notification?.title}');
      final inApp = _remoteMessageToInApp(message);
      _recentNotifications.insert(0, inApp);
      if (_recentNotifications.length > 20) _recentNotifications.removeLast();
      _inAppController.add(inApp);
      notifyListeners();
    });

    // ─── Background → App Opened ────────────────────────────────────────────
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] App opened via notification: ${message.notification?.title}');
      _handleNotificationClick(message);
    });
  }

  void _handleNotificationClick(RemoteMessage message) {
    _notificationClickController.add(message);
  }

  InAppNotification _remoteMessageToInApp(RemoteMessage message) {
    final data = message.data;
    return InAppNotification(
      title: message.notification?.title ?? data['title'] ?? 'إشعار جديد',
      body: message.notification?.body ?? data['body'] ?? '',
      type: data['type'] ?? 'general',
      resourceId: data['resourceId'],
    );
  }

  Future<void> _updateTokenInFirestore() async {
    final user = _auth.currentUser;
    if (user != null && _fcmToken != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': _fcmToken,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('[FCM] Error updating token: $e');
      }
    }
  }

  // ─── الاشتراك في Topics ──────────────────────────────────────────────────
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      debugPrint('[FCM] Subscribed to: $topic');
    } catch (e) {
      debugPrint('[FCM] Subscribe error: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      debugPrint('[FCM] Unsubscribed from: $topic');
    } catch (e) {
      debugPrint('[FCM] Unsubscribe error: $e');
    }
  }

  // ─── الاشتراك حسب دور المستخدم ───────────────────────────────────────────
  Future<void> subscribeByRole({required bool isOfficer}) async {
    if (isOfficer) {
      await subscribeToTopic('officers_white_nile');
      await subscribeToTopic('announcements_official');
    } else {
      await subscribeToTopic('citizens_white_nile');
    }
    await subscribeToTopic('all_users');
  }

  // ─── حفظ الإشعار في Firestore (سجل دائم) ────────────────────────────────
  Future<void> _saveNotificationToFirestore({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? resourceId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'resourceId': resourceId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[FCM] Error saving notification: $e');
    }
  }

  // ─── الإشعارات الداخلية (In-App trigger) ────────────────────────────────
  /// يُطلق إشعاراً داخلياً مباشرة بدون FCM (للتغييرات المحلية الفورية)
  void triggerInAppNotification({
    required String title,
    required String body,
    required String type,
    String? resourceId,
  }) {
    final notif = InAppNotification(
      title: title,
      body: body,
      type: type,
      resourceId: resourceId,
    );
    _recentNotifications.insert(0, notif);
    if (_recentNotifications.length > 20) _recentNotifications.removeLast();
    _inAppController.add(notif);
    notifyListeners();
  }

  // ─── إشعار: قيد مخالفة جديدة على المواطن ───────────────────────────────
  /// يُحفظ الإشعار في Firestore ويُطلق InApp Banner
  Future<void> sendViolationIssuedNotification({
    required String targetUserId,
    required String violationId,
    required String plateNumber,
    required String violationType,
    required double amount,
  }) async {
    const title = '⚠️ تم قيد مخالفة مرورية جديدة';
    final body =
        'لوحة $plateNumber — $violationType\nالمبلغ: ${amount.toStringAsFixed(0)} ج.س.';

    await _saveNotificationToFirestore(
      userId: targetUserId,
      title: title,
      body: body,
      type: 'violation',
      resourceId: violationId,
    );

    // إطلاق InApp للمستخدم الحالي إذا كان هو نفس المستهدف
    if (_auth.currentUser?.uid == targetUserId) {
      triggerInAppNotification(
        title: title,
        body: body,
        type: 'violation',
        resourceId: violationId,
      );
    }

    debugPrint('[FCM] Violation notification saved for $targetUserId');
  }

  // ─── إشعار: تأكيد سداد مخالفة ───────────────────────────────────────────
  Future<void> sendPaymentConfirmedNotification({
    required String targetUserId,
    required String transactionId,
    required String violationId,
    required double amount,
  }) async {
    const title = '✅ تم تأكيد سداد المخالفة';
    final body =
        'رقم المعاملة: $transactionId\nالمبلغ المسدد: ${amount.toStringAsFixed(0)} ج.س.\nتم التوثيق في السجل الرسمي.';

    await _saveNotificationToFirestore(
      userId: targetUserId,
      title: title,
      body: body,
      type: 'payment',
      resourceId: violationId,
    );

    triggerInAppNotification(
      title: title,
      body: body,
      type: 'payment',
      resourceId: violationId,
    );

    debugPrint('[FCM] Payment notification saved for $targetUserId — TXN: $transactionId');
  }

  // ─── إشعار: تعميم إداري/أمني للضباط ────────────────────────────────────
  /// يُرسل للـ topic الخاص بالضباط (يصل لجميع الضباط المشتركين)
  Future<void> sendAnnouncementNotification({
    required String announcementId,
    required String title,
    required String summary,
    required String priority, // عاجل، تنبيه، عام
  }) async {
    final emoji = priority == 'عاجل' ? '🚨' : priority == 'تنبيه' ? '⚡' : '📢';
    final notifTitle = '$emoji تعميم $priority — إدارة مرور النيل الأبيض';

    // حفظ في Firestore للضباط (topic-based)
    await _firestore.collection('announcements_log').add({
      'announcementId': announcementId,
      'title': notifTitle,
      'body': summary,
      'priority': priority,
      'topic': 'officers_white_nile',
      'sentAt': FieldValue.serverTimestamp(),
    });

    // In-App للمستخدم الحالي إذا كان ضابطاً
    triggerInAppNotification(
      title: notifTitle,
      body: summary,
      type: 'announcement',
      resourceId: announcementId,
    );

    debugPrint('[FCM] Announcement notification saved — $notifTitle');
  }

  // ─── إشعار: تحديث حالة مخالفة ───────────────────────────────────────────
  Future<void> sendViolationStatusUpdateNotification({
    required String targetUserId,
    required String violationId,
    required String newStatus,
    required String plateNumber,
  }) async {
    final statusText = newStatus == 'paid'
        ? 'مسددة ✅'
        : newStatus == 'cancelled'
            ? 'ملغاة 🟢'
            : newStatus == 'disputed'
                ? 'قيد الاعتراض 🔄'
                : 'معلقة ⏳';

    final title = '📋 تحديث حالة مخالفة';
    final body = 'لوحة $plateNumber\nالحالة الجديدة: $statusText';

    await _saveNotificationToFirestore(
      userId: targetUserId,
      title: title,
      body: body,
      type: 'violation_update',
      resourceId: violationId,
    );

    if (_auth.currentUser?.uid == targetUserId) {
      triggerInAppNotification(
        title: title,
        body: body,
        type: 'violation_update',
        resourceId: violationId,
      );
    }
  }

  void markAllRead() {
    // يمكن تحديث Firestore هنا
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationClickController.close();
    _inAppController.close();
    super.dispose();
  }
}
