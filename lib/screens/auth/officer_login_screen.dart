import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../models/user_model.dart';
import '../officer/officer_navigation_wrapper.dart';

class OfficerLoginScreen extends StatefulWidget {
  const OfficerLoginScreen({super.key});

  @override
  State<OfficerLoginScreen> createState() => _OfficerLoginScreenState();
}

class _OfficerLoginScreenState extends State<OfficerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _badgeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _badgeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthService>();
    final nav = Navigator.of(context);
    try {
      final success = await auth.login(
        identifier: _badgeController.text.trim(),
        password: _passwordController.text.trim(),
        selectedRole: UserRole.officer,
      );
      if (success && mounted) {
        nav.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OfficerNavigationWrapper()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F), // Deep blue for officers
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Center(
                  child: Icon(Icons.local_police, size: 80, color: Colors.amber),
                ),
                const SizedBox(height: 24),
                const Text(
                  'بوابة دخول الضباط',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'أدخل الرقم العسكري / كود الضابط الخاص بك',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _badgeController,
                        label: 'كود الضابط / الإيميل',
                        hint: 'مثال: OFFICER-001',
                        prefixIcon: Icons.badge,
                        labelColor: Colors.black87,
                        textColor: Colors.black87,
                        fillColor: Colors.grey.shade100,
                        validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'كلمة المرور',
                        prefixIcon: Icons.lock_outline_rounded,
                        labelColor: Colors.black87,
                        textColor: Colors.black87,
                        fillColor: Colors.grey.shade100,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey.shade700),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        text: 'تسجيل الدخول',
                        icon: Icons.login,
                        isLoading: auth.isLoading,
                        onPressed: _handleLogin,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

