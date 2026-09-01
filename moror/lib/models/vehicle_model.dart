import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  final String id;
  final String userId;
  final String make;
  final String model;
  final String plateNumber;
  final String plateStateCode;
  final String plateCategoryCode;
  final String color;
  final String chassisNumber;
  final String certificateImageUrl;
  final bool isVerified;
  final bool isWanted;
  final DateTime? licenseExpiryDate;
  final DateTime createdAt;

  VehicleModel({
    required this.id,
    required this.userId,
    required this.make,
    required this.model,
    required this.plateNumber,
    this.plateStateCode = '',
    this.plateCategoryCode = '',
    required this.color,
    required this.chassisNumber,
    required this.certificateImageUrl,
    this.isVerified = false,
    this.isWanted = false,
    this.licenseExpiryDate,
    required this.createdAt,
  });

  // Computed helpers used by vehicle_card & vehicle_details
  String get fullPlateDisplay => plateNumber;

  bool get isLicenseExpired {
    if (licenseExpiryDate == null) return false;
    return DateTime.now().isAfter(licenseExpiryDate!);
  }

  int get daysUntilExpiry {
    if (licenseExpiryDate == null) return 999;
    return licenseExpiryDate!.difference(DateTime.now()).inDays;
  }

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    DateTime? expiry;
    if (json['licenseExpiryDate'] != null) {
      expiry = (json['licenseExpiryDate'] as Timestamp).toDate();
    }
    
    String cUrl = json['certificateImageUrl'] ?? '';
    // تنظيف الروابط القديمة لضمان عدم حدوث أخطاء
    if (cUrl.contains('firebasestorage')) {
      cUrl = 'https://placehold.co/400x300/1a2942/d4af37?text=شهادة+البحث';
    }

    return VehicleModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      plateNumber: json['plateNumber'] ?? '',
      plateStateCode: json['plateStateCode'] ?? '',
      plateCategoryCode: json['plateCategoryCode'] ?? '',
      color: json['color'] ?? '',
      chassisNumber: json['chassisNumber'] ?? '',
      certificateImageUrl: cUrl,
      isVerified: json['isVerified'] ?? false,
      isWanted: json['isWanted'] ?? false,
      licenseExpiryDate: expiry,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'make': make,
      'model': model,
      'plateNumber': plateNumber,
      'plateStateCode': plateStateCode,
      'plateCategoryCode': plateCategoryCode,
      'color': color,
      'chassisNumber': chassisNumber,
      'certificateImageUrl': certificateImageUrl,
      'isVerified': isVerified,
      'isWanted': isWanted,
      if (licenseExpiryDate != null)
        'licenseExpiryDate': Timestamp.fromDate(licenseExpiryDate!),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
