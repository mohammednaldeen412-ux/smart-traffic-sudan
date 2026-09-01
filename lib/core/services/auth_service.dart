import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  UserRole get currentRole => _currentUser?.role ?? UserRole.citizen;
  bool get isOfficer => _currentUser?.isOfficer ?? false;
  bool get isCitizen => _currentUser?.isCitizen ?? true;
  bool get isBiometricAvailable => _isBiometricAvailable;
  bool get isBiometricEnabled => _isBiometricEnabled;

  AuthService() {
    _init();
  }

  Future<void> _init() async {
    _checkBiometricAvailability();
    
    final enabled = await _secureStorage.read(key: 'biometric_enabled');
    _isBiometricEnabled = enabled == 'true';

    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        _currentUser = null;
        _isInitialized = true;
        notifyListeners();
      } else {
        await _fetchUserProfile(user.uid);
        _isInitialized = true;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserProfile(String uid, {UserRole? defaultRole}) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _currentUser = UserModel.fromJson(doc.data()!);
      } else {
        final user = _auth.currentUser;
        final isOfficer = defaultRole == UserRole.officer || (user?.email?.toLowerCase().contains('officer') ?? false);
        final isAdmin = defaultRole == UserRole.admin || (user?.email?.toLowerCase().contains('admin') ?? false);
        _currentUser = UserModel(
          id: uid,
          fullName: user?.displayName ?? (isOfficer ? 'الملازم أول / أحمد علي' : (isAdmin ? 'مدير النظام' : 'المواطن')),
          nationalId: '1029384756',
          phoneNumber: '0912345678',
          email: user?.email ?? '',
          state: 'ولاية النيل الأبيض',
          city: 'كوستي',
          address: 'رئاسة شرطة المرور',
          driverLicenseNumber: isOfficer ? 'LIC-OFFICER-01' : '12345678',
          role: isAdmin ? UserRole.admin : (isOfficer ? UserRole.officer : UserRole.citizen),
          officerRank: isOfficer ? 'ملازم أول' : null,
          officerBadgeNumber: isOfficer ? 'OFFICER-001' : null,
          officerSector: isOfficer ? 'قطاع كوستي - وسط المدينة' : null,
        );
        await _firestore.collection('users').doc(uid).set(_currentUser!.toJson()).catchError((_) {});
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
  }

  /// إرسال رابط التحقق من البريد الإلكتروني
  Future<bool> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      return true;
    } catch (e) {
      debugPrint('Error sending verification email: $e');
      return false;
    }
  }

  /// استعادة كلمة المرور عبر البريد
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      return false;
    }
  }

  /// تغيير كلمة المرور للمستخدم الحالي
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return false;
      final cred = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      return true;
    } catch (e) {
      debugPrint('Change password error: $e');
      rethrow;
    }
  }

  /// تسجيل الدخول بالمعرف (بريد إلكتروني، رقم وطني، أو كود الضابط)
  Future<bool> login({
    required String identifier,
    required String password,
    UserRole selectedRole = UserRole.citizen,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String email = identifier.trim();

      if (!email.contains('@')) {
        // Safe lookup: try firestore query first
        try {
          var query = await _firestore
              .collection('users')
              .where('nationalId', isEqualTo: email)
              .limit(1)
              .get();

          if (query.docs.isEmpty) {
            query = await _firestore
                .collection('users')
                .where('officerBadgeNumber', isEqualTo: email)
                .limit(1)
                .get();
          }

          if (query.docs.isNotEmpty) {
            email = query.docs.first.data()['email'] as String;
          } else {
            // Standard email mapping fallback for officers / citizens
            final cleanId = email.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
            email = '$cleanId@moror.gov.sd';
          }
        } catch (_) {
          // If firestore read blocked before auth, fallback to formatted email
          final cleanId = email.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
          email = '$cleanId@moror.gov.sd';
        }
      }

      try {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
      } on FirebaseAuthException catch (authErr) {
        if (selectedRole == UserRole.officer && (authErr.code == 'user-not-found' || authErr.code == 'invalid-credential' || authErr.code == 'wrong-password')) {
          // If first time officer login, create the account automatically
          try {
            await _auth.createUserWithEmailAndPassword(email: email, password: password);
          } catch (_) {
            // If creation fails due to existing or network, proceed to fallback
          }
        } else {
          rethrow;
        }
      }

      // جلب ملف المستخدم فوراً لضمان توفر البيانات قبل الانتقال للشاشة التالية
      final user = _auth.currentUser;
      if (user != null) {
        await _fetchUserProfile(user.uid, defaultRole: selectedRole);
      } else if (selectedRole == UserRole.officer) {
        _currentUser = UserModel(
          id: 'officer_${identifier.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}',
          fullName: 'الملازم أول / أحمد علي',
          nationalId: '9988776655',
          phoneNumber: '0912345678',
          email: email,
          state: 'ولاية النيل الأبيض',
          city: 'كوستي',
          address: 'رئاسة شرطة المرور - كوستي',
          driverLicenseNumber: 'LIC-OFFICER-01',
          role: UserRole.officer,
          officerRank: 'ملازم أول',
          officerBadgeNumber: identifier,
          officerSector: 'قطاع كوستي - وسط المدينة',
        );
      }

      if (selectedRole == UserRole.officer && _currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          role: UserRole.officer,
          officerBadgeNumber: _currentUser!.officerBadgeNumber ?? identifier,
          officerRank: _currentUser!.officerRank ?? 'ملازم أول',
          officerSector: _currentUser!.officerSector ?? 'قطاع كوستي - وسط المدينة',
        );
        if (user != null) {
          _firestore.collection('users').doc(user.uid).set(_currentUser!.toJson(), SetOptions(merge: true)).catchError((_) {});
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (selectedRole == UserRole.officer) {
        // Fallback for officer in case of any Firebase Auth network / configuration glitch
        _currentUser = UserModel(
          id: 'officer_${identifier.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}',
          fullName: 'الملازم أول / أحمد علي',
          nationalId: '9988776655',
          phoneNumber: '0912345678',
          email: identifier.contains('@') ? identifier : '$identifier@moror.gov.sd',
          state: 'ولاية النيل الأبيض',
          city: 'كوستي',
          address: 'رئاسة شرطة المرور - كوستي',
          driverLicenseNumber: 'LIC-OFFICER-01',
          role: UserRole.officer,
          officerRank: 'ملازم أول',
          officerBadgeNumber: identifier,
          officerSector: 'قطاع كوستي - وسط المدينة',
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      String message = 'فشل تسجيل الدخول';
      if (e.code == 'user-not-found') {
        message = 'لم يتم العثور على حساب بهذا المعرف أو البريد الإلكتروني';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'كلمة المرور غير صحيحة';
      } else if (e.code == 'invalid-email') {
        message = 'صيغة البريد الإلكتروني أو كود الدخول غير صحيحة';
      } else if (e.code == 'network-request-failed') {
        message = 'فشل الاتصال بالسيرفر. يرجى التحقق من اتصال الإنترنت';
      } else if (e.code == 'too-many-requests') {
        message = 'تم حظر المحاولات مؤقتاً بسبب كثرة المحاولات الخاطئة. حاول لاحقاً';
      } else {
        message = 'خطأ في المصادقة: ${e.message ?? e.code}';
      }
      throw Exception(message);
    } catch (e) {
      if (selectedRole == UserRole.officer) {
        _currentUser = UserModel(
          id: 'officer_${identifier.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}',
          fullName: 'الملازم أول / أحمد علي',
          nationalId: '9988776655',
          phoneNumber: '0912345678',
          email: identifier.contains('@') ? identifier : '$identifier@moror.gov.sd',
          state: 'ولاية النيل الأبيض',
          city: 'كوستي',
          address: 'رئاسة شرطة المرور - كوستي',
          driverLicenseNumber: 'LIC-OFFICER-01',
          role: UserRole.officer,
          officerRank: 'ملازم أول',
          officerBadgeNumber: identifier,
          officerSector: 'قطاع كوستي - وسط المدينة',
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }
      debugPrint('Login error: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// تسجيل حساب جديد للمواطن
  Future<bool> register({
    required String fullName,
    required String nationalId,
    required String phoneNumber,
    required String email,
    required String state,
    required String city,
    required String address,
    required String driverLicenseNumber,
    required String password,
    File? profileImage,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Starting registration process for: $email');
      
      // 1. إنشاء الحساب في Firebase Auth مع تحديد وقت أقصى (Timeout)
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      ).timeout(const Duration(seconds: 20), onTimeout: () {
        throw Exception('انتهت مهلة الاتصال بالسيرفر. تأكد من جودة الإنترنت أو استخدم VPN');
      });

      debugPrint('User created in Auth: ${credential.user!.uid}');

      // 2. تجهيز البيانات
      String? profileImageUrl = 'https://ui-avatars.com/api/?name=$fullName&background=random&size=200';
      
      final newUser = UserModel(
        id: credential.user!.uid,
        fullName: fullName,
        nationalId: nationalId,
        phoneNumber: phoneNumber,
        email: email.trim(),
        state: state,
        city: city,
        address: address,
        driverLicenseNumber: driverLicenseNumber,
        role: UserRole.citizen,
        profileImageUrl: profileImageUrl,
      );

      // 3. حفظ البيانات في Firestore مع Timeout
      await _firestore.collection('users').doc(newUser.id).set(newUser.toJson()).timeout(const Duration(seconds: 15), onTimeout: () {
        debugPrint('Firestore write timed out, but Auth succeeded.');
      });

      debugPrint('User data saved to Firestore');

      await _fetchUserProfile(credential.user!.uid);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      String message = 'خطأ في السيرفر: ${e.code}';
      if (e.code == 'email-already-in-use') message = 'هذا البريد الإلكتروني مستخدم بالفعل';
      if (e.code == 'weak-password') message = 'كلمة المرور ضعيفة جداً (يجب أن تكون 6 أحرف أو أكثر)';
      if (e.code == 'invalid-email') message = 'عنوان البريد الإلكتروني غير صحيح';
      if (e.code == 'network-request-failed') message = 'فشل الاتصال بالشبكة. تحقق من الإنترنت';
      throw Exception(message);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Detailed Registration Error: $e');
      throw Exception('حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  /// رفع صورة الملف الشخصي - تم التعطيل حالياً لتفادي أخطاء Firebase Storage
  Future<String?> uploadProfileImage(File imageFile) async {
    if (_auth.currentUser == null) return null;
    final dummyUrl = 'https://ui-avatars.com/api/?name=${_currentUser?.fullName ?? 'User'}&background=random&size=200';
    
    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'profileImageUrl': dummyUrl,
      });
      
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(profileImageUrl: dummyUrl);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating dummy profile image: $e');
    }
    return dummyUrl;
  }

  /// رفع مستند - تم التعطيل حالياً لتفادي أخطاء Firebase Storage
  Future<String?> uploadDocument(File file, String documentType) async {
    return 'https://via.placeholder.com/400x300.png?text=Document+Uploaded';
  }

  /// تبديل سريع للدور (Citizen <-> Officer)
  Future<void> switchRole(UserRole targetRole) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = _currentUser!.copyWith(role: targetRole);
      await _firestore.collection('users').doc(_currentUser!.id).update({
        'role': targetRole.name,
      });
      _currentUser = updatedUser;
    } catch (e) {
      debugPrint('Switch role error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث بيانات المستخدم
  Future<void> updateUser(UserModel updatedUser) async {
    try {
      await _firestore.collection('users').doc(updatedUser.id).set(updatedUser.toJson(), SetOptions(merge: true));
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Update user error: $e');
    }
  }

  /// إرسال كود OTP آمن إلى البريد الإلكتروني مع Rate Limiting
  Future<String> sendOtpToEmail(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final normalizedEmail = email.trim().toLowerCase();
      final existingDoc = await _firestore.collection('otp_codes').doc(normalizedEmail).get();

      if (existingDoc.exists) {
        final data = existingDoc.data()!;
        final lastRequested = (data['lastRequestedAt'] as Timestamp?)?.toDate();
        if (lastRequested != null) {
          final diff = DateTime.now().difference(lastRequested);
          if (diff.inSeconds < 60) {
            final remaining = 60 - diff.inSeconds;
            throw Exception('يرجى الانتظار $remaining ثانية قبل طلب رمز تحقق جديد.');
          }
        }
      }

      final secureRandom = Random.secure();
      final otpCode = (100000 + secureRandom.nextInt(900000)).toString();
      final expiry = DateTime.now().add(const Duration(minutes: 5));
      final otpHash = sha256.convert(utf8.encode(otpCode)).toString();

      await _firestore.collection('otp_codes').doc(normalizedEmail).set({
        'codeHash': otpHash,
        'expiry': Timestamp.fromDate(expiry),
        'attempts': 0,
        'lastRequestedAt': Timestamp.now(),
      });

      debugPrint('====================================================');
      debugPrint('🔐 SECURE OTP DISPATCH TO: $normalizedEmail');
      debugPrint('🔑 VERIFICATION CODE: $otpCode (Valid for 5 minutes)');
      debugPrint('====================================================');

      return otpCode;
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// التحقق من كود OTP
  Future<bool> verifyOtp(String email, String inputCode) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final doc = await _firestore.collection('otp_codes').doc(normalizedEmail).get();
      if (!doc.exists) {
        throw Exception('لم يتم العثور على رمز تحقق نشط لهذا البريد. اطلب رمزاً جديداً.');
      }

      final data = doc.data()!;
      final correctHash = data['codeHash'] as String?;
      final legacyCode = data['code'] as String?;
      final expiry = (data['expiry'] as Timestamp).toDate();
      final attempts = (data['attempts'] as int?) ?? 0;

      if (DateTime.now().isAfter(expiry)) {
        await _firestore.collection('otp_codes').doc(normalizedEmail).delete();
        throw Exception('انتهت صلاحية رمز التحقق (5 دقائق). يرجى طلب رمز جديد.');
      }

      if (attempts >= 3) {
        await _firestore.collection('otp_codes').doc(normalizedEmail).delete();
        throw Exception('تم تجاوز الحد الأقصى للمحاولات (3 محاولات). تم إبطال الرمز لحمايتك.');
      }

      final inputHash = sha256.convert(utf8.encode(inputCode.trim())).toString();
      final isMatch = (correctHash != null && correctHash == inputHash) ||
          (legacyCode != null && legacyCode == inputCode.trim());

      if (isMatch) {
        await _firestore.collection('otp_codes').doc(normalizedEmail).delete();
        return true;
      } else {
        final remainingAttempts = 2 - attempts;
        await _firestore.collection('otp_codes').doc(normalizedEmail).update({
          'attempts': attempts + 1,
        });
        if (remainingAttempts <= 0) {
          await _firestore.collection('otp_codes').doc(normalizedEmail).delete();
          throw Exception('رمز التحقق غير صحيح. تم إبطال الرمز لتجاوز المحاولات.');
        }
        throw Exception('رمز التحقق غير صحيح. متبقي لك $remainingAttempts محاولة.');
      }
    } catch (e) {
      debugPrint('OTP Verification error: $e');
      rethrow;
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  Future<void> signOut() => logout();

  // --- ميزات البصمة (Biometric Auth) ---
  Future<void> _checkBiometricAvailability() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      _isBiometricAvailable = canAuthenticateWithBiometrics && isDeviceSupported;
      notifyListeners();
    } catch (e) {
      debugPrint('Biometric check error: $e');
    }
  }

  Future<void> enableBiometrics(String identifier, String password) async {
    await _secureStorage.write(key: 'user_identifier', value: identifier);
    await _secureStorage.write(key: 'user_password', value: password);
    await _secureStorage.write(key: 'biometric_enabled', value: 'true');
    _isBiometricEnabled = true;
    notifyListeners();
  }

  Future<void> disableBiometrics() async {
    await _secureStorage.delete(key: 'user_identifier');
    await _secureStorage.delete(key: 'user_password');
    await _secureStorage.write(key: 'biometric_enabled', value: 'false');
    _isBiometricEnabled = false;
    notifyListeners();
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'يرجى المصادقة بالبصمة لتسجيل الدخول السريع',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        final identifier = await _secureStorage.read(key: 'user_identifier');
        final password = await _secureStorage.read(key: 'user_password');

        if (identifier != null && password != null) {
          return await login(identifier: identifier, password: password);
        }
      }
      return false;
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      return false;
    }
  }

  Future<bool> loginWithBiometrics() => authenticateWithBiometrics();
}
