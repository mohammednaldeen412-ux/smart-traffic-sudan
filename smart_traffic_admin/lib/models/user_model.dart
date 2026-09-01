import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  citizen,
  officer,
  admin,
}

class UserModel {
  final String id;
  final String fullName;
  final String nationalId; // الرقم الوطني (11 رقم)
  final String phoneNumber;
  final String email;
  final bool isEmailVerified;
  final String state; // الولاية
  final String city; // المدينة
  final String address; // العنوان
  final String driverLicenseNumber; // رقم رخصة القيادة
  final String? profileImageUrl;
  final String? nationalIdImage; // صورة الرقم الوطني
  final String? licenseImage; // صورة الرخصة
  final UserRole role;
  
  // بيانات خاصة بالضابط ورجال المرور الميداني
  final String? officerRank; // الرتبة: ملازم أول، نقيب، رائد...
  final String? officerBadgeNumber; // الرقم العسكري / كود الضابط
  final String? officerSector; // قطاع / شعبة المرور
  
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.nationalId,
    required this.phoneNumber,
    required this.email,
    this.isEmailVerified = false,
    required this.state,
    required this.city,
    required this.address,
    required this.driverLicenseNumber,
    this.profileImageUrl,
    this.nationalIdImage,
    this.licenseImage,
    this.role = UserRole.citizen,
    this.officerRank,
    this.officerBadgeNumber,
    this.officerSector,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOfficer => role == UserRole.officer;
  bool get isCitizen => role == UserRole.citizen;
  bool get isAdmin => role == UserRole.admin;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'nationalId': nationalId,
        'phoneNumber': phoneNumber,
        'email': email,
        'isEmailVerified': isEmailVerified,
        'state': state,
        'city': city,
        'address': address,
        'driverLicenseNumber': driverLicenseNumber,
        'profileImageUrl': profileImageUrl,
        'nationalIdImage': nationalIdImage,
        'licenseImage': licenseImage,
        'role': role.name,
        'officerRank': officerRank,
        'officerBadgeNumber': officerBadgeNumber,
        'officerSector': officerSector,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        nationalId: json['nationalId'] as String,
        phoneNumber: json['phoneNumber'] as String,
        email: json['email'] as String,
        isEmailVerified: json['isEmailVerified'] as bool? ?? false,
        state: json['state'] as String? ?? 'الخرطوم',
        city: json['city'] as String? ?? 'الخرطوم',
        address: json['address'] as String? ?? '',
        driverLicenseNumber: json['driverLicenseNumber'] as String? ?? '',
        profileImageUrl: json['profileImageUrl'] as String?,
        nationalIdImage: json['nationalIdImage'] as String?,
        licenseImage: json['licenseImage'] as String?,
        role: _parseRole(json['role']),
        officerRank: json['officerRank'] as String?,
        officerBadgeNumber: json['officerBadgeNumber'] as String?,
        officerSector: json['officerSector'] as String?,
        createdAt: _parseDateTime(json['createdAt']),
      );

  static UserRole _parseRole(dynamic role) {
    if (role == 'admin') return UserRole.admin;
    if (role == 'officer') return UserRole.officer;
    return UserRole.citizen;
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.parse(date);
    return DateTime.now();
  }

  UserModel copyWith({
    String? fullName,
    String? nationalId,
    String? phoneNumber,
    String? email,
    bool? isEmailVerified,
    String? state,
    String? city,
    String? address,
    String? driverLicenseNumber,
    String? profileImageUrl,
    String? nationalIdImage,
    String? licenseImage,
    UserRole? role,
    String? officerRank,
    String? officerBadgeNumber,
    String? officerSector,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      nationalId: nationalId ?? this.nationalId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      state: state ?? this.state,
      city: city ?? this.city,
      address: address ?? this.address,
      driverLicenseNumber: driverLicenseNumber ?? this.driverLicenseNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      nationalIdImage: nationalIdImage ?? this.nationalIdImage,
      licenseImage: licenseImage ?? this.licenseImage,
      role: role ?? this.role,
      officerRank: officerRank ?? this.officerRank,
      officerBadgeNumber: officerBadgeNumber ?? this.officerBadgeNumber,
      officerSector: officerSector ?? this.officerSector,
      createdAt: createdAt,
    );
  }
}
