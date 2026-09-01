import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال بريد إلكتروني صحيح'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);
    final auth = context.read<AuthService>();
    final success = await auth.resetPassword(email);
    setState(() => _isLoading = false);

    if (success && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Icon(Icons.mark_email_read, color: AppColors.success, size: 60),
          content: Text(
            'تم إرسال رابط استعادة كلمة المرور إلى:\n$email\n\nيرجى مراجعة بريدك الإلكتروني.',
            textAlign: TextAlign.center,
          ),
          actions: [
            CustomButton(
              text: 'العودة للدخول',
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close forgot password screen
              },
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ، تأكد من صحة البريد الإلكتروني'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('استعادة كلمة المرور')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.lock_reset, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              'هل نسيت كلمة المرور؟',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'أدخل بريدك الإلكتروني أدناه، وسنقوم بإرسال رابط آمن ومباشر لإعادة تعيين كلمة المرور الخاصة بك.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomTextField(
              controller: _emailController,
              label: 'البريد الإلكتروني',
              hint: '',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'إرسال رابط الاستعادة',
              icon: Icons.send,
              isLoading: _isLoading,
              onPressed: _handleReset,
            ),
          ],
        ),
      ),
    );
  }
}
