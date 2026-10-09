import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/services/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_background.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 1;
  final _nationalIdCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _securityAnswerCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();

  bool _isLoading = false;

  void _nextStep() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
      if (_step < 4) _step++;
    });
  }

  void _finish() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.isArabic ? 'تم تغيير كلمة السر بنجاح' : 'Password changed successfully'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = GlassColors.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: c.text),
      ),
      body: AppBackground(
        role: AppRole.citizen,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                blur: 20,
                opacity: c.isDark ? 0.3 : 0.7,
                tintColor: c.isDark ? Colors.black : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_reset_rounded, size: 64, color: AppColors.goldPrimary),
                      const SizedBox(height: 16),
                      Text(
                        context.isArabic ? 'استعادة كلمة السر' : 'Reset Password',
                        style: AppTypography.displayMedium.copyWith(color: c.text, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      if (_step == 1) ...[
                        Text(context.isArabic ? 'أدخل الرقم الوطني ورقم الهاتف المرتبط بالحساب لإرسال رمز التحقق (OTP).' : 'Enter National ID and Phone number to receive OTP.', style: TextStyle(color: c.text)),
                        const SizedBox(height: 16),
                        CustomTextField(controller: _nationalIdCtrl, label: context.isArabic ? 'الرقم الوطني' : 'National ID', prefixIcon: Icons.badge),
                        const SizedBox(height: 12),
                        CustomTextField(controller: _phoneCtrl, label: context.isArabic ? 'رقم الهاتف' : 'Phone Number', prefixIcon: Icons.phone),
                        const SizedBox(height: 24),
                        CustomButton(text: context.isArabic ? 'إرسال الرمز' : 'Send OTP', isLoading: _isLoading, onPressed: _nextStep),
                      ] else if (_step == 2) ...[
                        Text(context.isArabic ? 'تم إرسال رمز تحقق (OTP) إلى هاتفك. الرجاء إدخاله أدناه (للتجربة أدخل 1234)' : 'OTP sent to your phone. Enter below (mock: 1234)', style: TextStyle(color: c.text)),
                        const SizedBox(height: 16),
                        CustomTextField(controller: _otpCtrl, label: context.isArabic ? 'رمز التحقق (OTP)' : 'OTP Code', prefixIcon: Icons.message),
                        const SizedBox(height: 24),
                        CustomButton(text: context.isArabic ? 'تحقق' : 'Verify', isLoading: _isLoading, onPressed: _nextStep),
                      ] else if (_step == 3) ...[
                        Text(context.isArabic ? 'أجب على سؤال الأمان الخاص بك للمتابعة' : 'Answer your security question', style: TextStyle(color: c.text)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: c.glassTint.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                          child: Text(context.isArabic ? 'ما هو اسم أول مدرسة التحقت بها؟' : 'What was the name of your first school?', style: TextStyle(color: c.text, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(controller: _securityAnswerCtrl, label: context.isArabic ? 'الإجابة' : 'Answer', prefixIcon: Icons.security),
                        const SizedBox(height: 24),
                        CustomButton(text: context.isArabic ? 'التالي' : 'Next', isLoading: _isLoading, onPressed: _nextStep),
                      ] else if (_step == 4) ...[
                        Text(context.isArabic ? 'أدخل كلمة السر الجديدة (يجب أن تحتوي على 8 أحرف، حرف كبير، صغير، رقم، ورمز)' : 'Enter new complex password', style: TextStyle(color: c.text)),
                        const SizedBox(height: 16),
                        CustomTextField(controller: _newPasswordCtrl, label: context.isArabic ? 'كلمة السر الجديدة' : 'New Password', prefixIcon: Icons.lock, obscureText: true),
                        const SizedBox(height: 24),
                        CustomButton(text: context.isArabic ? 'حفظ الدخول' : 'Save & Login', isLoading: _isLoading, onPressed: _finish),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
