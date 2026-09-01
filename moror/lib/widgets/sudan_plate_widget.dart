import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/plate_formatter.dart';

/// ويدجت لمحاكاة تصميم لوحة المركبات السودانية الرسمية بتفاصيل دقيقة
class SudanPlateWidget extends StatelessWidget {
  final String plateNumber; // e.g. "48291"
  final String stateCode; // e.g. "خ", "ب", "ج"
  final String categoryCode; // e.g. "5" (ملاكي), "2" (تجاري)
  final bool isCompact;

  const SudanPlateWidget({
    super.key,
    required this.plateNumber,
    this.stateCode = 'خ',
    this.categoryCode = '5',
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final stateName = PlateFormatter.getStateName(stateCode);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F141C),
        borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
        border: Border.all(
          color: AppColors.goldPrimary,
          width: isCompact ? 1.5 : 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withValues(alpha: 0.18),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // علم / اسم السودان والولاية
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 5 : 8,
              vertical: isCompact ? 3 : 5,
            ),
            decoration: BoxDecoration(
              color: AppColors.goldPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.goldPrimary.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'السودان',
                  style: TextStyle(
                    fontSize: isCompact ? 8 : 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldPrimary,
                  ),
                ),
                Text(
                  stateName,
                  style: TextStyle(
                    fontSize: isCompact ? 8 : 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isCompact ? 8 : 12),

          // رمز الولاية والفئة
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 6 : 8,
              vertical: isCompact ? 2 : 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2638),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$stateCode $categoryCode',
              style: TextStyle(
                fontSize: isCompact ? 12 : 16,
                fontWeight: FontWeight.w900,
                color: AppColors.goldPrimary,
                letterSpacing: 1,
              ),
            ),
          ),

          SizedBox(width: isCompact ? 8 : 12),

          // رقم اللوحة العريض
          Text(
            plateNumber,
            style: AppTypography.plateText.copyWith(
              fontSize: isCompact ? 16 : 22,
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
            ),
          ),
        ],
      ),
    );
  }
}
