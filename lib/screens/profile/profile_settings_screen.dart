import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/locale_provider.dart';
import '../../core/services/theme_provider.dart';
import '../../core/services/traffic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../auth/login_screen.dart';
import '../emergency/emergency_hotline_screen.dart';
import 'digital_license_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _notificationsEnabled = true;
  bool _radarAlerts = true;

  Future<void> _changeProfilePicture() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      final auth = context.read<AuthService>();
      final url = await auth.uploadProfileImage(File(pickedFile.path));
      if (url != null && mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الصورة الشخصية بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _showEditProfileDialog() {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    final phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    final cityController = TextEditingController(text: user?.city ?? '');
    final addressController = TextEditingController(text: user?.address ?? '');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Theme.of(dialogCtx).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.edit_note_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('تعديل البيانات الشخصية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: phoneController,
                label: 'رقم الهاتف',
                hint: '09xxxxxxx',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: cityController,
                label: 'المدينة / المنطقة',
                hint: 'الخرطوم',
                prefixIcon: Icons.location_city_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: addressController,
                label: 'العنوان السكني',
                hint: 'الرياض - شارع المشتل',
                prefixIcon: Icons.home_outlined,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              if (user != null) {
                final updated = user.copyWith(
                  phoneNumber: phoneController.text.trim(),
                  city: cityController.text.trim(),
                  address: addressController.text.trim(),
                );
                await auth.updateUser(updated);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حفظ البيانات الجديدة بنجاح'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('حفظ التعديلات'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
            SizedBox(width: 8),
            Text('سياسة الاستخدام والخصوصية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تطبيق مرور السودان الذكي (Smart Traffic Sudan)\n'
                'الإدارة العامة للمرور - وزارة الداخلية',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(height: 10),
              Text(
                '1. حماية البيانات المشفرة:\n'
                'تخضع كافة البيانات والوثائق والمعلومات المرفوعة لمعايير التشفير القومية وحماية الخصوصية الرقمية.\n\n'
                '2. الرخص الرقمية والتحقق:\n'
                'الرخصة الرقمية داخل التطبيق معتمدة رسمياً ومزودة برمز QR ديناميكي ومشفر للتحقق الفوري من قبل دوريات المرور.\n\n'
                '3. بوابات السداد الإلكتروني:\n'
                'جميع المعاملات المالية وسداد المخالفات تتم عبر الربط المباشر مع شبكة المحول القومي (EBS) والتطبيقات المصرفية المعتمدة (بنكك، فوري، أوكاش).\n\n'
                '4. التنبيهات وإشعارات الرادار:\n'
                'يستخدم التطبيق خدمات الموقع والتنبيهات لإشعار السائقين بالمخالفات الفورية ونقاط التهدئة لتعزيز السلامة المرورية.',
                style: TextStyle(fontSize: 12, height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    // ... logic remains same
  }

  void _showChangePasswordDialog() {
    final auth = context.read<AuthService>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Theme.of(dialogCtx).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('تغيير كلمة المرور', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: currentPasswordController,
                label: 'كلمة المرور الحالية',
                obscureText: true,
                prefixIcon: Icons.lock_open_rounded,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: newPasswordController,
                label: 'كلمة المرور الجديدة',
                obscureText: true,
                prefixIcon: Icons.lock_outline_rounded,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: confirmPasswordController,
                label: 'تأكيد كلمة المرور',
                obscureText: true,
                prefixIcon: Icons.lock_reset_rounded,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(dialogCtx);
              if (newPasswordController.text != confirmPasswordController.text) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('كلمتا المرور غير متطابقتين'), backgroundColor: AppColors.error),
                );
                return;
              }
              
              try {
                final success = await auth.changePassword(
                  currentPasswordController.text.trim(),
                  newPasswordController.text.trim(),
                );
                if (success) {
                  nav.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح'), backgroundColor: AppColors.success),
                  );
                }
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('خطأ: ${e.toString()}'), backgroundColor: AppColors.error),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final traffic = context.watch<TrafficService>();
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('الإعدادات والملف الشخصي', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'تعديل البيانات',
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. Profile Header Card ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        backgroundImage: user?.profileImageUrl != null
                            ? NetworkImage(user!.profileImageUrl!)
                            : null,
                        child: user?.profileImageUrl == null
                            ? const Icon(Icons.person, color: AppColors.primary, size: 48)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _changeProfilePicture,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'المواطن السوداني',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fingerprint, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        'الرقم الوطني: ${user?.nationalId ?? 'غير موثق'}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      user?.isOfficer == true ? 'حساب ضابط مرور معتمد' : 'حساب مواطن موثق',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── 1.5 Quick Stats Row ───
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  _buildStatItem('المركبات', traffic.totalVehiclesCount.toString(), Icons.directions_car_filled_rounded),
                  const SizedBox(width: 12),
                  _buildStatItem('المخالفات', traffic.unpaidViolationsCount.toString(), Icons.receipt_long_rounded, isError: traffic.unpaidViolationsCount > 0),
                  const SizedBox(width: 12),
                  _buildStatItem('المبالغ', '${traffic.totalUnpaidAmount.toInt()} ج.س', Icons.account_balance_wallet_rounded),
                ],
              ),
            ),

            // ─── 2. Quick Access to Digital License ───
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DigitalLicenseScreen()),
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.badge_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'بطاقة رخصة القيادة الرقمية',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            'رقم الرخصة: ${user?.driverLicenseNumber ?? 'غير متوفر'}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ─── 3. Personal Information Section ───
            Text(
              'البيانات والمعلومات الشخصية',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.phone_outlined,
                    title: 'رقم الهاتف',
                    value: user?.phoneNumber ?? '0912345678',
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildInfoTile(
                    icon: Icons.email_outlined,
                    title: 'البريد الإلكتروني',
                    value: user?.email ?? 'citizen@moror.gov.sd',
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildInfoTile(
                    icon: Icons.location_on_outlined,
                    title: 'الولاية والمدينة',
                    value: '${user?.state ?? 'غير محدد'} - ${user?.city ?? 'غير محدد'}',
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildInfoTile(
                    icon: Icons.home_outlined,
                    title: 'العنوان السكني',
                    value: user?.address ?? 'غير محدد',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── 4. Application Settings (Language, Dark Mode, Alerts) ───
            Text(
              'أمان الحساب والخصوصية',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_reset_rounded, color: AppColors.primary),
                    title: const Text('تغيير كلمة المرور', style: TextStyle(fontSize: 14)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: _showChangePasswordDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── 4.5 Sovereign Documents Section ───
            Text(
              'الوثائق والتوثيقات السيادية',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  _buildDocPreview('صورة الهوية', user?.nationalIdImage),
                  const SizedBox(width: 12),
                  _buildDocPreview('صورة الرخصة', user?.licenseImage),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── 5. Application Settings (Language, Dark Mode, Alerts) ───
            Text(
              'إعدادات التطبيق والمظهر',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  // Language Selector
                  ListTile(
                    leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                    title: const Text('لغة التطبيق (Language)', style: TextStyle(fontSize: 14)),
                    subtitle: Text(
                      localeProvider.isArabic ? 'العربية (السودان)' : 'English (United States)',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    trailing: DropdownButton<String>(
                      value: localeProvider.languageCode,
                      underline: const SizedBox.shrink(),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                      items: const [
                        DropdownMenuItem(
                          value: 'ar',
                          child: Text('العربية', style: TextStyle(fontSize: 13)),
                        ),
                        DropdownMenuItem(
                          value: 'en',
                          child: Text('English', style: TextStyle(fontSize: 13)),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          localeProvider.setLocale(val);
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // Dark Mode Switch
                  SwitchListTile(
                    secondary: Icon(
                      themeProvider.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: AppColors.primary,
                    ),
                    title: const Text('الوضع المظلم (Dark Mode)', style: TextStyle(fontSize: 14)),
                    subtitle: Text(
                      themeProvider.isDark ? 'مفعل (الملكي الداكن)' : 'الوضع النهاري الفاتح',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    value: themeProvider.isDark,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      themeProvider.setDark(val);
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // Notifications Toggle
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                    title: const Text('إشعارات المخالفات والرسائل', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('تنبيه فوري عند تسجيل أي مخالفة', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    value: _notificationsEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() => _notificationsEnabled = val);
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // Radar Proximity Alert
                  SwitchListTile(
                    secondary: const Icon(Icons.speed_rounded, color: AppColors.primary),
                    title: const Text('تنبيهات السرعة والرادار', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('تنبيه السائق بنقاط التهدئة المرورية', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    value: _radarAlerts,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() => _radarAlerts = val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── 5. Privacy, Policy, & Support ───
            Text(
              'الخصوصية، المعايير والمساعدة',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.policy_outlined, color: AppColors.primary),
                    title: const Text('سياسة الاستخدام والخصوصية', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('معايير حماية البيانات وأمان أندرويد', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: _showPrivacyPolicyDialog,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.headset_mic_outlined, color: AppColors.primary),
                    title: const Text('طوارئ وغرفة عمليات المرور (777)', style: TextStyle(fontSize: 14)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const EmergencyHotlineScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                    title: const Text('حول التطبيق ومعايير النظام', style: TextStyle(fontSize: 14)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: _showAboutDialog,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── 6. Logout & Session Actions ───
            CustomButton(
              text: 'تسجيل الخروج من الحساب',
              icon: Icons.logout_rounded,
              isOutlined: true,
              textColor: AppColors.error,
              onPressed: () async {
                final navigator = Navigator.of(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    backgroundColor: Theme.of(dialogCtx).cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('تأكيد تسجيل الخروج'),
                    content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من التطبيق؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx, false),
                        child: const Text('إلغاء'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(dialogCtx, true),
                        child: const Text('تسجيل الخروج'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  await auth.signOut();
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),

            const SizedBox(height: 16),
            const Center(
              child: Text(
                'جمهورية السودان - وزارة الداخلية - المرور الذكي v1.0.0',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 110), // مسافة سفلية كافية لظهور زر تسجيل الخروج فوق شريط التنقل
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {bool isError = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: isError ? AppColors.error : AppColors.primary),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isError ? AppColors.error : null,
              ),
            ),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildDocPreview(String label, String? imageUrl) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
              image: imageUrl != null && imageUrl.startsWith('http')
                  ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: imageUrl == null || !imageUrl.startsWith('http')
                ? const Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted)
                : null,
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
