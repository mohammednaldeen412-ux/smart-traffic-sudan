import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/vehicle_model.dart';
import 'sudan_plate_widget.dart';

class VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback? onTap;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExpired = vehicle.isLicenseExpired;
    final int daysLeft = vehicle.daysUntilExpiry;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: vehicle.isVerified
              ? AppColors.cardBorder
              : AppColors.warning.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الصف العلوي: اللوحة وحالة التوثيق
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SudanPlateWidget(
                      plateNumber: vehicle.plateNumber,
                      stateCode: vehicle.plateStateCode,
                      categoryCode: vehicle.plateCategoryCode,
                      isCompact: true,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: vehicle.isVerified
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: vehicle.isVerified
                              ? AppColors.success
                              : AppColors.warning,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            vehicle.isVerified
                                ? Icons.verified_rounded
                                : Icons.pending_actions_rounded,
                            size: 14,
                            color: vehicle.isVerified
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            vehicle.isVerified ? 'موثق رسمياً' : 'قيد المراجعة',
                            style: TextStyle(
                              fontSize: 11,
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
                const SizedBox(height: 14),

                // بيانات الماركة والموديل
                Row(
                  children: [
                    const Icon(
                      Icons.directions_car_filled_rounded,
                      size: 20,
                      color: AppColors.goldPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${vehicle.make} - ${vehicle.model}',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // تفاصيل إضافية
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildInfoChip(Icons.palette_outlined, vehicle.color),
                    _buildInfoChip(
                        Icons.tag_rounded, 'شاسيه: ${vehicle.chassisNumber.length > 8 ? "${vehicle.chassisNumber.substring(0, 8)}..." : vehicle.chassisNumber}'),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: 12),

                // شريط انتهاء الترخيص
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isExpired
                              ? Icons.error_rounded
                              : (daysLeft <= 30
                                  ? Icons.warning_amber_rounded
                                  : Icons.check_circle_outline_rounded),
                          size: 16,
                          color: isExpired
                              ? AppColors.error
                              : (daysLeft <= 30
                                  ? AppColors.warning
                                  : AppColors.success),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isExpired
                              ? 'الترخيص منتهي الصلاحية!'
                              : (daysLeft <= 30
                                  ? 'ينتهي الترخيص خلال $daysLeft يوم'
                                  : 'الترخيص سارٍ ($daysLeft يوم)'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isExpired
                                ? AppColors.error
                                : (daysLeft <= 30
                                    ? AppColors.warning
                                    : AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.goldPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
