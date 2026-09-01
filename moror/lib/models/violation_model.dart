import 'package:cloud_firestore/cloud_firestore.dart';

enum ViolationStatus {
  pending,
  paid,
  cancelled,
  disputed,
}

class ViolationModel {
  final String id;
  final String userId;
  final String vehicleId;
  final String plateNumber;
  final String plateStateCode;
  final String violationType;
  final double amount;
  final DateTime date;
  final String state; // الولاية
  final String locality; // المحلية
  final String city; // المدينة
  final String locationName;
  final double latitude;
  final double longitude;
  final String officerName;
  final String officerBadge;
  final bool isPaid;
  final ViolationStatus violationStatus;
  final DateTime? paidDate;
  final String? receiptId;
  final String? paymentMethod;
  final String? paymentTransactionId; // معرف عملية الدفع
  final bool hasDispute;
  final String? disputeId;
  final String? disputeStatus; // قيد المراجعة الفنية، مقبول (إلغاء الغرامة)، مرفوض

  ViolationModel({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.plateNumber,
    required this.plateStateCode,
    required this.violationType,
    required this.amount,
    required this.date,
    this.state = 'النيل الأبيض',
    required this.locality,
    required this.city,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.officerName,
    required this.officerBadge,
    this.isPaid = false,
    this.violationStatus = ViolationStatus.pending,
    this.paidDate,
    this.receiptId,
    this.paymentMethod,
    this.paymentTransactionId,
    this.hasDispute = false,
    this.disputeId,
    this.disputeStatus,
  });

  String get fullPlateDisplay => '$plateStateCode 5 - $plateNumber';

  /// نص مشفر للـ QR Code الرسمي للتحقق
  String get qrPayload =>
      'SUDAN-TRAFFIC-VERIFY://VIOLATION/$id?PLATE=$plateStateCode-$plateNumber&AMT=$amount&STATUS=${violationStatus.name.toUpperCase()}&OFFICER=$officerBadge';

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'vehicleId': vehicleId,
        'plateNumber': plateNumber,
        'plateStateCode': plateStateCode,
        'violationType': violationType,
        'amount': amount,
        'date': Timestamp.fromDate(date),
        'state': state,
        'locality': locality,
        'city': city,
        'locationName': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'officerName': officerName,
        'officerBadge': officerBadge,
        'isPaid': isPaid,
        'violationStatus': violationStatus.name,
        'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
        'receiptId': receiptId,
        'paymentMethod': paymentMethod,
        'paymentTransactionId': paymentTransactionId,
        'hasDispute': hasDispute,
        'disputeId': disputeId,
        'disputeStatus': disputeStatus,
      };

  factory ViolationModel.fromJson(Map<String, dynamic> json) => ViolationModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        vehicleId: json['vehicleId'] as String,
        plateNumber: json['plateNumber'] as String,
        plateStateCode: json['plateStateCode'] as String? ?? 'خ',
        violationType: json['violationType'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: _parseDateTime(json['date']),
        state: json['state'] as String? ?? 'النيل الأبيض',
        locality: json['locality'] as String? ?? 'كوستي',
        city: json['city'] as String? ?? 'كوستي',
        locationName: json['locationName'] as String,
        latitude: (json['latitude'] as num?)?.toDouble() ?? 15.5007,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 32.5599,
        officerName: json['officerName'] as String? ?? 'الرادار الآلي المركزي',
        officerBadge: json['officerBadge'] as String? ?? 'SD-RADAR-01',
        isPaid: json['isPaid'] as bool? ?? false,
        violationStatus: _parseStatus(json['violationStatus']),
        paidDate: json['paidDate'] != null
            ? _parseDateTime(json['paidDate'])
            : null,
        receiptId: json['receiptId'] as String?,
        paymentMethod: json['paymentMethod'] as String?,
        paymentTransactionId: json['paymentTransactionId'] as String?,
        hasDispute: json['hasDispute'] as bool? ?? false,
        disputeId: json['disputeId'] as String?,
        disputeStatus: json['disputeStatus'] as String?,
      );

  static ViolationStatus _parseStatus(dynamic status) {
    if (status == 'paid') return ViolationStatus.paid;
    if (status == 'cancelled') return ViolationStatus.cancelled;
    if (status == 'disputed') return ViolationStatus.disputed;
    return ViolationStatus.pending;
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.parse(date);
    return DateTime.now();
  }

  ViolationModel copyWith({
    bool? isPaid,
    ViolationStatus? violationStatus,
    DateTime? paidDate,
    String? receiptId,
    String? paymentMethod,
    String? paymentTransactionId,
    bool? hasDispute,
    String? disputeId,
    String? disputeStatus,
  }) {
    return ViolationModel(
      id: id,
      userId: userId,
      vehicleId: vehicleId,
      plateNumber: plateNumber,
      plateStateCode: plateStateCode,
      violationType: violationType,
      amount: amount,
      date: date,
      locality: locality,
      city: city,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      officerName: officerName,
      officerBadge: officerBadge,
      isPaid: isPaid ?? this.isPaid,
      violationStatus: violationStatus ?? this.violationStatus,
      paidDate: paidDate ?? this.paidDate,
      receiptId: receiptId ?? this.receiptId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
      hasDispute: hasDispute ?? this.hasDispute,
      disputeId: disputeId ?? this.disputeId,
      disputeStatus: disputeStatus ?? this.disputeStatus,
    );
  }
}
