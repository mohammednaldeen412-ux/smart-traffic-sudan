import 'package:cloud_firestore/cloud_firestore.dart';

class DisputeModel {
  final String id;
  final String violationId;
  final String userId;
  final String plateNumber;
  final String reasonCategory; // سبب الاعتراض
  final String description; // الشرح التفصيلي
  final String? evidenceAttachment; // صورة أو وثيقة إثبات
  final DateTime submissionDate;
  final String status; // قيد المراجعة الفنية، مقبول (إلغاء الغرامة)، مرفوض
  final String? reviewerOfficer; // الضابط المراجع
  final String? reviewNotes; // رد شرطة المرور
  final DateTime? reviewedDate;

  DisputeModel({
    required this.id,
    required this.violationId,
    required this.userId,
    required this.plateNumber,
    required this.reasonCategory,
    required this.description,
    this.evidenceAttachment,
    DateTime? submissionDate,
    this.status = 'قيد المراجعة الفنية',
    this.reviewerOfficer,
    this.reviewNotes,
    this.reviewedDate,
  }) : submissionDate = submissionDate ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'violationId': violationId,
        'userId': userId,
        'plateNumber': plateNumber,
        'reasonCategory': reasonCategory,
        'description': description,
        'evidenceAttachment': evidenceAttachment,
        'submissionDate': submissionDate,
        'status': status,
        'reviewerOfficer': reviewerOfficer,
        'reviewNotes': reviewNotes,
        'reviewedDate': reviewedDate,
      };

  factory DisputeModel.fromJson(Map<String, dynamic> json) => DisputeModel(
        id: json['id'] as String,
        violationId: json['violationId'] as String,
        userId: json['userId'] as String,
        plateNumber: json['plateNumber'] as String,
        reasonCategory: json['reasonCategory'] as String,
        description: json['description'] as String,
        evidenceAttachment: json['evidenceAttachment'] as String?,
        submissionDate: _parseDateTime(json['submissionDate']),
        status: json['status'] as String? ?? 'قيد المراجعة الفنية',
        reviewerOfficer: json['reviewerOfficer'] as String?,
        reviewNotes: json['reviewNotes'] as String?,
        reviewedDate: json['reviewedDate'] != null
            ? _parseDateTime(json['reviewedDate'])
            : null,
      );

  static DateTime _parseDateTime(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.parse(date);
    return DateTime.now();
  }

  DisputeModel copyWith({
    String? status,
    String? reviewerOfficer,
    String? reviewNotes,
    DateTime? reviewedDate,
  }) {
    return DisputeModel(
      id: id,
      violationId: violationId,
      userId: userId,
      plateNumber: plateNumber,
      reasonCategory: reasonCategory,
      description: description,
      evidenceAttachment: evidenceAttachment,
      submissionDate: submissionDate,
      status: status ?? this.status,
      reviewerOfficer: reviewerOfficer ?? this.reviewerOfficer,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      reviewedDate: reviewedDate ?? this.reviewedDate,
    );
  }
}
