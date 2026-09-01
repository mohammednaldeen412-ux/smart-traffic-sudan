import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/violation_model.dart';
import '../../widgets/custom_button.dart';
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
    final dateFormat = DateFormat('yyyy/MM/dd - hh:mm a', 'ar');
    final formattedDate = dateFormat.format(violation.date);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تفاصيل المخالفة والتحقق'),
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
              // رأس المخالفة: الكبسولة الذهبية والمبلغ
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.sovereignHeaderGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: violation.isPaid
                        ? AppColors.success.withValues(alpha: 0.4)
                        : AppColors.error.withValues(alpha: 0.5),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (violation.isPaid ? AppColors.success : AppColors.error)
                          .withValues(alpha: 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
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
                        'لوحة المركبة: ${violation.fullPlateDisplay}',
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
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      CurrencyFormatter.formatSDG(violation.amount),
                      style: AppTypography.displayMedium.copyWith(
                        color: AppColors.goldPrimary,
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
                        violation.isPaid ? '✅ تم سداد الغرامة' : '🚨 مستحقة السداد الفوري',
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
                'موقع رصد المخالفة جغرافياً',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.goldPrimary,
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
                'بيانات الرصد والضبط المروري',
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
                    _buildInfoRow('رقم المخالفة السيادي', violation.id, isMonospace: true),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildInfoRow('التاريخ والوقت', formattedDate),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildInfoRow('جهة الضبط', violation.officerName),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildInfoRow('رقم الدورية / الرادار', violation.officerBadge, isMonospace: true),
                    if (violation.isPaid && violation.receiptId != null) ...[
                      const Divider(height: 1, color: AppColors.divider),
                      _buildInfoRow('رقم إيصال السداد', violation.receiptId!, isMonospace: true),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // كود التحقق الرقمي الرسمي (Sovereign QR Code)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.goldPrimary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldPrimary.withValues(alpha: 0.1),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.qr_code_scanner_rounded, color: AppColors.goldPrimary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'كود التحقق الأمني للجهات الرسمية',
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.goldPrimary,
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
                        'امسح الكود عبر جهاز شرطي المرور المعتمد للتحقق الفوري',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
                                'طلب الاعتراض: ${violation.disputeStatus ?? "قيد المراجعة الفنية"}',
                                style: AppTypography.titleSmall.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'الطلب قيد الفحص لدى اللجنة الفنية لشرطة المرور',
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
                  text: 'الانتقال لبوابة الدفع الإلكتروني',
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
                    text: 'تقديم اعتراض رسمي على المخالفة',
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
                              'تمت تسوية هذه المخالفة بالكامل',
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'طريقة الدفع: ${violation.paymentMethod ?? "تطبيق بنكك"}',
                              style: AppTypography.bodySmall,
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
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isMonospace = false}) {
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
          Flexible(
            child: Text(
              value,
              style: isMonospace
                  ? const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: AppColors.goldPrimary,
                      fontWeight: FontWeight.bold,
                    )
                  : AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
