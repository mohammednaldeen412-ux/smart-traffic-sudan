import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLogModel {
  final String id;
  final String userId;
  final String action; // e.g., "LOGIN", "UPDATE_VEHICLE", "PAY_VIOLATION"
  final String resourceId;
  final String resourceType; // e.g., "User", "Vehicle", "Violation"
  final DateTime timestamp;
  final Map<String, dynamic>? details;
  final String? ipAddress;

  AuditLogModel({
    required this.id,
    required this.userId,
    required this.action,
    required this.resourceId,
    required this.resourceType,
    DateTime? timestamp,
    this.details,
    this.ipAddress,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'action': action,
        'resourceId': resourceId,
        'resourceType': resourceType,
        'timestamp': Timestamp.fromDate(timestamp),
        'details': details,
        'ipAddress': ipAddress,
      };

  factory AuditLogModel.fromJson(Map<String, dynamic> json) => AuditLogModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        action: json['action'] as String,
        resourceId: json['resourceId'] as String,
        resourceType: json['resourceType'] as String,
        timestamp: _parseDateTime(json['timestamp']),
        details: json['details'] as Map<String, dynamic>?,
        ipAddress: json['ipAddress'] as String?,
      );

  static DateTime _parseDateTime(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.parse(date);
    return DateTime.now();
  }
}
