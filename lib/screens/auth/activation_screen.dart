import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/locale_provider.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/app_background.dart';
import '../../widgets/auth_top_bar.dart';
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

  /// ترجمة خارج build (بدون watch)
  String _t(String key) => AppStrings.tr(key, context.read<LocaleProvider>().languageCode);

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_nationalIdController.text.trim().length != 11) {
        _showError(_t('national_id_invalid'));
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 1) {
      if (_otpController.text.trim() != '1234') {
        _showError(_t('otp_invalid'));
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 2) {
      if (_passwordController.text.length < 6) {
        _showError(_t('password_short'));
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
      if (mounted) _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = GlassColors.of(context);
    const gold = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: c.text),
        actions: const [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 12),
            child: Center(child: AuthTopBar()),
          ),
        ],
      ),
      body: AppBackground(
        role: AppRole.auth,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: GlassCard(
                blur: 15,
                opacity: c.glassOpacity,
                tintColor: c.glassTint,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user_rounded, size: 64, color: gold),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('smart_activation'),
                      textAlign: TextAlign.center,
                      style: AppTypography.titleLarge.copyWith(color: c.text, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('activation_step${_currentStep + 1}'),
                      style: TextStyle(color: c.textMuted, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _StepDots(current: _currentStep, color: gold, inactive: c.textFaint),
                    const SizedBox(height: 24),

                    if (_currentStep == 0) _buildStep1(),
                    if (_currentStep == 1) _buildStep2(c),
                    if (_currentStep == 2) _buildStep3(),

                    const SizedBox(height: 32),

                    _isLoading
                        ? const CircularProgressIndicator(color: gold)
                        : CustomButton(
                            text: context.tr(_currentStep == 2 ? 'confirm_activate' : 'next'),
                            onPressed: _nextStep,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return CustomTextField(
      controller: _nationalIdController,
      label: context.tr('national_id'),
      hint: context.tr('national_id_hint'),
      keyboardType: TextInputType.number,
      prefixIcon: Icons.badge_outlined,
    );
  }

  Widget _buildStep2(GlassColors c) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('otp_sent_msg'),
                  style: TextStyle(color: c.textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _otpController,
          label: context.tr('otp_label'),
          hint: context.tr('otp_hint'),
          keyboardType: TextInputType.number,
          prefixIcon: Icons.message_outlined,
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return CustomTextField(
      controller: _passwordController,
      label: context.tr('new_password'),
      hint: context.tr('new_password_hint'),
      obscureText: true,
      prefixIcon: Icons.lock_outline,
    );
  }
}

/// مؤشر الخطوات (3 نقاط)
class _StepDots extends StatelessWidget {
  final int current;
  final Color color;
  final Color inactive;
  const _StepDots({required this.current, required this.color, required this.inactive});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i <= current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == current ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: active ? color : inactive.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}
