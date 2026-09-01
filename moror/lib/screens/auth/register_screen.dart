import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  final _fullNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  
  String _selectedState = 'الخرطوم';
  bool _obscurePassword = true;
  bool _agreedToTerms = true;
  File? _profileImage;

  final List<String> _sudanStates = [
    'الخرطوم', 'البحر الأحمر', 'الجزيرة', 'نهر النيل', 'الشمالية',
    'القضارف', 'كسلا', 'سنار', 'النيل الأبيض', 'النيل الأزرق',
    'شمال كردفان', 'جنوب كردفان', 'غرب كردفان', 'شمال دارفور',
    'جنوب دارفور', 'غرب دارفور', 'وسط دارفور', 'شرق دارفور',
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _addressController.dispose();
        _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة بشكل صحيح'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب الموافقة على الشروط والأحكام للمتابعة'), backgroundColor: Colors.orange),
      );
      return;
    }

    final auth = context.read<AuthService>();
    try {
      final success = await auth.register(
        fullName: _fullNameController.text.trim(),
        nationalId: _nationalIdController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        state: _selectedState,
        city: _cityController.text.trim().isEmpty ? _selectedState : _cityController.text.trim(),
        address: _addressController.text.trim(),
                driverLicenseNumber: '',
        password: _passwordController.text.trim(),
        profileImage: _profileImage,
      );

      if (success && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Icon(Icons.mark_email_read_rounded, color: Colors.green, size: 60),
            content: const Text('تم إنشاء الحساب بنجاح!\nلقد أرسلنا رسالة تفعيل إلى بريدك الإلكتروني. يرجى تفعيل حسابك قبل تسجيل الدخول.', textAlign: TextAlign.center),
            actions: [
              CustomButton(
                text: 'العودة للدخول',
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('تسجيل حساب جديد')),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          type: StepperType.horizontal,
          onStepTapped: (step) => setState(() => _currentStep = step),
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep += 1);
            } else {
              _handleRegister();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            } else {
              Navigator.of(context).pop();
            }
          },
          controlsBuilder: (context, details) {
            final isLastStep = _currentStep == 2;
            return Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: isLastStep ? 'تأكيد وإنشاء حساب' : 'التالي',
                      isLoading: auth.isLoading,
                      onPressed: details.onStepContinue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_currentStep > 0)
                    Expanded(
                      child: CustomButton(
                        text: 'رجوع',
                        isOutlined: true,
                        onPressed: details.onStepCancel,
                      ),
                    ),
                ],
              ),
            );
          },
          steps: [
    // Step 1: Personal Info
    Step(
      title: const Text('البيانات الشخصية', style: TextStyle(fontSize: 12)),
      isActive: _currentStep >= 0,
      content: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null ? const Icon(Icons.add_a_photo, size: 30, color: Colors.grey) : null,
                ),
                const SizedBox(height: 8),
                Text(
                  _profileImage != null ? 'تم اختيار الصورة محلياً' : 'صورة شخصية (اختيارية)',
                  style: TextStyle(fontSize: 11, color: _profileImage != null ? Colors.green : Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
                  CustomTextField(
                    controller: _fullNameController,
                    label: 'الاسم الرباعي',
                    hint: '',
                    prefixIcon: Icons.person_outline,
                    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _nationalIdController,
                    label: 'الرقم الوطني',
                    hint: '',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.badge_outlined,
                    validator: (v) => v!.length < 11 ? 'الرقم الوطني غير صحيح' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _phoneController,
                    label: 'رقم الهاتف',
                    hint: '',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_android_outlined,
                    validator: (v) => v!.length < 10 ? 'رقم هاتف غير صحيح' : null,
                  ),
                ],
              ),
            ),
            // Step 2: Location & License
            Step(
              title: const Text('السكن والرخصة', style: TextStyle(fontSize: 12)),
              isActive: _currentStep >= 1,
              content: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedState,
                    decoration: InputDecoration(
                      labelText: 'الولاية',
                      prefixIcon: const Icon(Icons.map_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    items: _sudanStates.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => _selectedState = val!),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _cityController,
                    label: 'المدينة / المحلية',
                    hint: '', // Removed placeholder
                    prefixIcon: Icons.location_city_outlined,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _addressController,
                    label: 'العنوان التفصيلي',
                    hint: '', // Removed placeholder
                    prefixIcon: Icons.home_outlined,
                  ),
                  
                ],
              ),
            ),
            // Step 3: Account Security
            Step(
              title: const Text('بيانات الدخول', style: TextStyle(fontSize: 12)),
              isActive: _currentStep >= 2,
              content: Column(
                children: [
                  CustomTextField(
                    controller: _emailController,
                    label: 'البريد الإلكتروني',
                    hint: '',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) => v!.contains('@') ? null : 'بريد غير صحيح',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'كلمة المرور',
                    hint: '',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) => v!.length < 6 ? 'كلمة المرور قصيرة جداً' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'تأكيد كلمة المرور',
                    hint: '',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    validator: (v) => v != _passwordController.text ? 'كلمات المرور غير متطابقة' : null,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: _agreedToTerms,
                    onChanged: (v) => setState(() => _agreedToTerms = v ?? true),
                    title: const Text('أوافق على الشروط والأحكام الخاصة بالمرور', style: TextStyle(fontSize: 13)),
                    activeColor: AppColors.goldPrimary,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



