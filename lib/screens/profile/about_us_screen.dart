import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_background.dart';
import '../../widgets/glass_card.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.textMuted : AppColors.lightTextMuted;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('التوثيق والدعم الفني', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.code_rounded, size: 60, color: AppColors.goldPrimary),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'نظام المرور الذكي V3',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ),
                Center(
                  child: Text(
                    'النسخة النهائية (Final Release)',
                    style: TextStyle(fontSize: 14, color: AppColors.goldPrimary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 32),
                Text('عن التطبيق', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 12),
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'هذا التطبيق هو نظام متكامل لإدارة المخالفات المرورية في السودان، تم تصميمه كجزء من مشروع تخرج متكامل (موبايل، ويب، قواعد بيانات، بوابة دفع بنكك).',
                      style: TextStyle(color: textMuted, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('فريق التطوير (Developer Team)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 12),
                _buildTeamMember(
                  context, 
                  name: 'م. محمد نصر الدين', 
                  role: 'قائد الفريق ومطور تطبيق الموبايل',
                  phone: '0961941263',
                  github: 'mohammednaldeen412-ux',
                ),
                const SizedBox(height: 12),
                _buildTeamMember(
                  context, 
                  name: 'م. مصطفى عيسى', 
                  role: 'مهندس الخوادم وقواعد البيانات والأمان',
                  phone: '0909987293',
                ),
                const SizedBox(height: 12),
                _buildTeamMember(
                  context, 
                  name: 'م. علي عبد الرحمن', 
                  role: 'مطور واجهات الويب وبوابة الدفع واختبار الجودة',
                  phone: '0960402145',
                ),
                const SizedBox(height: 32),
                Text('تواصل معنا (Support)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 12),
                GlassCard(
                  child: ListTile(
                    leading: const Icon(Icons.email_rounded, color: AppColors.goldPrimary),
                    title: Text('البريد الإلكتروني للدعم', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                    subtitle: Text('support@smart-traffic.sd', style: TextStyle(color: textMuted)),
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: ListTile(
                    leading: const Icon(Icons.bug_report_rounded, color: Colors.redAccent),
                    title: Text('الإبلاغ عن مشكلة (Report a Bug)', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                    subtitle: Text('GitHub Issues', style: TextStyle(color: textMuted)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMember(BuildContext context, {required String name, required String role, required String phone, String? github}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.textMuted : AppColors.lightTextMuted;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.goldPrimary,
                  child: Icon(Icons.person_outline, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(role, style: TextStyle(color: textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone_android_rounded, size: 16, color: textMuted),
                const SizedBox(width: 8),
                Text('واتساب: $phone', style: TextStyle(color: textColor, fontSize: 13)),
              ],
            ),
            if (github != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.code_rounded, size: 16, color: textMuted),
                  const SizedBox(width: 8),
                  Text('جيت هب: $github', style: TextStyle(color: textColor, fontSize: 13)),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
