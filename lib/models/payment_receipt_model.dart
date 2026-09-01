import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentReceiptModel {
  final String transactionId;
  final String violationId;
  final String violationType;
  final double amount;
  final String paymentMethod; // بنكك، فوري، أوكاش، بطاقة مصرفية
  final DateTime paymentDate;
  final String payerName;
  final String payerNationalId;
  final String plateNumber;
  final String verificationHash;
  final String status; // ناجحة، مكتملة

  // حقول Pipeline الجديدة
  final String? gatewayRef;          // مرجع بوابة الدفع الخارجية
  final String? bankingTransactionId; // رقم المعاملة البنكية الرسمي
  final DateTime? confirmedAt;        // وقت تأكيد السيرفر
  final DateTime? initiatedAt;        // وقت بدء الطلب
  final String paymentStatus;         // pending / processing / confirmed / failed

  PaymentReceiptModel({
    required this.transactionId,
    required this.violationId,
    required this.violationType,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    required this.payerName,
    required this.payerNationalId,
    required this.plateNumber,
    required this.verificationHash,
    this.status = 'مكتملة وناجحة',
    this.gatewayRef,
    this.bankingTransactionId,
    this.confirmedAt,
    this.initiatedAt,
    this.paymentStatus = 'مكتملة وناجحة',
  });

  String get qrData =>
      'SUDAN-TRAFFIC-RECEIPT://$transactionId?AMT=$amount&DATE=${paymentDate.toIso8601String()}&HASH=$verificationHash';

  /// عرض رقم المعاملة البنكية الرسمي
  String get displayBankingRef => bankingTransactionId ?? transactionId;

  Map<String, dynamic> toJson() => {
        'transactionId': transactionId,
        'violationId': violationId,
        'violationType': violationType,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'paymentDate': Timestamp.fromDate(paymentDate),
        'payerName': payerName,
        'payerNationalId': payerNationalId,
        'plateNumber': plateNumber,
        'verificationHash': verificationHash,
        'status': status,
        'gatewayRef': gatewayRef,
        'bankingTransactionId': bankingTransactionId,
        'confirmedAt':
            confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
        'initiatedAt':
            initiatedAt != null ? Timestamp.fromDate(initiatedAt!) : null,
        'paymentStatus': paymentStatus,
      };

  factory PaymentReceiptModel.fromJson(Map<String, dynamic> json) =>
      PaymentReceiptModel(
        transactionId: json['transactionId'] as String,
        violationId: json['violationId'] as String,
        violationType: json['violationType'] as String,
        amount: (json['amount'] as num).toDouble(),
        paymentMethod: json['paymentMethod'] as String,
        paymentDate: _parseDateTime(json['paymentDate']),
        payerName: json['payerName'] as String,
        payerNationalId: json['payerNationalId'] as String,
        plateNumber: json['plateNumber'] as String,
        verificationHash: json['verificationHash'] as String,
        status: json['status'] as String? ?? 'مكتملة وناجحة',
        gatewayRef: json['gatewayRef'] as String?,
        bankingTransactionId: json['bankingTransactionId'] as String?,
        confirmedAt: json['confirmedAt'] != null
            ? _parseDateTime(json['confirmedAt'])
            : null,
        initiatedAt: json['initiatedAt'] != null
            ? _parseDateTime(json['initiatedAt'])
            : null,
        paymentStatus: json['paymentStatus'] as String? ?? 'مكتملة وناجحة',
      );

  static DateTime _parseDateTime(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.parse(date);
    return DateTime.now();
  }
}
