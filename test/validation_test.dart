import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_traffic_sudan/core/constants/sudan_locations.dart';

// ─── مساعد: محاكاة منطق OTP دون Firebase ─────────────────────────────────────
// نستخرج المنطق الخالص ليُختبر بشكل مستقل
class OtpValidator {
  static String hashOtp(String code) =>
      sha256.convert(utf8.encode(code.trim())).toString();

  static bool isExpired(DateTime expiry) => DateTime.now().isAfter(expiry);

  static bool isAttemptsExceeded(int attempts, {int maxAttempts = 3}) =>
      attempts >= maxAttempts;

  static bool isMatch(String inputCode, String storedHash) =>
      hashOtp(inputCode) == storedHash;

  static bool isRateLimited(DateTime? lastSentAt, {int cooldownSeconds = 60}) {
    if (lastSentAt == null) return false;
    return DateTime.now().difference(lastSentAt).inSeconds < cooldownSeconds;
  }
}

// ─── مساعد: محاكاة منطق Anti-Duplicate Violations ────────────────────────────
class ViolationDuplicateChecker {
  /// تحقق مما إذا كانت المخالفة مكررة ضمن نافذة زمنية معينة
  static bool isDuplicate({
    required String plateNumber,
    required String violationType,
    required List<Map<String, dynamic>> existingViolations,
    int windowMinutes = 60,
  }) {
    final cutoff = DateTime.now().subtract(Duration(minutes: windowMinutes));
    return existingViolations.any((v) {
      final issuedAt = v['issuedAt'] as DateTime;
      return v['plateNumber'] == plateNumber &&
          v['violationType'] == violationType &&
          issuedAt.isAfter(cutoff);
    });
  }
}

// ─── مساعد: محاكاة فحص فرادة المركبة ─────────────────────────────────────────
class VehicleUniquenessChecker {
  static bool isPlateUnique(
      String plate, List<Map<String, dynamic>> existingVehicles) {
    return !existingVehicles.any((v) => v['plateNumber'] == plate);
  }

  static bool isChassisUnique(
      String chassis, List<Map<String, dynamic>> existingVehicles) {
    return !existingVehicles.any((v) => v['chassisNumber'] == chassis);
  }

  static bool isEngineUnique(
      String engine, List<Map<String, dynamic>> existingVehicles) {
    return !existingVehicles.any((v) => v['engineNumber'] == engine);
  }
}

void main() {
  // ═══════════════════════════════════════════════════════════
  // GROUP 1: اختبارات نظام OTP الآمن
  // ═══════════════════════════════════════════════════════════
  group('🔐 OTP Validation Logic', () {
    test('SHA-256 hash of same code produces same result (deterministic)', () {
      const code = '482913';
      final hash1 = OtpValidator.hashOtp(code);
      final hash2 = OtpValidator.hashOtp(code);
      expect(hash1, equals(hash2));
      expect(hash1.length, equals(64)); // SHA-256 hex is 64 chars
    });

    test('Different OTP codes produce different hashes (no collision)', () {
      final hash1 = OtpValidator.hashOtp('123456');
      final hash2 = OtpValidator.hashOtp('654321');
      expect(hash1, isNot(equals(hash2)));
    });

    test('OTP hash does not store plain text', () {
      const code = '999888';
      final hash = OtpValidator.hashOtp(code);
      expect(hash, isNot(equals(code)));
      expect(hash.contains(code), isFalse);
    });

    test('OTP match returns true for correct input', () {
      const code = '741852';
      final stored = OtpValidator.hashOtp(code);
      expect(OtpValidator.isMatch(code, stored), isTrue);
    });

    test('OTP match returns false for wrong input', () {
      const correctCode = '741852';
      const wrongCode = '111111';
      final stored = OtpValidator.hashOtp(correctCode);
      expect(OtpValidator.isMatch(wrongCode, stored), isFalse);
    });

    test('OTP is expired when expiry is in the past', () {
      final pastExpiry = DateTime.now().subtract(const Duration(seconds: 1));
      expect(OtpValidator.isExpired(pastExpiry), isTrue);
    });

    test('OTP is valid when expiry is in the future', () {
      final futureExpiry = DateTime.now().add(const Duration(minutes: 5));
      expect(OtpValidator.isExpired(futureExpiry), isFalse);
    });

    test('Brute-force protection: 3 or more attempts triggers lockout', () {
      expect(OtpValidator.isAttemptsExceeded(3), isTrue);
      expect(OtpValidator.isAttemptsExceeded(5), isTrue);
    });

    test('Brute-force protection: fewer than 3 attempts is allowed', () {
      expect(OtpValidator.isAttemptsExceeded(0), isFalse);
      expect(OtpValidator.isAttemptsExceeded(2), isFalse);
    });

    test('Rate limiting: blocks resend within 60 seconds', () {
      final justNow = DateTime.now().subtract(const Duration(seconds: 30));
      expect(OtpValidator.isRateLimited(justNow), isTrue);
    });

    test('Rate limiting: allows resend after 60 seconds', () {
      final longAgo = DateTime.now().subtract(const Duration(seconds: 61));
      expect(OtpValidator.isRateLimited(longAgo), isFalse);
    });

    test('Rate limiting: allows first send (no previous timestamp)', () {
      expect(OtpValidator.isRateLimited(null), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 2: اختبارات بيانات المواقع السودانية
  // ═══════════════════════════════════════════════════════════
  group('🗺️ Sudan Locations Data', () {
    test('allStates contains exactly 18 Sudanese states', () {
      expect(SudanLocations.allStates.length, equals(18));
    });

    test('Each state has code, name, and symbol keys', () {
      for (final state in SudanLocations.allStates) {
        expect(state.containsKey('code'), isTrue,
            reason: 'Missing code for state: ${state['name']}');
        expect(state.containsKey('name'), isTrue,
            reason: 'Missing name for state: ${state['code']}');
        expect(state.containsKey('symbol'), isTrue,
            reason: 'Missing symbol for state: ${state['name']}');
      }
    });

    test('whiteNileLocalities contains exactly 8 official localities', () {
      expect(SudanLocations.whiteNileLocalities.length, equals(8));
    });

    test('whiteNileLocalities includes all 8 official White Nile localities', () {
      const expected = ['ربك', 'كوستي', 'الدويم', 'القطينة', 'تندلتي', 'أم رمتة', 'السلام', 'الجبلين'];
      for (final city in expected) {
        final found = SudanLocations.whiteNileLocalities
            .any((loc) => loc.contains(city));
        expect(found, isTrue, reason: 'Locality "$city" not found in whiteNileLocalities');
      }
    });

    test('isValidWhiteNileLocality returns true for valid locality', () {
      expect(SudanLocations.isValidWhiteNileLocality('كوستي'), isTrue);
      expect(SudanLocations.isValidWhiteNileLocality('ربك'), isTrue);
      expect(SudanLocations.isValidWhiteNileLocality('الجبلين'), isTrue);
    });

    test('isValidWhiteNileLocality returns false for non-White Nile locality', () {
      expect(SudanLocations.isValidWhiteNileLocality('بحري'), isFalse);
      expect(SudanLocations.isValidWhiteNileLocality('مدني'), isFalse);
      expect(SudanLocations.isValidWhiteNileLocality('بورتسودان'), isFalse);
    });

    test('No duplicate state codes in allStates', () {
      final codes = SudanLocations.allStates.map((s) => s['code']).toList();
      final uniqueCodes = codes.toSet();
      expect(codes.length, equals(uniqueCodes.length),
          reason: 'Found duplicate state codes!');
    });

    test('White Nile state is present in allStates', () {
      final hasWhiteNile = SudanLocations.allStates
          .any((s) => s['name'] == 'النيل الأبيض');
      expect(hasWhiteNile, isTrue);
    });

    test('operationalState is set to White Nile', () {
      expect(SudanLocations.operationalState, equals('النيل الأبيض'));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 3: اختبارات فرادة المركبات
  // ═══════════════════════════════════════════════════════════
  group('🚗 Vehicle Uniqueness Validation', () {
    final existingVehicles = [
      {
        'plateNumber': '48291',
        'chassisNumber': 'CH-XYZ-2024',
        'engineNumber': 'ENG-ABC-001',
      },
      {
        'plateNumber': '73921',
        'chassisNumber': 'CH-DEF-2023',
        'engineNumber': 'ENG-DEF-002',
      },
    ];

    test('New plate number is accepted (unique)', () {
      expect(
        VehicleUniquenessChecker.isPlateUnique('99999', existingVehicles),
        isTrue,
      );
    });

    test('Duplicate plate number is rejected', () {
      expect(
        VehicleUniquenessChecker.isPlateUnique('48291', existingVehicles),
        isFalse,
      );
    });

    test('New chassis number is accepted (unique)', () {
      expect(
        VehicleUniquenessChecker.isChassisUnique('CH-NEW-2024', existingVehicles),
        isTrue,
      );
    });

    test('Duplicate chassis number is rejected', () {
      expect(
        VehicleUniquenessChecker.isChassisUnique('CH-XYZ-2024', existingVehicles),
        isFalse,
      );
    });

    test('New engine number is accepted (unique)', () {
      expect(
        VehicleUniquenessChecker.isEngineUnique('ENG-NEW-999', existingVehicles),
        isTrue,
      );
    });

    test('Duplicate engine number is rejected', () {
      expect(
        VehicleUniquenessChecker.isEngineUnique('ENG-ABC-001', existingVehicles),
        isFalse,
      );
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 4: اختبارات مكافحة تكرار المخالفات
  // ═══════════════════════════════════════════════════════════
  group('🚫 Anti-Duplicate Violation Enforcement', () {
    test('Same plate + same violation within 60min is a duplicate', () {
      final violations = [
        {
          'plateNumber': '48291',
          'violationType': 'قطع الإشارة الضوئية الحمراء',
          'issuedAt': DateTime.now().subtract(const Duration(minutes: 30)),
        },
      ];

      expect(
        ViolationDuplicateChecker.isDuplicate(
          plateNumber: '48291',
          violationType: 'قطع الإشارة الضوئية الحمراء',
          existingViolations: violations,
        ),
        isTrue,
      );
    });

    test('Same plate + different violation type within 60min is NOT a duplicate', () {
      final violations = [
        {
          'plateNumber': '48291',
          'violationType': 'قطع الإشارة الضوئية الحمراء',
          'issuedAt': DateTime.now().subtract(const Duration(minutes: 20)),
        },
      ];

      expect(
        ViolationDuplicateChecker.isDuplicate(
          plateNumber: '48291',
          violationType: 'تجاوز السرعة القانونية المقررة (رادار)',
          existingViolations: violations,
        ),
        isFalse,
      );
    });

    test('Same violation type but different plate is NOT a duplicate', () {
      final violations = [
        {
          'plateNumber': '48291',
          'violationType': 'قطع الإشارة الضوئية الحمراء',
          'issuedAt': DateTime.now().subtract(const Duration(minutes: 10)),
        },
      ];

      expect(
        ViolationDuplicateChecker.isDuplicate(
          plateNumber: '99999',
          violationType: 'قطع الإشارة الضوئية الحمراء',
          existingViolations: violations,
        ),
        isFalse,
      );
    });

    test('Same plate + same violation type outside 60min window is allowed', () {
      final violations = [
        {
          'plateNumber': '48291',
          'violationType': 'قطع الإشارة الضوئية الحمراء',
          'issuedAt': DateTime.now().subtract(const Duration(minutes: 90)),
        },
      ];

      expect(
        ViolationDuplicateChecker.isDuplicate(
          plateNumber: '48291',
          violationType: 'قطع الإشارة الضوئية الحمراء',
          existingViolations: violations,
        ),
        isFalse,
      );
    });

    test('Empty violations list always returns no duplicate', () {
      expect(
        ViolationDuplicateChecker.isDuplicate(
          plateNumber: '48291',
          violationType: 'قطع الإشارة الضوئية الحمراء',
          existingViolations: [],
        ),
        isFalse,
      );
    });

    test('Exactly at the 60-minute boundary is NOT a duplicate (strict gt)', () {
      final violations = [
        {
          'plateNumber': '48291',
          'violationType': 'تظليل زجاج المركبة بدون تصريح أمني',
          'issuedAt': DateTime.now().subtract(const Duration(minutes: 60, seconds: 1)),
        },
      ];

      expect(
        ViolationDuplicateChecker.isDuplicate(
          plateNumber: '48291',
          violationType: 'تظليل زجاج المركبة بدون تصريح أمني',
          existingViolations: violations,
        ),
        isFalse,
      );
    });
  });
}
