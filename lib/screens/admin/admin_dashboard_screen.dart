import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/services/theme_provider.dart';
import '../../core/services/traffic_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _broadcastController = TextEditingController();

  void _sendBroadcast() {
    if (_broadcastController.text.trim().isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.goldPrimary),
        ),
        title: const Text('تأكيد التعميم السيادي'),
        content: Text('هل أنت متأكد من إرسال هذا التعميم لجميع الضباط الميدانيين؟\n\n"${_broadcastController.text}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _broadcastController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال التعميم لجميع الوحدات الميدانية بنجاح'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary),
            child: const Text('إرسال الآن'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final traffic = context.watch<TrafficService>();
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('لوحة التحكم الإدارية السيادية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_rounded, color: AppColors.goldPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إحصائيات الحالة المرورية العامة',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.goldPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // كروت الإحصائيات
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'إجمالي المخالفات',
                    value: '${traffic.globalTotalViolations}',
                    icon: Icons.gavel_rounded,
                    color: AppColors.error,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'التحصيل المالي',
                    value: '${(traffic.globalTotalRevenue / 1000000).toStringAsFixed(1)}M',
                    icon: Icons.payments_rounded,
                    color: AppColors.success,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'المخالفات النشطة',
                    value: '${traffic.globalUnpaidCount}',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'الاعتراضات',
                    value: '12', // يمكن ربطها لاحقاً بـ traffic.disputes.length إذا كانت شاملة
                    icon: Icons.message_rounded,
                    color: AppColors.info,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // قسم إرسال التعميم
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.goldPrimary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.campaign_rounded, color: AppColors.goldPrimary),
                      const SizedBox(width: 8),
                      Text(
                        'إرسال تعميم للضباط والقوات',
                        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _broadcastController,
                    label: 'نص التعميم الإداري',
                    hint: 'اكتب التعليمات أو التنبيهات هنا...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'بث التعميم لكافة الوحدات الميدانية',
                    icon: Icons.send_rounded,
                    onPressed: _sendBroadcast,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'أحدث العمليات الميدانية',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.goldPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // قائمة العمليات الأخيرة الحقيقية من السيرفر
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: traffic.allViolations.length > 5 ? 5 : traffic.allViolations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final violation = traffic.allViolations[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.cardBorder : AppColors.lightCardBorder),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: (violation.isPaid ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                      child: Icon(
                        violation.isPaid ? Icons.check_circle_rounded : Icons.gavel_rounded,
                        color: violation.isPaid ? AppColors.success : AppColors.error,
                      ),
                    ),
                    title: Text(
                      violation.violationType,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      '${violation.locality} • ${violation.officerName}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    trailing: Text(
                      violation.isPaid ? 'مُسددة' : 'غير مسددة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: violation.isPaid ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.cardBorder : AppColors.lightCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
