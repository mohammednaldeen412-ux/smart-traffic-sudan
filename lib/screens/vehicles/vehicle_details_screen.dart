import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/vehicle_model.dart';
import '../../widgets/app_background.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/sudan_plate_widget.dart';
import '../violations/violations_list_screen.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final VehicleModel vehicle;

  const VehicleDetailsScreen({
    super.key,
    required this.vehicle,
  });

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.vehicle;
    final c = GlassColors.of(context);
    final dateFormat = DateFormat('yyyy/MM/dd', context.isArabic ? 'ar' : 'en');
    final formattedExpiry = vehicle.licenseExpiryDate != null
        ? dateFormat.format(vehicle.licenseExpiryDate!)
        : context.tr('active');
    final isExpired = vehicle.isLicenseExpired;
    final daysLeft = vehicle.daysUntilExpiry;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          '${vehicle.make} - ${vehicle.model}',
          style: TextStyle(color: c.text, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: c.text),
      ),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        role: AppRole.citizen,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // بطاقة الرأس واللوحة السودانية
                GlassCard(
                  blur: 16,
                  opacity: c.isDark ? 0.2 : 0.45,
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
                                      ? context.tr('vehicle_verified_tag')
                                      : context.tr('vehicle_pending_tag'),
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
                GlassCard(
                  blur: 12,
                  opacity: c.isDark ? 0.15 : 0.35,
                  tintColor: isExpired ? AppColors.error : AppColors.success,
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
                              context.tr('vehicle_license_validity'),
                              style: AppTypography.titleSmall.copyWith(
                                color: c.text,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isExpired
                                  ? '${context.tr('expired_on')} $formattedExpiry'
                                  : '${context.tr('valid_until')} $formattedExpiry (${context.tr('remaining')} $daysLeft ${context.tr('days')})',
                              style: AppTypography.bodySmall.copyWith(
                                color: isExpired ? AppColors.error : c.textMuted,
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
                  context.tr('vehicle_specs_title'),
                  style: AppTypography.titleMedium.copyWith(
                    color: c.isDark ? AppColors.goldPrimary : AppColors.goldDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                GlassCard(
                  blur: 12,
                  opacity: c.isDark ? 0.12 : 0.35,
                  child: Column(
                    children: [
                      _buildDetailRow(context, context.tr('make_and_model'), '${vehicle.make} - ${vehicle.model}'),
                      Divider(height: 1, color: c.text.withValues(alpha: 0.1)),
                      _buildDetailRow(context, context.tr('model_year_label'), context.tr('registered_and_valid')),
                      Divider(height: 1, color: c.text.withValues(alpha: 0.1)),
                      _buildDetailRow(context, context.tr('usage_category'), context.tr('private_vehicle')),
                      Divider(height: 1, color: c.text.withValues(alpha: 0.1)),
                      _buildDetailRow(context, context.tr('vehicle_color'), vehicle.color),
                      Divider(height: 1, color: c.text.withValues(alpha: 0.1)),
                      _buildDetailRow(context, context.tr('chassis_num_label'), vehicle.chassisNumber, isMonospace: true),
                      Divider(height: 1, color: c.text.withValues(alpha: 0.1)),
                      _buildDetailRow(context, context.tr('engine_num_label'), vehicle.chassisNumber, isMonospace: true),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // مستندات المركبة الرسمية
                Text(
                  context.tr('vehicle_documents_title'),
                  style: AppTypography.titleMedium.copyWith(
                    color: c.isDark ? AppColors.goldPrimary : AppColors.goldDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildDocCard(
                        context,
                        title: context.tr('registration_card'),
                        subtitle: context.tr('search_certificate'),
                        icon: Icons.assignment_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // أزرار الإجراءات
                CustomButton(
                  text: context.tr('check_vehicle_violations'),
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
                  text: context.tr('request_license_renewal'),
                  icon: Icons.refresh_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr('renewal_sent_msg')),
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
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isMonospace = false}) {
    final c = GlassColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: c.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: isMonospace
                ? TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: c.isDark ? AppColors.goldPrimary : AppColors.goldDark,
                    fontWeight: FontWeight.bold,
                  )
                : AppTypography.bodyLarge.copyWith(
                    color: c.text,
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
    final c = GlassColors.of(context);
    return GlassCard(
      blur: 12,
      opacity: c.isDark ? 0.12 : 0.35,
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            backgroundColor: c.isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: AppColors.goldPrimary, width: 1.2),
            ),
            title: Text(title, style: AppTypography.titleSmall.copyWith(color: c.text)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: c.isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.text.withValues(alpha: 0.1)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 48, color: AppColors.goldPrimary),
                        const SizedBox(height: 8),
                        Text(
                          '✅ ${context.tr('verified')}',
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
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: Text(context.tr('ok_btn'), style: const TextStyle(color: AppColors.goldPrimary)),
              ),
            ],
          ),
        );
      },
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
            style: AppTypography.titleSmall.copyWith(
              color: c.text,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(color: c.textMuted, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
