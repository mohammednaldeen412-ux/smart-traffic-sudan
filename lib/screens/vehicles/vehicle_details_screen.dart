import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/vehicle_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/sudan_plate_widget.dart';
import '../violations/violations_list_screen.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final VehicleModel vehicle;

  const VehicleDetailsScreen({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    final formattedExpiry = vehicle.licenseExpiryDate != null
        ? dateFormat.format(vehicle.licenseExpiryDate!)
        : 'ساري';
    final isExpired = vehicle.isLicenseExpired;
    final daysLeft = vehicle.daysUntilExpiry;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${vehicle.make} - ${vehicle.model}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة الرأس واللوحة السودانية
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.sovereignHeaderGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: 0.35),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldPrimary.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SudanPlateWidget(
                      plateNumber: vehicle.plateNumber,
                      stateCode: vehicle.plateStateCode,
                      categoryCode: vehicle.plateCategoryCode,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: vehicle.isVerified
                                ? AppColors.success.withValues(alpha: 0.2)
                                : AppColors.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: vehicle.isVerified
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                vehicle.isVerified
                                    ? Icons.verified_rounded
                                    : Icons.hourglass_top_rounded,
                                size: 16,
                                color: vehicle.isVerified
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                vehicle.isVerified
                                    ? 'مركبة موثقة رسمياً'
                                    : 'قيد مراجعة البيانات',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: vehicle.isVerified
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // بطاقة حالة رخصة السير والترخيص
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isExpired
                        ? AppColors.error.withValues(alpha: 0.4)
                        : AppColors.cardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isExpired
                            ? AppColors.error.withValues(alpha: 0.15)
                            : AppColors.goldPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isExpired
                            ? Icons.warning_rounded
                            : Icons.calendar_month_rounded,
                        color: isExpired ? AppColors.error : AppColors.goldPrimary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'صلاحية ترخيص المركبة',
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isExpired
                                ? 'منتهي بتاريخ: $formattedExpiry'
                                : 'سارٍ حتى: $formattedExpiry (متبقي $daysLeft يوم)',
                            style: AppTypography.bodySmall.copyWith(
                              color: isExpired ? AppColors.error : AppColors.textSecondary,
                              fontWeight: isExpired ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // البيانات الفنية والمواصفات
              Text(
                'البيانات الفنية للمركبة',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.goldPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('الماركة والموديل', '${vehicle.make} - ${vehicle.model}'),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildDetailRow('سنة الصنع', 'سارية ومسجلة'),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildDetailRow('فئة الاستخدام', 'مركبة ملاكي / خصوصي'),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildDetailRow('لون المركبة', vehicle.color),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildDetailRow('رقم الشاسيه (Chassis)', vehicle.chassisNumber, isMonospace: true),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildDetailRow('رقم المحرك (Engine)', vehicle.chassisNumber, isMonospace: true),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // مستندات المركبة الرسمية
              Text(
                'الوثائق والتراخيص المرفقة',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.goldPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildDocCard(
                      context,
                      title: 'بطاقة الترخيص',
                      subtitle: 'شهادة البحث',
                      icon: Icons.assignment_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDocCard(
                      context,
                      title: 'رخصة القيادة',
                      subtitle: 'رخصة المالك',
                      icon: Icons.badge_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // أزرار الإجراءات
              CustomButton(
                text: 'استعلام عن مخالفات هذه المركبة',
                icon: Icons.search_rounded,
                isOutlined: true,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ViolationsListScreen(filterPlate: vehicle.plateNumber),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              CustomButton(
                text: 'طلب تجديد الترخيص إلكترونياً',
                icon: Icons.refresh_rounded,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم توجيه طلب التجديد لقسم الفحص الآلي بشرطة المرور'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isMonospace = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: isMonospace
                ? const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: AppColors.goldPrimary,
                    fontWeight: FontWeight.bold,
                  )
                : AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: AppColors.goldPrimary, width: 1.2),
            ),
            title: Text(title, style: AppTypography.titleSmall),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 48, color: AppColors.goldPrimary),
                        const SizedBox(height: 8),
                        Text(
                          'المستند موثق إلكترونياً ✅',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إغلاق', style: TextStyle(color: AppColors.goldPrimary)),
              ),
            ],
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.goldPrimary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.goldPrimary, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTypography.titleSmall.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
