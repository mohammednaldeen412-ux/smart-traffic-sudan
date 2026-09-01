import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/sovereign_badge.dart';
import '../../models/user_model.dart';
import '../dashboard/smart_role_router.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'officer_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController(); // Empty for official mode
  final _passwordController = TextEditingController(); // Empty for official mode
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthService>();
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final success = await auth.login(
        identifier: identifier,
        password: password,
        selectedRole: UserRole.citizen, // Hardcoded to citizen for this screen
      );

      if (!mounted) return;

      if (success) {
        if (_rememberMe) {
          await auth.enableBiometrics(identifier, password);
        }
        
        if (!mounted) return;
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SmartRoleRouter()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'خطأ: ${e.toString().replaceAll('Exception: ', '')}',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleBiometricLogin() async {
    final auth = context.read<AuthService>();
    try {
      final success = await auth.loginWithBiometrics();
      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SmartRoleRouter()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goldPrimary.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.info.withValues(alpha: 0.08),
              ),
            ),
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.transparent),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const OfflineBanner(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),
                          const SovereignBadge(),
                          const SizedBox(height: 32),

                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.goldPrimary, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.goldPrimary.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.traffic_rounded, size: 36, color: AppColors.goldPrimary),
                            ),
                          ),

                          const SizedBox(height: 18),
                          Text(
                            'تسجيل الدخول',
                            style: AppTypography.displayMedium.copyWith(fontSize: 24, fontWeight: FontWeight.w900),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'بوابة المواطن للخدمات المرورية',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.15), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                CustomTextField(
                                  controller: _identifierController,
                                  label: 'الرقم الوطني / البريد الإلكتروني',
                                  hint: '',
                                  prefixIcon: Icons.badge_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) return 'يرجى إدخال الرقم الوطني أو الإيميل';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),
                                CustomTextField(
                                  controller: _passwordController,
                                  label: 'كلمة المرور',
                                  hint: '',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  obscureText: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textSecondary, size: 20),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.length < 6) return 'كلمة المرور يجب أن لا تقل عن 6 أحرف';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 24, height: 24,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            activeColor: AppColors.goldPrimary,
                                            checkColor: AppColors.background,
                                            side: const BorderSide(color: AppColors.cardBorder),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                            onChanged: (val) => setState(() => _rememberMe = val ?? true),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text('تذكرني', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                                      ],
                                    ),
                                    TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())), child: Text('نسيت كلمة المرور؟', style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                CustomButton(
                                  text: 'تسجيل الدخول',
                                  icon: Icons.login_rounded,
                                  isLoading: auth.isLoading,
                                  onPressed: _handleLogin,
                                ),
                                if (auth.isBiometricAvailable && auth.isBiometricEnabled) ...[
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: auth.isLoading ? null : _handleBiometricLogin,
                                    icon: const Icon(Icons.fingerprint_rounded, size: 24),
                                    label: const Text('الدخول بالبصمة'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.goldPrimary,
                                      side: const BorderSide(color: AppColors.goldPrimary, width: 1.2),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'تسجيل حساب مواطن جديد',
                            isOutlined: true,
                            icon: Icons.person_add_alt_1_rounded,
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
                            },
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OfficerLoginScreen()));
                            },
                            icon: const Icon(Icons.local_police, color: AppColors.goldPrimary),
                            label: Text(
                              'بوابة دخول ضباط وأفراد المرور',
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.goldPrimary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

