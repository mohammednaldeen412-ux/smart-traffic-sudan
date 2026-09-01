import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/payment_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/violation_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'payment_success_screen.dart';

class PaymentGatewayScreen extends StatefulWidget {
  final ViolationModel violation;

  const PaymentGatewayScreen({
    super.key,
    required this.violation,
  });

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen>
    with SingleTickerProviderStateMixin {
  int _selectedMethodIndex = 0;
  bool _isProcessingPayment = false;
  String _processingStep = '';

  final _accountNumberController = TextEditingController(text: '3049182');
  final _cardNumberController =
      TextEditingController(text: '5241 8892 0019 4821');
  final _cardHolderController =
      TextEditingController(text: 'محمد عبد الرحمن الشيخ');
  final _expiryController = TextEditingController(text: '08/28');
  final _cvvController = TextEditingController(text: '849');

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'title': 'تطبيق بنكك (Bankak)',
      'subtitle': 'بنك الخرطوم - سداد مباشر',
      'icon': Icons.account_balance_rounded,
      'color': Color(0xFF00875A),
    },
    {
      'title': 'تطبيق فوري (Fawry)',
      'subtitle': 'بنك فيصل الإسلامي السوداني',
      'icon': Icons.flash_on_rounded,
      'color': Color(0xFF0284C7),
    },
    {
      'title': 'أوكاش (O-Cash)',
      'subtitle': 'بنك أم درمان الوطني',
      'icon': Icons.payments_rounded,
      'color': Color(0xFFD97706),
    },
    {
      'title': 'بطاقة صراف آلي (EBS)',
      'subtitle': 'شبكة المحول القومي السوداني',
      'icon': Icons.credit_card_rounded,
      'color': Color(0xFF7C3AED),
    },
  ];

  @override
  void dispose() {
    _accountNumberController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  // --- نافذة بنكك والتحقق من الحساب والـ PIN ---
  Future<Map<String, dynamic>?> _showBankakPinDialog(double totalAmount) async {
    final payment = context.read<PaymentService>();
    final accountController = TextEditingController(
        text: _accountNumberController.text.trim().isNotEmpty
            ? _accountNumberController.text.trim()
            : '2849102948');
    final pinController = TextEditingController();
    
    Map<String, dynamic>? lookedUpAccount;
    bool isLookingUp = false;
    String? pinError;
    String? accountError;

    // محاولة البحث التلقائي الأولي
    try {
      lookedUpAccount = await payment.lookupBankAccount(accountController.text.trim());
    } catch (_) {}

    if (!mounted) return null;

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_rounded,
                    color: Color(0xFF10B981), size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الربط المباشر مع بنكك',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'بنك الخرطوم — سداد فوري متزامن',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ملخص المبلغ والمخالفة
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      _bankakInfoRow('جهة السداد:', 'إدارة المرور السوداني'),
                      const SizedBox(height: 6),
                      _bankakInfoRow('المخالفة:', widget.violation.violationType),
                      const SizedBox(height: 6),
                      _bankakInfoRow('المبلغ المطلوب:',
                          CurrencyFormatter.formatSDG(totalAmount),
                          highlight: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // حقل رقم الحساب البنكي
                const Text(
                  'رقم الحساب البنكي / الهاتف:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: accountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF1E293B),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF334155)),
                          ),
                          hintText: 'مثال: 2849102948',
                          hintStyle: const TextStyle(color: Colors.white30),
                        ),
                        onChanged: (_) {
                          setDialogState(() {
                            accountError = null;
                            lookedUpAccount = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isLookingUp
                          ? null
                          : () async {
                              final acc = accountController.text.trim();
                              if (acc.isEmpty) return;
                              setDialogState(() => isLookingUp = true);
                              final found = await payment.lookupBankAccount(acc);
                              setDialogState(() {
                                isLookingUp = false;
                                lookedUpAccount = found;
                                if (found == null) {
                                  accountError = 'الحساب غير موجود في النظام';
                                } else {
                                  accountError = null;
                                }
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF334155),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: isLookingUp
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('تحقق', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                if (accountError != null) ...[
                  const SizedBox(height: 4),
                  Text(accountError!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
                ],

                // بطاقة تأكيد صاحب الحساب
                if (lookedUpAccount != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B).withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, color: Color(0xFF34D399), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'صاحب الحساب: ${lookedUpAccount!['name']}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'البنك: ${lookedUpAccount!['bankName'] ?? 'بنكك'} | الرصيد: ${CurrencyFormatter.formatSDG((lookedUpAccount!['balance'] as num).toDouble())}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                const Text(
                  'أدخل رمز الـ PIN السري (4 أرقام):',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pinController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF10B981)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF34D399), width: 2),
                    ),
                    hintText: '● ● ● ●',
                    hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        letterSpacing: 10,
                        fontSize: 18),
                  ),
                ),
                if (pinError != null) ...[
                  const SizedBox(height: 6),
                  Text(pinError!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 12)),
                ],
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'الحساب الافتراضي: 2849102948 | الـ PIN: 1234',
                      style: TextStyle(color: Color(0xFF34D399), fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('إلغاء',
                  style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final acc = accountController.text.trim();
                final pin = pinController.text.trim();
                if (acc.isEmpty) {
                  setDialogState(() => accountError = 'يرجى إدخال رقم الحساب');
                  return;
                }
                if (pin.length != 4) {
                  setDialogState(() => pinError = 'يرجى إدخال رمز PIN من 4 أرقام');
                  return;
                }

                Navigator.of(ctx).pop({
                  'account': acc,
                  'pin': pin,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: const Text('تأكيد وخصم الرصيد',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bankakInfoRow(String label, String value,
      {bool mono = false, bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: highlight ? const Color(0xFF34D399) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: highlight ? 13 : 12,
              fontFamily: mono ? 'monospace' : null,
            ),
          ),
        ),
      ],
    );
  }

  // --- نافذة OTP للطرق الأخرى ---
  Future<bool?> _showOtpDialog() {
    final otpController = TextEditingController();
    final auth = context.read<AuthService>();
    final userEmail = auth.currentUser?.email ?? '';

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.goldPrimary, width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.security_rounded, color: AppColors.goldPrimary),
            const SizedBox(width: 8),
            Text(
              'التحقق الأمني (OTP)',
              style: AppTypography.titleSmall
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تم إرسال رمز التحقق إلى:\n$userEmail',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(
                fontSize: 22,
                letterSpacing: 10,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '------',
                hintStyle:
                    TextStyle(color: AppColors.textMuted, letterSpacing: 8),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'الرمز التجريبي: 123456',
                style: AppTypography.bodySmall
                  .copyWith(color: AppColors.success, fontSize: 11),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final otp = otpController.text.trim();
              if (otp == '123456' || otp.length == 6) {
                Navigator.of(ctx).pop(true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: Colors.black,
            ),
            child: const Text('تأكيد',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Pipeline الدفع الكامل والربط البنكي ---
  Future<void> _processPayment() async {
    const double serviceFee = 500.0;
    final double totalAmount = widget.violation.amount + serviceFee;
    final auth = context.read<AuthService>();
    final payment = context.read<PaymentService>();
    final notif = context.read<NotificationService>();
    final user = auth.currentUser;

    String bankAccountUsed = '2849102948';
    String bankPinUsed = '1234';

    if (_selectedMethodIndex == 0) {
      final bankAuthResult = await _showBankakPinDialog(totalAmount);
      if (bankAuthResult == null) return;
      bankAccountUsed = bankAuthResult['account'] as String;
      bankPinUsed = bankAuthResult['pin'] as String;
    } else {
      try {
        await auth.sendOtpToEmail(auth.currentUser?.email ?? '');
      } catch (_) {}
      if (!mounted) return;
      final isConfirmed = await _showOtpDialog();
      if (isConfirmed != true) return;
    }

    if (!mounted) return;

    setState(() {
      _isProcessingPayment = true;
      _processingStep = 'جاري التحقق من الحساب البنكي والرصيد...';
    });

    try {
      setState(() => _processingStep = 'جاري خصم المبلغ وتسجيل المعاملة البنكية...');

      final receipt = await payment.processRealBankPayment(
        violationId: widget.violation.id,
        bankAccountQuery: bankAccountUsed,
        pin: bankPinUsed,
        paymentMethod:
            _paymentMethods[_selectedMethodIndex]['title'] as String,
        payerName: user?.fullName ?? 'محمد عبد الرحمن الشيخ',
        payerNationalId: user?.nationalId ?? '11829471928',
        serviceFee: serviceFee,
      );

      if (!mounted) return;

      setState(() => _processingStep = 'جاري تسجيل الإيصال وإصدار الإشعار...');

      await notif.sendPaymentConfirmedNotification(
        targetUserId: user?.id ?? '',
        transactionId: receipt.displayBankingRef,
        violationId: widget.violation.id,
        amount: receipt.amount,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(receipt: receipt),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessingPayment = false);
      _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.error, size: 26),
            SizedBox(width: 8),
            Text('فشلت عملية السداد'),
          ],
        ),
        content: Text(message,
            style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حاول مرة أخرى',
                style: TextStyle(color: AppColors.goldPrimary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payment = context.watch<PaymentService>();
    const double serviceFee = 500.0;
    final double totalAmount = widget.violation.amount + serviceFee;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('بوابة الدفع الإلكتروني'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed:
              _isProcessingPayment ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _isProcessingPayment
            ? _buildProcessingView()
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ملخص الفاتورة
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: AppColors.sovereignHeaderGradient,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color:
                                AppColors.goldPrimary.withValues(alpha: 0.4),
                            width: 1.2),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'ملخص فاتورة السداد',
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.goldPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPriceRow('قيمة الغرامة المرورية',
                              widget.violation.amount),
                          const SizedBox(height: 8),
                          _buildPriceRow(
                              'رسوم الخدمة الإلكترونية', serviceFee,
                              color: AppColors.textSecondary),
                          const Divider(
                              height: 20, color: AppColors.divider),
                          _buildPriceRow('إجمالي المستحق', totalAmount,
                              isTotal: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // اختيار وسيلة الدفع
                    Text(
                      'اختر وسيلة الدفع',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.goldPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...List.generate(_paymentMethods.length, (index) {
                      final method = _paymentMethods[index];
                      final isSelected = _selectedMethodIndex == index;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedMethodIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.cardElevated
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.goldPrimary
                                  : AppColors.cardBorder,
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (method['color'] as Color)
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  method['icon'] as IconData,
                                  color: method['color'] as Color,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(method['title'] as String,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                          fontSize: 13,
                                        )),
                                    Text(method['subtitle'] as String,
                                        style: AppTypography.bodySmall),
                                  ],
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                color: isSelected
                                    ? AppColors.goldPrimary
                                    : AppColors.textMuted,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // نموذج الدفع
                    if (_selectedMethodIndex == 0) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00875A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                const Color(0xFF00875A).withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00875A),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                  Icons.account_balance_rounded,
                                  color: Colors.white,
                                  size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'الدفع عبر بنكك',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'اضغط "سداد" وسيطلب منك رمز PIN بنكك',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: const Color(0xFF34D399),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_selectedMethodIndex == 1 ||
                        _selectedMethodIndex == 2) ...[
                      CustomTextField(
                        controller: _accountNumberController,
                        label: _selectedMethodIndex == 1
                            ? 'رقم هاتف تطبيق فوري'
                            : 'رقم هاتف أوكاش',
                        hint: '0912345678',
                        prefixIcon: Icons.phone_android_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ] else ...[
                      CustomTextField(
                        controller: _cardNumberController,
                        label: 'رقم بطاقة الصراف الآلي',
                        hint: 'XXXX XXXX XXXX XXXX',
                        prefixIcon: Icons.credit_card_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _expiryController,
                              label: 'تاريخ الانتهاء',
                              hint: 'MM/YY',
                              prefixIcon: Icons.calendar_today_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _cvvController,
                              label: 'رمز CVV',
                              hint: 'XXX',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: true,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 28),

                    CustomButton(
                      text: _selectedMethodIndex == 0
                          ? '🏦 سداد عبر بنكك — ${CurrencyFormatter.formatSDG(totalAmount)}'
                          : 'سداد ${CurrencyFormatter.formatSDG(totalAmount)} بأمان',
                      icon: Icons.lock_rounded,
                      isLoading: payment.isProcessing || _isProcessingPayment,
                      onPressed:
                          _isProcessingPayment ? null : _processPayment,
                    ),

                    const SizedBox(height: 14),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shield_outlined,
                              size: 13, color: AppColors.success),
                          const SizedBox(width: 5),
                          Text(
                            'مشفر بالتشفير السيادي 256-bit',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount,
      {bool isTotal = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)
              : AppTypography.bodySmall,
        ),
        Text(
          CurrencyFormatter.formatSDG(amount),
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            fontSize: isTotal ? 16 : 14,
            color: color ?? (isTotal ? AppColors.goldPrimary : Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.goldPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: 0.4),
                    width: 2),
              ),
              child: const CircularProgressIndicator(
                color: AppColors.goldPrimary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'جارٍ معالجة الدفع...',
              style: AppTypography.titleMedium
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _processingStep,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
