import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../models/announcement_model.dart';
import 'traffic_service.dart';
import '../../models/audit_log_model.dart';

class AnnouncementService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TrafficService _trafficService;

  AnnouncementService(this._trafficService);

  /// إرسال تعميم جديد من الإدارة مع إشعار Push (محاكاة)
  Future<void> sendAnnouncement({
    required String title,
    required String content,
    AnnouncementCategory category = AnnouncementCategory.general,
    bool sendPush = true,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final id = 'ANN-${const Uuid().v4().substring(0, 8).toUpperCase()}';
    final announcement = AnnouncementModel(
      id: id,
      title: title,
      content: content,
      category: category,
      authorId: user.uid,
    );

    try {
      await _firestore.collection('announcements').doc(id).set(announcement.toJson());

      // تسجيل العملية في Audit Log
      await _trafficService.logActivity(AuditLogModel(
        id: const Uuid().v4(),
        userId: user.uid,
        action: 'CREATE_ANNOUNCEMENT',
        resourceId: id,
        resourceType: 'Announcement',
        details: {'title': title, 'category': category.name},
      ));

      if (sendPush) {
        // محاكاة إرسال إشعار Push عبر Cloud Functions
        // عملياً يتم الاشتراك في Topic: 'announcements'
        debugPrint('Push Notification Triggred: $title');
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error sending announcement: $e');
      rethrow;
    }
  }

  /// الحصول على قائمة التعاميم الفعالة
  Stream<List<AnnouncementModel>> getAnnouncements() {
    return _firestore
        .collection('announcements')
        .where('expiryDate', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('expiryDate')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnnouncementModel.fromJson(doc.data()))
            .toList());
  }

  /// الحصول على التعاميم بدون شرط التاريخ (للأرشيف)
  Stream<List<AnnouncementModel>> getAllAnnouncements() {
    return _firestore
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnnouncementModel.fromJson(doc.data()))
            .toList());
  }
}
