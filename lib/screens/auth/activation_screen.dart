import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_card.dart';
import '../dashboard/smart_role_router.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  int _currentStep = 0;
  final _nationalIdController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nationalIdController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_nationalIdController.text.length != 11) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرقم الوطني يجب أن يكون 11 رقماً')));
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 1) {
      if (_otpController.text != '1234') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('رمز التحقق غير صحيح (أدخل 1234 للتجربة)')));
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 2) {
      if (_passwordController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كلمة المرور يجب أن لا تقل عن 6 أحرف')));
        return;
      }
      _activateAccount();
    }
  }

  Future<void> _activateAccount() async {
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthService>();
      final success = await auth.activateAccount(
        nationalId: _nationalIdController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (success && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SmartRoleRouter()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.8, -0.6),
                radius: 1.5,
                colors: [Color(0xFF1E293B), Color(0xFF0A0E17)],
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: GlassCard(
                  blur: 15,
                  opacity: 0.1,
                  tintColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_user_rounded, size: 64, color: Color(0xFFD4AF37)),
                        const SizedBox(height: 16),
                        Text(
                          'تفعيل الحساب الذكي',
                          style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getStepSubtitle(),
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        
                        // Steps content
                        if (_currentStep == 0) _buildStep1(),
                        if (_currentStep == 1) _buildStep2(),
                        if (_currentStep == 2) _buildStep3(),
                        
                        const SizedBox(height: 32),
                        
                        _isLoading
                            ? const CircularProgressIndicator(color: Color(0xFFD4AF37))
                            : CustomButton(
                                text: _currentStep == 2 ? 'تأكيد وتفعيل الحساب' : 'التالي',
                                onPressed: _nextStep,
                                backgroundColor: const Color(0xFFD4AF37),
                                textColor: const Color(0xFF0F172A),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 0: return 'أدخل رقمك الوطني للبحث عن بياناتك في السجل المدني والمرور.';
      case 1: return 'تم العثور على بياناتك. أدخل رمز التحقق OTP المرسل إلى هاتفك.';
      case 2: return 'قم بتعيين كلمة مرور جديدة لتأمين حسابك الذكي.';
      default: return '';
    }
  }

  Widget _buildStep1() {
    return CustomTextField(
      controller: _nationalIdController,
      label: 'الرقم الوطني',
      hint: 'أدخل 11 رقماً',
      keyboardType: TextInputType.number,
      prefixIcon: Icons.badge_outlined,
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تم إرسال رمز OTP إلى رقم هاتفك المسجل لدى إدارة المرور (091****123).',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _otpController,
          label: 'رمز التحقق OTP',
          hint: 'أدخل 1234 للتجربة',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.message_outlined,
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return CustomTextField(
      controller: _passwordController,
      label: 'كلمة المرور الجديدة',
      hint: 'أدخل 6 أحرف أو أكثر',
      obscureText: true,
      prefixIcon: Icons.lock_outline,
    );
  }
}
