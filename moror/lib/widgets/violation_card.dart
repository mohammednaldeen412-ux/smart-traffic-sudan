import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/currency_formatter.dart';
import '../models/violation_model.dart';

class ViolationCard extends StatelessWidget {
  final ViolationModel violation;
  final VoidCallback? onTap;
  final VoidCallback? onPayTap;

  const ViolationCard({
    super.key,
    required this.violation,
    this.onTap,
    this.onPayTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd - hh:mm a', 'ar');
    final formattedDate = dateFormat.format(violation.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: violation.isPaid
              ? AppColors.cardBorder
              : AppColors.error.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (violation.isPaid ? Colors.black : AppColors.error)
                .withValues(alpha: 0.12),
            blurRadius: 16,
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
                // الصف العلوي: كبسولة اللوحة الذهبية + حالة السداد
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // كبسولة ذهبية للوحة المركبة
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.goldPrimary,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldPrimary.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.pin_outlined,
                            size: 14,
                            color: AppColors.goldPrimary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            violation.fullPlateDisplay,
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.goldPrimary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // شارة السداد
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: violation.isPaid
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: violation.isPaid ? AppColors.success : AppColors.error,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            violation.isPaid
                                ? Icons.check_circle_rounded
                                : Icons.error_outline_rounded,
                            size: 14,
                            color: violation.isPaid ? AppColors.success : AppColors.error,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            violation.isPaid ? 'مسددة' : 'غير مسددة',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: violation.isPaid ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // نوع المخالفة والمبلغ
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            violation.violationType,
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  violation.locationName,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.formatSDG(violation.amount),
                          style: AppTypography.titleMedium.copyWith(
                            color: violation.isPaid
                                ? AppColors.textSecondary
                                : AppColors.goldPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'قيمة الغرامة',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 10),

                // الصف السفلي: التاريخ وزر الإجراء
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          formattedDate,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    if (!violation.isPaid && onPayTap != null)
                      InkWell(
                        onTap: onPayTap,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.payment_rounded,
                                size: 14,
                                color: AppColors.background,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'سداد الآن',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.background,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Text(
                            'التفاصيل والـ QR',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.goldPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.qr_code_2_rounded,
                            size: 14,
                            color: AppColors.goldPrimary,
                          ),
                        ],
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
}
