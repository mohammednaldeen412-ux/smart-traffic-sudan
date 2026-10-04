import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/violation_model.dart';
import '../../widgets/app_background.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/interactive_map_widget.dart';
import '../payment/payment_gateway_screen.dart';
import 'dispute_violation_screen.dart';

class ViolationDetailsScreen extends StatelessWidget {
  final ViolationModel violation;

  const ViolationDetailsScreen({
    super.key,
    required this.violation,
  });

  @override
  Widget build(BuildContext context) {
    final c = GlassColors.of(context);
    final dateFormat = DateFormat('yyyy/MM/dd - hh:mm a', context.isArabic ? 'ar' : 'en');
    final formattedDate = dateFormat.format(violation.date);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          context.tr('violation_details_title'),
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
                // رأس المخالفة: الكبسولة الذهبية والمبلغ
                GlassCard(
                  blur: 16,
                  opacity: c.isDark ? 0.2 : 0.45,
                  tintColor: violation.isPaid ? AppColors.success : AppColors.error,
                  child: Column(
                    children: [
                      // كبسولة ذهبية للوحة
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColors.goldPrimary, width: 1.5),
                        ),
                        child: Text(
                          '${context.tr('vehicle_plate_label')} ${violation.fullPlateDisplay}',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.goldPrimary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        violation.violationType,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: c.text,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        CurrencyFormatter.formatSDG(violation.amount),
                        style: AppTypography.displayMedium.copyWith(
                          color: c.isDark ? AppColors.goldPrimary : AppColors.goldDark,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: violation.isPaid
                              ? AppColors.success.withValues(alpha: 0.2)
                              : AppColors.error.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: violation.isPaid ? AppColors.success : AppColors.error,
                          ),
                        ),
                        child: Text(
                          violation.isPaid
                              ? context.tr('fine_paid_status')
                              : context.tr('fine_due_status'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: violation.isPaid ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // خريطة موقع المخالفة التفاعلية
                Text(
                  context.tr('violation_geo_location'),
                  style: AppTypography.titleMedium.copyWith(
                    color: c.isDark ? AppColors.goldPrimary : AppColors.goldDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                InteractiveMapWidget(
                  locationName: violation.locationName,
                  latitude: violation.latitude,
                  longitude: violation.longitude,
                ),

                const SizedBox(height: 24),

                // بطاقة بيانات الضابط والتوثيق
                Text(
                  context.tr('traffic_enforcement_info'),
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
                      _buildInfoRow(context, context.tr('sovereign_violation_id'), violation.id, isMonospace: true),
                      Divider(height: 1, color: c.text.withValues(alpha: 0.1)),
                      _buildInfoRow(context, context.tr('date_and_time'), formattedDate),
                      Divider(height: 1, color: c.text.withValues(alpha: 0.1)),
                      _buildInfoRow(context, context.tr('enforcement_agency'), violation.officerName),
                      Divider(height: 1, color: c.text.withValues(alpha: 0.1)),
                      _buildInfoRow(context, context.tr('patrol_radar_number'), violation.officerBadge, isMonospace: true),
                      if (violation.isPaid && violation.receiptId != null) ...[
                        Divider(height: 1, color: c.text.withValues(alpha: 0.1)),
                        _buildInfoRow(context, context.tr('payment_receipt_number'), violation.receiptId!, isMonospace: true),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // كود التحقق الرقمي الرسمي (Sovereign QR Code)
                Center(
                  child: GlassCard(
                    blur: 16,
                    opacity: c.isDark ? 0.18 : 0.45,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.qr_code_scanner_rounded, color: AppColors.goldPrimary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                context.tr('security_verification_code'),
                                style: AppTypography.titleSmall.copyWith(
                                  color: c.isDark ? AppColors.goldPrimary : AppColors.goldDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: QrImageView(
                              data: violation.qrPayload,
                              version: QrVersions.auto,
                              size: 170.0,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.tr('scan_code_instruction'),
                            style: AppTypography.bodySmall.copyWith(
                              color: c.textMuted,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // زر الإجراء: سداد الآن أو تقديم اعتراض
                if (!violation.isPaid) ...[
                  if (violation.hasDispute) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.warning),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.pending_actions_rounded, color: AppColors.warning, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${context.tr('dispute_status_title')} ${violation.disputeStatus ?? context.tr('dispute_under_review')}',
                                  style: AppTypography.titleSmall.copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  context.tr('dispute_review_desc'),
                                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  CustomButton(
                    text: context.tr('proceed_to_payment'),
                    icon: Icons.payment_rounded,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PaymentGatewayScreen(violation: violation),
                        ),
                      );
                    },
                  ),
                  if (!violation.hasDispute) ...[
                    const SizedBox(height: 10),
                    CustomButton(
                      text: context.tr('submit_formal_dispute'),
                      icon: Icons.gavel_rounded,
                      isOutlined: true,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DisputeViolationScreen(violation: violation),
                          ),
                        );
                      },
                    ),
                  ],
                ]
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.success),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('violation_fully_settled'),
                                style: AppTypography.titleSmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${context.tr('payment_method_label')} ${violation.paymentMethod ?? "Bankak"}',
                                style: AppTypography.bodySmall.copyWith(color: c.text),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isMonospace = false}) {
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
          Flexible(
            child: Text(
              value,
              style: isMonospace
                  ? TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: c.isDark ? AppColors.goldPrimary : AppColors.goldDark,
                      fontWeight: FontWeight.bold,
                    )
                  : AppTypography.bodyLarge.copyWith(color: c.text, fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
