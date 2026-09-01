import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  final String id;
  final String userId;
  final String ownerName; // اسم المالك
  final String ownerNationalId; // الرقم الوطني للمالك
  final String plateNumber; // e.g. "12345"
  final String plateStateCode; // e.g. "خ" (الخرطوم) or "ب" (البحر الأحمر)
  final String plateCategoryCode; // e.g. "5" (ملاكي)
  final String classification; // ملاكي، تجاري، حافلة، دراجة نارية
  final String make; // e.g. "Toyota", "Hyundai"
  final String model; // e.g. "Corolla", "Tucson"
  final int year; // e.g. 2022
  final String color; // e.g. "أبيض لؤلؤي"
  final String chassisNumber; // رقم شاسيه
  final String engineNumber; // رقم المحرك
  final String locality; // المحلية (نظام ولاية النيل الأبيض)
  final DateTime licenseExpiryDate; // تاريخ انتهاء الترخيص
  final bool isVerified; // ✅ موثق / 🚨 قيد المراجعة
  final bool isWanted; // مطلوبة أمنياً / حجز قضائي
  final bool isStolenReported; // بلاغ سرقة نشط
  final String? alertNotes; // ملاحظات التعميم الأمني
  final String? registrationCardImage; // صورة بطاقة الترخيص
  final String? driverLicenseImage; // صورة رخصة القيادة
  final DateTime createdAt;

  VehicleModel({
    required this.id,
    required this.userId,
    this.ownerName = 'محمد عبد الرحمن الشيخ',
    this.ownerNationalId = '11829471928',
    required this.plateNumber,
    required this.plateStateCode,
    this.plateCategoryCode = '5',
    required this.classification,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.chassisNumber,
    required this.engineNumber,
    required this.locality,
    required this.licenseExpiryDate,
    this.isVerified = true,
    this.isWanted = false,
    this.isStolenReported = false,
    this.alertNotes,
    this.registrationCardImage,
    this.driverLicenseImage,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get fullPlateDisplay => '$plateStateCode $plateCategoryCode - $plateNumber';

  bool get isLicenseExpired => licenseExpiryDate.isBefore(DateTime.now());

  int get daysUntilExpiry => licenseExpiryDate.difference(DateTime.now()).inDays;

  bool get hasSecurityAlert => isWanted || isStolenReported;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'ownerName': ownerName,
        'ownerNationalId': ownerNationalId,
        'plateNumber': plateNumber,
        'plateStateCode': plateStateCode,
        'plateCategoryCode': plateCategoryCode,
        'classification': classification,
        'make': make,
        'model': model,
        'year': year,
        'color': color,
        'chassisNumber': chassisNumber,
        'engineNumber': engineNumber,
        'locality': locality,
        'licenseExpiryDate': Timestamp.fromDate(licenseExpiryDate),
        'isVerified': isVerified,
        'isWanted': isWanted,
        'isStolenReported': isStolenReported,
        'alertNotes': alertNotes,
        'registrationCardImage': registrationCardImage,
        'driverLicenseImage': driverLicenseImage,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        ownerName: json['ownerName'] as String? ?? 'محمد عبد الرحمن الشيخ',
        ownerNationalId: json['ownerNationalId'] as String? ?? '11829471928',
        plateNumber: json['plateNumber'] as String,
        plateStateCode: json['plateStateCode'] as String? ?? 'خ',
        plateCategoryCode: json['plateCategoryCode'] as String? ?? '5',
        classification: json['classification'] as String? ?? 'ملاكي',
        make: json['make'] as String,
        model: json['model'] as String,
        year: json['year'] as int? ?? 2020,
        color: json['color'] as String? ?? 'أسود',
        chassisNumber: json['chassisNumber'] as String? ?? 'KMHSH81BPFU091823',
        engineNumber: json['engineNumber'] as String? ?? 'G4FD-71829',
        locality: json['locality'] as String? ?? 'كوستي',
        licenseExpiryDate: _parseDateTime(json['licenseExpiryDate']),
        isVerified: json['isVerified'] as bool? ?? true,
        isWanted: json['isWanted'] as bool? ?? false,
        isStolenReported: json['isStolenReported'] as bool? ?? false,
        alertNotes: json['alertNotes'] as String?,
        registrationCardImage: json['registrationCardImage'] as String?,
        driverLicenseImage: json['driverLicenseImage'] as String?,
        createdAt: _parseDateTime(json['createdAt']),
      );

  static DateTime _parseDateTime(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.parse(date);
    return DateTime.now();
  }

  VehicleModel copyWith({
    String? ownerName,
    String? ownerNationalId,
    String? plateNumber,
    String? plateStateCode,
    String? plateCategoryCode,
    String? classification,
    String? make,
    String? model,
    int? year,
    String? color,
    String? chassisNumber,
    String? engineNumber,
    String? locality,
    DateTime? licenseExpiryDate,
    bool? isVerified,
    bool? isWanted,
    bool? isStolenReported,
    String? alertNotes,
    String? registrationCardImage,
    String? driverLicenseImage,
  }) {
    return VehicleModel(
      id: id,
      userId: userId,
      ownerName: ownerName ?? this.ownerName,
      ownerNationalId: ownerNationalId ?? this.ownerNationalId,
      plateNumber: plateNumber ?? this.plateNumber,
      plateStateCode: plateStateCode ?? this.plateStateCode,
      plateCategoryCode: plateCategoryCode ?? this.plateCategoryCode,
      classification: classification ?? this.classification,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      chassisNumber: chassisNumber ?? this.chassisNumber,
      engineNumber: engineNumber ?? this.engineNumber,
      locality: locality ?? this.locality,
      licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,
      isVerified: isVerified ?? this.isVerified,
      isWanted: isWanted ?? this.isWanted,
      isStolenReported: isStolenReported ?? this.isStolenReported,
      alertNotes: alertNotes ?? this.alertNotes,
      registrationCardImage: registrationCardImage ?? this.registrationCardImage,
      driverLicenseImage: driverLicenseImage ?? this.driverLicenseImage,
      createdAt: createdAt,
    );
  }
}
