import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../constants/sudan_locations.dart';
import '../../models/dispute_model.dart';
import '../../models/vehicle_model.dart';
import '../../models/violation_model.dart';
import '../../models/payment_receipt_model.dart';
import '../../models/audit_log_model.dart';
import 'notification_service.dart';

class TrafficService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // قائمة محليات النيل الأبيض المعتمدة
  static const List<String> whiteNileLocalities = SudanLocations.whiteNileLocalities;

  List<VehicleModel> _vehicles = [];
  List<ViolationModel> _violations = [];
  List<PaymentReceiptModel> _receipts = [];
  List<DisputeModel> _disputes = [];
  List<ViolationModel> _officerViolations = [];
  List<ViolationModel> _allViolations = []; // للمسؤول فقط
  bool _isLoading = false;

  StreamSubscription? _vehiclesSub;
  StreamSubscription? _violationsSub;
  StreamSubscription? _receiptsSub;
  StreamSubscription? _disputesSub;
  StreamSubscription? _officerViolationsSub;
  StreamSubscription? _adminViolationsSub;

  List<VehicleModel> get vehicles => List.unmodifiable(_vehicles);
  List<ViolationModel> get violations => List.unmodifiable(_violations);
  List<PaymentReceiptModel> get receipts => List.unmodifiable(_receipts);
  List<DisputeModel> get disputes => List.unmodifiable(_disputes);
  List<ViolationModel> get allViolations => List.unmodifiable(_allViolations);
  bool get isLoading => _isLoading;

  // إحصائيات المواطن
  int get totalVehiclesCount => _vehicles.length;
  int get unpaidViolationsCount => _violations.where((v) => !v.isPaid).length;
  int get paidViolationsCount => _violations.where((v) => v.isPaid).length;
  double get totalUnpaidAmount => _violations
      .where((v) => !v.isPaid)
      .fold(0.0, (acc, item) => acc + item.amount);

  // إحصائيات المسؤول الكلية
  double get globalTotalRevenue => _allViolations
      .where((v) => v.isPaid)
      .fold(0.0, (acc, item) => acc + item.amount);
  
  int get globalTotalViolations => _allViolations.length;
  int get globalUnpaidCount => _allViolations.where((v) => !v.isPaid).length;

  TrafficService() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _initializeData();
      } else {
        _clearData();
      }
    });
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }

  void _cancelSubscriptions() {
    _vehiclesSub?.cancel();
    _violationsSub?.cancel();
    _receiptsSub?.cancel();
    _disputesSub?.cancel();
    _officerViolationsSub?.cancel();
    _adminViolationsSub?.cancel();
  }

  void _clearData() {
    _cancelSubscriptions();
    _vehicles = [];
    _violations = [];
    _receipts = [];
    _disputes = [];
    _officerViolations = [];
    _allViolations = [];
    notifyListeners();
  }

  void _initializeData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    _cancelSubscriptions();

    // التحقق من صلاحيات المستخدم (ضابط أو مسؤول) لتحميل البيانات المناسبة
    String? officerBadge;
    bool isAdmin = false;
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        final role = data?['role'];
        if (role == 'officer') {
          officerBadge = data?['officerBadgeNumber'];
        } else if (role == 'admin') {
          isAdmin = true;
        }
      }
    } catch (e) {
      debugPrint('Error fetching user profile in TrafficService: $e');
    }

    // الاستماع لمركبات المواطن
    _vehiclesSub = _firestore.collection('vehicles')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      _vehicles = snapshot.docs.map((doc) => VehicleModel.fromJson(doc.data())).toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('Error listening to vehicles: $e');
      _isLoading = false;
      notifyListeners();
    });

    // الاستماع لمخالفات المواطن
    _violationsSub = _firestore.collection('violations')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      _violations = snapshot.docs.map((doc) => ViolationModel.fromJson(doc.data())).toList();
      _violations.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    }, onError: (e) => debugPrint('Error listening to violations: $e'));

    // الاستماع للإيصالات
    _receiptsSub = _firestore.collection('receipts')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      _receipts = snapshot.docs.map((doc) => PaymentReceiptModel.fromJson(doc.data())).toList();
      _receipts.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
      notifyListeners();
    }, onError: (e) => debugPrint('Error listening to receipts: $e'));

    // الاستماع للاعتراضات
    _disputesSub = _firestore.collection('disputes')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      _disputes = snapshot.docs.map((doc) => DisputeModel.fromJson(doc.data())).toList();
      _disputes.sort((a, b) => b.submissionDate.compareTo(a.submissionDate));
      notifyListeners();
    }, onError: (e) => debugPrint('Error listening to disputes: $e'));

    // الاستماع لمخالفات الضابط (تحديث لحظي للنوبة الميدانية)
    if (officerBadge != null) {
      _officerViolationsSub = _firestore.collection('violations')
          .where('officerBadge', isEqualTo: officerBadge)
          .snapshots()
          .listen((snapshot) {
        _officerViolations = snapshot.docs.map((doc) => ViolationModel.fromJson(doc.data())).toList();
        _officerViolations.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      }, onError: (e) => debugPrint('Error listening to officer violations: $e'));
    }

    // الاستماع لكافة المخالفات للمسؤول (Admin) - متطلب رقم 29
    if (isAdmin) {
      _adminViolationsSub = _firestore.collection('violations')
          .orderBy('date', descending: true)
          .snapshots()
          .listen((snapshot) {
        _allViolations = snapshot.docs.map((doc) => ViolationModel.fromJson(doc.data())).toList();
        notifyListeners();
      }, onError: (e) => debugPrint('Error listening to all violations: $e'));
    }
  }

  /// فحص واستعلام فوري عن أي لوحة لصالح الضابط الميداني - تم تحسينه للربط الذكي
  Future<VehicleModel?> lookupVehicleByPlate(String plateNumber, {String? stateCode}) async {
    final cleanNum = plateNumber.trim();
    
    try {
      // 1. محاولة البحث بالرقم والولاية (الطريقة الرسمية)
      Query query = _firestore.collection('vehicles').where('plateNumber', isEqualTo: cleanNum);
      if (stateCode != null && stateCode.isNotEmpty) {
        query = query.where('plateStateCode', isEqualTo: stateCode);
      }
      
      var snapshot = await query.limit(1).get();
      
      // 2. إذا لم يجد، يبحث بالرقم فقط (للمركبات المسجلة قديماً)
      if (snapshot.docs.isEmpty) {
        snapshot = await _firestore.collection('vehicles')
            .where('plateNumber', isEqualTo: cleanNum)
            .limit(1)
            .get();
      }

      // 3. محاولة أخيرة: البحث عن الرقم مدمجاً مع الولاية (إذا كتبها المواطن يدوياً)
      if (snapshot.docs.isEmpty && stateCode != null) {
        final fuzzyPlate = '$stateCode $cleanNum';
        snapshot = await _firestore.collection('vehicles')
            .where('plateNumber', isEqualTo: fuzzyPlate)
            .limit(1)
            .get();
      }

      if (snapshot.docs.isNotEmpty) {
        return VehicleModel.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error looking up vehicle: $e');
    }
    return null;
  }

  /// إضافة سجل عمليات
  Future<void> logActivity(AuditLogModel log) async {
    try {
      await _firestore.collection('audit_logs').doc(log.id).set(log.toJson());
    } catch (e) {
      debugPrint('Error logging activity: $e');
    }
  }

  /// إصدار مخالفة ميدانية فورية بواسطة الضابط
  Future<ViolationModel> issueOfficerTicket({
    required String plateNumber,
    required String plateStateCode,
    required String violationType,
    required double amount,
    required String locationName,
    required double latitude,
    required double longitude,
    required String officerName,
    required String officerBadge,
    required String locality,
    required String city,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // التأكد من أن المحلية تابعة للنيل الأبيض (نطاق العمليات)
      if (!whiteNileLocalities.contains(locality)) {
        throw Exception('المحلية المحددة لا تتبع لولاية النيل الأبيض (نطاق المشروع)');
      }

      // التحقق من عدم تكرار المخالفة لنفس المركبة في آخر ساعة (متطلب 12)
      // استعلام برقم اللوحة فقط لتفادي أخطاء الفهرسة المركبة (Composite Index)
      final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
      final recentViolations = await _firestore.collection('violations')
          .where('plateNumber', isEqualTo: plateNumber)
          .limit(20)
          .get();

      // فلترة الولاية والتاريخ ونوع المخالفة في الذاكرة
      final duplicate = recentViolations.docs.any((doc) {
        final data = doc.data();
        if (data['plateStateCode'] != plateStateCode) return false;
        if (data['violationType'] != violationType) return false;

        final dynamic dateField = data['date'];
        DateTime? violationDate;
        if (dateField is Timestamp) {
          violationDate = dateField.toDate();
        } else if (dateField is String) {
          violationDate = DateTime.tryParse(dateField);
        }

        if (violationDate != null && violationDate.isAfter(oneHourAgo)) {
          return true;
        }
        return false;
      });

      if (duplicate) {
        throw Exception('هذه المخالفة مسجلة بالفعل لهذه المركبة خلال الساعة الماضية (منعاً للتكرار)');
      }

      // ربط المخالفة بالمالك إذا كانت المركبة مسجلة
      final matchedVeh = await lookupVehicleByPlate(plateNumber, stateCode: plateStateCode);
      final targetUserId = matchedVeh?.userId ?? 'usr_unregistered';
      final targetVehicleId = matchedVeh?.id ?? 'veh_unlinked_${const Uuid().v4().substring(0, 8)}';

      final ticketId = 'VIO-SD-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final newViolation = ViolationModel(
        id: ticketId,
        userId: targetUserId,
        vehicleId: targetVehicleId,
        plateNumber: plateNumber,
        plateStateCode: plateStateCode,
        violationType: violationType,
        amount: amount,
        date: DateTime.now(),
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
        officerName: officerName,
        officerBadge: officerBadge,
        locality: locality,
        city: city,
        isPaid: false,
      );

      await _firestore.collection('violations').doc(ticketId).set(newViolation.toJson());

      // تسجيل العملية (Audit Log)
      await logActivity(AuditLogModel(
        id: const Uuid().v4(),
        userId: _auth.currentUser?.uid ?? 'system',
        action: 'ISSUE_TICKET',
        resourceId: ticketId,
        resourceType: 'Violation',
        details: {'plate': plateNumber, 'type': violationType},
      ));

      // إشعار FCM للمواطن صاحب المركبة (إن كانت مسجلة)
      if (targetUserId != 'usr_unregistered') {
        try {
          final notifService = NotificationService();
          await notifService.sendViolationIssuedNotification(
            targetUserId: targetUserId,
            violationId: ticketId,
            plateNumber: '$plateStateCode - $plateNumber',
            violationType: violationType,
            amount: amount,
          );
        } catch (e) {
          debugPrint('[FCM] Could not send violation notification: $e');
        }
      }

      return newViolation;
    } catch (e) {
      debugPrint('Error issuing ticket: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تقديم اعتراض على مخالفة من قِبل المواطن
  Future<DisputeModel> submitDispute({
    required String violationId,
    required String userId,
    required String plateNumber,
    required String reasonCategory,
    required String description,
    String? evidenceAttachment,
  }) async {
    _isLoading = true;
    notifyListeners();

    final disputeId = 'DSP-SD-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    final dispute = DisputeModel(
      id: disputeId,
      violationId: violationId,
      userId: userId,
      plateNumber: plateNumber,
      reasonCategory: reasonCategory,
      description: description,
      evidenceAttachment: evidenceAttachment,
      submissionDate: DateTime.now(),
      status: 'قيد المراجعة الفنية',
    );

    final batch = _firestore.batch();
    
    batch.set(_firestore.collection('disputes').doc(disputeId), dispute.toJson());
    
    batch.update(_firestore.collection('violations').doc(violationId), {
      'hasDispute': true,
      'disputeId': disputeId,
      'disputeStatus': 'قيد المراجعة الفنية',
    });

    await batch.commit();

    // تسجيل العملية
    await logActivity(AuditLogModel(
      id: const Uuid().v4(),
      userId: _auth.currentUser?.uid ?? 'system',
      action: 'SUBMIT_DISPUTE',
      resourceId: disputeId,
      resourceType: 'Dispute',
      details: {'violationId': violationId, 'plate': plateNumber},
    ));

    _isLoading = false;
    notifyListeners();
    return dispute;
  }

  /// مراجعة والبت في الاعتراض
  Future<void> resolveDispute({
    required String disputeId,
    required bool isAccepted,
    required String officerName,
    required String notes,
  }) async {
    final disputeDoc = await _firestore.collection('disputes').doc(disputeId).get();
    if (!disputeDoc.exists) return;
    
    final data = disputeDoc.data() as Map<String, dynamic>;
    final violationId = data['violationId'] as String;
    
    final updatedStatus = isAccepted ? 'مقبول (تم إلغاء الغرامة)' : 'مرفوض';
    
    final batch = _firestore.batch();
    
    batch.update(_firestore.collection('disputes').doc(disputeId), {
      'status': updatedStatus,
      'reviewerOfficer': officerName,
      'reviewNotes': notes,
      'reviewedDate': FieldValue.serverTimestamp(),
    });

    Map<String, dynamic> violationUpdates = {
      'disputeStatus': updatedStatus,
    };
    
    if (isAccepted) {
      violationUpdates['isPaid'] = true;
      violationUpdates['paidDate'] = FieldValue.serverTimestamp();
      violationUpdates['paymentMethod'] = 'إلغاء رسمي بموجب قرار الاعتراض';
    }
    
    batch.update(_firestore.collection('violations').doc(violationId), violationUpdates);

    await batch.commit();

    // تسجيل العملية
    await logActivity(AuditLogModel(
      id: const Uuid().v4(),
      userId: _auth.currentUser?.uid ?? 'system',
      action: 'RESOLVE_DISPUTE',
      resourceId: disputeId,
      resourceType: 'Dispute',
      details: {'status': updatedStatus, 'officer': officerName},
    ));

    notifyListeners();
  }

  /// إحصائيات وسجل مخالفات الضابط خلال نوبته
  List<ViolationModel> getOfficerShiftViolations(String officerBadge) {
    return _officerViolations;
  }

  /// إضافة مركبة جديدة مع تحقق (تم تخفيف القيود للتطوير)
  Future<bool> addVehicle(VehicleModel vehicle) async {
    _isLoading = true;
    notifyListeners();

    try {
      /* 
      // تم تعطيل الفحص الصارم مؤقتاً للتطوير
      if (!SudanLocations.isValidWhiteNileLocality(vehicle.locality)) {
        throw Exception('المحلية المحددة (${vehicle.locality}) غير مطابقة لنطاق ولاية النيل الأبيض التشغيلي');
      }
      */

      await _firestore.collection('vehicles').doc(vehicle.id).set(vehicle.toJson());
      
      // تسجيل العملية
      await logActivity(AuditLogModel(
        id: const Uuid().v4(),
        userId: _auth.currentUser?.uid ?? 'system',
        action: 'ADD_VEHICLE',
        resourceId: vehicle.id,
        resourceType: 'Vehicle',
        details: {'plate': vehicle.plateNumber, 'chassis': vehicle.chassisNumber},
      ));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding vehicle: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// سداد المخالفة (متطلب 19 و 20)
  Future<PaymentReceiptModel> payViolation({
    required String violationId,
    required String paymentMethod,
    required String payerName,
    required String payerNationalId,
  }) async {
    _isLoading = true;
    notifyListeners();

    final violationDoc = await _firestore.collection('violations').doc(violationId).get();
    if (!violationDoc.exists) {
      _isLoading = false;
      notifyListeners();
      throw Exception('المخالفة غير موجودة');
    }

    final violationData = violationDoc.data() as Map<String, dynamic>;
    final transactionId = 'TXN-SD-${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';
    final verificationHash = const Uuid().v4().replaceAll('-', '').substring(0, 16).toUpperCase();

    final receipt = PaymentReceiptModel(
      transactionId: transactionId,
      violationId: violationId,
      violationType: violationData['violationType'] as String,
      amount: (violationData['amount'] as num).toDouble(),
      paymentMethod: paymentMethod,
      paymentDate: DateTime.now(),
      payerName: payerName,
      payerNationalId: payerNationalId,
      plateNumber: '${violationData['plateStateCode']} - ${violationData['plateNumber']}',
      verificationHash: verificationHash,
    );

    final batch = _firestore.batch();
    
    batch.set(_firestore.collection('receipts').doc(transactionId), {
      ...receipt.toJson(),
      'userId': _auth.currentUser?.uid,
    });
    
    batch.update(_firestore.collection('violations').doc(violationId), {
      'isPaid': true,
      'paidDate': FieldValue.serverTimestamp(),
      'receiptId': transactionId,
      'paymentMethod': paymentMethod,
    });

    await batch.commit();

    // تسجيل العملية الحساسة
    await logActivity(AuditLogModel(
      id: const Uuid().v4(),
      userId: _auth.currentUser?.uid ?? 'system',
      action: 'PAY_VIOLATION',
      resourceId: violationId,
      resourceType: 'Violation',
      details: {'amount': receipt.amount, 'method': paymentMethod, 'txnId': transactionId},
    ));

    // إشعار FCM تأكيد الدفع
    try {
      final uid = _auth.currentUser?.uid ?? '';
      if (uid.isNotEmpty) {
        final notifService = NotificationService();
        await notifService.sendPaymentConfirmedNotification(
          targetUserId: uid,
          transactionId: transactionId,
          violationId: violationId,
          amount: receipt.amount,
        );
      }
    } catch (e) {
      debugPrint('[FCM] Could not send payment notification: $e');
    }

    _isLoading = false;
    notifyListeners();
    return receipt;
  }

  ViolationModel? getViolationById(String id) {
    try {
      return _allViolations.firstWhere((v) => v.id == id);
    } catch (_) {
      try {
        return _violations.firstWhere((v) => v.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  VehicleModel? getVehicleById(String id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }
}
