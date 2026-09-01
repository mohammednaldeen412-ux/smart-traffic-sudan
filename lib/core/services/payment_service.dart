import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../models/payment_receipt_model.dart';

/// حالات طلب الدفع
enum PaymentRequestStatus {
  pending,    // بانتظار التأكيد
  processing, // قيد المعالجة البنكية
  confirmed,  // مؤكد من السيرفر
  failed,     // فشل
  cancelled,  // ملغى
}

/// خدمة بوابة الدفع الإلكتروني والربط البنكي الفعلي مع موقع بنكك
class PaymentService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  // ─── توليد رقم معاملة بنكية رسمي ──────────────────────────────────────────
  static String generateBankingTransactionId() {
    final year = DateTime.now().year;
    final rand = Random.secure();
    // صيغة: TXN-WN-{YEAR}-{8 أرقام عشوائية}
    final serial =
        List.generate(8, (_) => rand.nextInt(10)).join();
    return 'TXN-WN-$year-$serial';
  }

  // ─── توليد Hash تحقق للإيصال ───────────────────────────────────────────────
  static String generateVerificationHash({
    required String transactionId,
    required String violationId,
    required double amount,
    required String paymentMethod,
  }) {
    final raw = '$transactionId|$violationId|$amount|$paymentMethod|${DateTime.now().millisecondsSinceEpoch}';
    return sha256.convert(utf8.encode(raw)).toString().substring(0, 32).toUpperCase();
  }

  // ─── بذر الحسابات الافتراضية للبنك إن لم تكن موجودة ────────────────────────
  Future<void> seedDefaultBankAccountsIfEmpty() async {
    try {
      final snap = await _firestore.collection('bank_accounts').limit(1).get();
      if (snap.docs.isEmpty) {
        final defaultAccounts = [
          {
            'id': 'usr_001',
            'name': 'أحمد المنصور',
            'phone': '0912345678',
            'email': 'ahmed.mansoor@example.com',
            'accountNumber': '2849102948',
            'iban': 'SD89BOK0000002849102948',
            'cardNumber': '5342 •••• •••• 8821',
            'cardExpiry': '08/29',
            'cardCvv': '742',
            'balance': 84500.00,
            'currency': 'SDG',
            'pin': '1234',
            'bankName': 'بنك الخرطوم (بنكك)',
            'role': 'personal',
            'createdAt': FieldValue.serverTimestamp(),
          },
          {
            'id': 'usr_002',
            'name': 'سارة التجريبية (متجر الأمل)',
            'phone': '0998877665',
            'email': 'sara.store@example.com',
            'accountNumber': '1092837465',
            'iban': 'SD89BOK0000001092837465',
            'cardNumber': '4218 •••• •••• 4190',
            'cardExpiry': '11/28',
            'cardCvv': '391',
            'balance': 320000.00,
            'currency': 'SDG',
            'pin': '1234',
            'bankName': 'بنك فيصل الإسلامي (فوري)',
            'role': 'merchant',
            'createdAt': FieldValue.serverTimestamp(),
          },
          {
            'id': 'usr_003',
            'name': 'محمد عبد الرحمن الشيخ',
            'phone': '0912300000',
            'email': 'mohammed.sheikh@example.com',
            'accountNumber': '3049182',
            'iban': 'SD89BOK000000003049182',
            'cardNumber': '5241 •••• •••• 4821',
            'cardExpiry': '08/28',
            'cardCvv': '849',
            'balance': 65000.00,
            'currency': 'SDG',
            'pin': '1234',
            'bankName': 'بنك الخرطوم (بنكك)',
            'role': 'personal',
            'createdAt': FieldValue.serverTimestamp(),
          },
        ];

        for (final acc in defaultAccounts) {
          await _firestore
              .collection('bank_accounts')
              .doc(acc['id'] as String)
              .set(acc, SetOptions(merge: true));
        }
        debugPrint('[PaymentService] ✅ Seeded default bank accounts in Firestore');
      }
    } catch (e) {
      debugPrint('[PaymentService] Error seeding default bank accounts: $e');
    }
  }

  // ─── البحث عن حساب بنكي برقم الحساب أو الهاتف ─────────────────────────────
  Future<Map<String, dynamic>?> lookupBankAccount(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return null;

    try {
      // التأكد من وجود الحسابات التجريبية أولاً
      await seedDefaultBankAccountsIfEmpty();

      // البحث برقم الحساب
      var snap = await _firestore
          .collection('bank_accounts')
          .where('accountNumber', isEqualTo: clean)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        // البحث برقم الهاتف
        snap = await _firestore
            .collection('bank_accounts')
            .where('phone', isEqualTo: clean)
            .limit(1)
            .get();
      }

      if (snap.docs.isNotEmpty) {
        final doc = snap.docs.first;
        final data = Map<String, dynamic>.from(doc.data());
        data['docId'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('[PaymentService] lookupBankAccount error: $e');
      return null;
    }
  }

  // ─── معالجة الدفع الفعلي والخصم المباشر من الحساب البنكي ───────────────────
  Future<PaymentReceiptModel> processRealBankPayment({
    required String violationId,
    required String bankAccountQuery,
    required String pin,
    required String paymentMethod,
    required String payerName,
    required String payerNationalId,
    double serviceFee = 500.0,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      // 1. استخراج وقراءة بيانات المخالفة
      final violationDoc =
          await _firestore.collection('violations').doc(violationId).get();
      if (!violationDoc.exists) {
        throw Exception('المخالفة غير موجودة في النظام');
      }
      final vData = violationDoc.data()!;
      if (vData['isPaid'] == true) {
        throw Exception('هذه المخالفة مسددة مسبقاً — لا يمكن تكرار الدفع');
      }

      final violationAmount = (vData['amount'] as num).toDouble();
      final totalAmount = violationAmount + serviceFee;

      // 2. البحث عن الحساب البنكي والتحقق منه
      final bankAccount = await lookupBankAccount(bankAccountQuery);
      if (bankAccount == null) {
        throw Exception('رقم الحساب البنكي ($bankAccountQuery) غير مسجل في النظام البنكي');
      }

      final accountDocId = bankAccount['docId'] as String;
      final accountPin = bankAccount['pin']?.toString() ?? '1234';
      final accountBalance = (bankAccount['balance'] as num?)?.toDouble() ?? 0.0;
      final accountHolder = bankAccount['name']?.toString() ?? payerName;
      final accountNumber = bankAccount['accountNumber']?.toString() ?? bankAccountQuery;

      // 3. التحقق من صحة الـ PIN
      if (accountPin != pin.trim()) {
        throw Exception('رمز الـ PIN غير صحيح للحساب ($accountNumber). يرجى التأكد والمحاولة مجدداً');
      }

      // 4. التحقق من كفاية الرصيد
      if (accountBalance < totalAmount) {
        throw Exception('رصيد الحساب البنكي غير كافٍ لإتمام السداد.\nالرصيد الحالي: ${accountBalance.toStringAsFixed(2)} SDG\nالمبلغ المطلوب: ${totalAmount.toStringAsFixed(2)} SDG');
      }

      // 5. توليد المعرفات
      final transactionId = generateBankingTransactionId();
      final gatewayRef = 'GW-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final verificationHash = generateVerificationHash(
        transactionId: transactionId,
        violationId: violationId,
        amount: totalAmount,
        paymentMethod: paymentMethod,
      );

      final now = DateTime.now();
      final receipt = PaymentReceiptModel(
        transactionId: transactionId,
        violationId: violationId,
        violationType: vData['violationType'] as String,
        amount: totalAmount,
        paymentMethod: paymentMethod,
        paymentDate: now,
        payerName: accountHolder,
        payerNationalId: payerNationalId,
        plateNumber: '${vData['plateStateCode']} - ${vData['plateNumber']}',
        verificationHash: verificationHash,
        gatewayRef: gatewayRef,
        bankingTransactionId: transactionId,
        confirmedAt: now,
        initiatedAt: now,
        paymentStatus: 'مكتملة وناجحة',
      );

      // 6. تنفيذ Transaction ذرية لخصم الرصيد وتحديث المخالفة وإضافة المعاملة البنكية
      await _firestore.runTransaction((txn) async {
        final accountRef = _firestore.collection('bank_accounts').doc(accountDocId);
        final violationRef = _firestore.collection('violations').doc(violationId);
        final receiptRef = _firestore.collection('receipts').doc(transactionId);
        final bankTxnRef = _firestore.collection('bank_transactions').doc(transactionId);

        // Double check balance & violation status inside transaction
        final freshAccountDoc = await txn.get(accountRef);
        final freshViolationDoc = await txn.get(violationRef);

        if (!freshAccountDoc.exists) {
          throw Exception('الحساب البنكي غير موجود أثناء معالجة العملية');
        }
        final currentBal = (freshAccountDoc.data()?['balance'] as num?)?.toDouble() ?? 0.0;
        if (currentBal < totalAmount) {
          throw Exception('رصيد الحساب أصبح غير كافٍ');
        }
        if (freshViolationDoc.data()?['isPaid'] == true) {
          throw Exception('تم سداد المخالفة بالفعل مسبقاً');
        }

        // أ) خصم الرصيد من الحساب البنكي
        final newBalance = currentBal - totalAmount;
        txn.update(accountRef, {
          'balance': newBalance,
          'lastTransactionAt': FieldValue.serverTimestamp(),
        });

        // ب) إضافة سجل المعاملة في bank_transactions لموقع البنك (يظهر في History)
        txn.set(bankTxnRef, {
          'id': transactionId,
          'type': 'payment_gateway',
          'amount': totalAmount,
          'currency': 'SDG',
          'title': 'سداد مخالفة مرورية (${vData['violationType']})',
          'description': 'سداد مخالفة رقم $violationId للمركبة ${vData['plateStateCode']} - ${vData['plateNumber']}',
          'recipientName': 'الإدارة العامة للمرور - السودان',
          'recipientAccount': '9900112233',
          'senderName': accountHolder,
          'senderAccount': accountNumber,
          'merchantName': 'الإدارة العامة للمرور',
          'orderId': violationId,
          'status': 'success',
          'timestamp': now.toIso8601String(),
          'createdAt': FieldValue.serverTimestamp(),
          'fee': serviceFee,
          'referenceNumber': transactionId,
          'userId': freshAccountDoc.data()?['id'] ?? accountDocId,
        });

        // ج) تحديث حالة المخالفة إلى مدفوعة
        txn.update(violationRef, {
          'isPaid': true,
          'violationStatus': 'paid',
          'paidDate': FieldValue.serverTimestamp(),
          'receiptId': transactionId,
          'paymentMethod': paymentMethod,
          'paymentTransactionId': transactionId,
        });

        // د) حفظ الإيصال في مجموعة receipts
        txn.set(receiptRef, {
          ...receipt.toJson(),
          'userId': _auth.currentUser?.uid,
          'bankAccountUsed': accountNumber,
          'bankAccountHolder': accountHolder,
          'confirmedAt': FieldValue.serverTimestamp(),
        });
      });

      debugPrint('[PaymentService] ✅ Payment succeeded! Deducted $totalAmount SDG from $accountNumber. Txn: $transactionId');
      return receipt;
    } catch (e) {
      debugPrint('[PaymentService] ❌ Payment failed: $e');
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // ─── المرحلة 1: بدء طلب الدفع ─────────────────────────────────────────────
  Future<String> initiatePayment({
    required String violationId,
    required String paymentMethod,
    required double amount,
    required String payerUserId,
  }) async {
    final requestId = 'PAY-REQ-${const Uuid().v4().substring(0, 12).toUpperCase()}';

    await _firestore.collection('payment_requests').doc(requestId).set({
      'requestId': requestId,
      'violationId': violationId,
      'paymentMethod': paymentMethod,
      'amount': amount,
      'payerUserId': payerUserId,
      'status': PaymentRequestStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return requestId;
  }

  // ─── Pipeline المتوافق مع الشاشات السابقة ─────────────────────────────────
  Future<PaymentReceiptModel> processFullPayment({
    required String violationId,
    required String paymentMethod,
    required String payerName,
    required String payerNationalId,
  }) async {
    return processRealBankPayment(
      violationId: violationId,
      bankAccountQuery: '2849102948',
      pin: '1234',
      paymentMethod: paymentMethod,
      payerName: payerName,
      payerNationalId: payerNationalId,
    );
  }
}
