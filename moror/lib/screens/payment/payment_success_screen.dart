import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/payment_receipt_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/success_animation.dart';
import '../dashboard/main_navigation_wrapper.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final PaymentReceiptModel receipt;

  const PaymentSuccessScreen({
    super.key,
    required this.receipt,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd - hh:mm a', 'ar');
    final formattedDate = dateFormat.format(receipt.paymentDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // علامة الصح الكبيرة المتحركة ديناميكياً
              const SuccessCheckmarkAnimation(size: 96),

              const SizedBox(height: 24),

              Text(
                'تم سداد المخالفة بنجاح!',
                style: AppTypography.displayMedium.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 6),

              Text(
                'تم تسجيل السداد فـورياً في السجل السيادي للإدارة العامة للمرور',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // بطاقة الإيصال الرقمي الفاخر
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: 0.4),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldPrimary.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // رأس الإيصال الرسمي
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.verified_user_rounded,
                                color: AppColors.goldPrimary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'إيصال سداد إلكتروني معتمد',
                                style: AppTypography.titleSmall.copyWith(
                                  color: AppColors.goldPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'جمهورية السودان',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // المبلغ المسدد
                          Text(
                            CurrencyFormatter.formatSDG(receipt.amount),
                            style: AppTypography.displayMedium.copyWith(
                              color: AppColors.goldPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'الحالة: ${receipt.status}',
                              style: const TextStyle(
                                color: AppColors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),
                          const Divider(height: 1, color: AppColors.divider),
                          const SizedBox(height: 14),

                          // تفاصيل الإيصال
                          _buildReceiptItem('رقم المعاملة (Txn ID):', receipt.transactionId, isMonospace: true),
                          _buildReceiptItem('رقم المخالفة:', receipt.violationId, isMonospace: true),
                          _buildReceiptItem('لوحة المركبة:', receipt.plateNumber),
                          _buildReceiptItem('نوع المخالفة:', receipt.violationType),
                          _buildReceiptItem('اسم المسدد:', receipt.payerName),
                          _buildReceiptItem('الرقم الوطني:', receipt.payerNationalId, isMonospace: true),
                          _buildReceiptItem('وسيلة الدفع:', receipt.paymentMethod),
                          _buildReceiptItem('تاريخ ووقت المعاملة:', formattedDate),
                          _buildReceiptItem('رمز التحقق الأمني:', receipt.verificationHash, isMonospace: true),

                          const SizedBox(height: 16),
                          const Divider(height: 1, color: AppColors.divider),
                          const SizedBox(height: 16),

                          // كود QR للتحقق من الإيصال
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: QrImageView(
                              data: receipt.qrData,
                              version: QrVersions.auto,
                              size: 130.0,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'امسح الرمز للتأكد من صحة الإيصال السيادي',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // أزرار التحميل والمشاركة
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'حفظ الإيصال كـ PDF',
                      icon: Icons.download_rounded,
                      isOutlined: true,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم حفظ إيصال المعاملة ${receipt.transactionId} بصيغة PDF في مجلد التنزيلات',
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'مشاركة الإيصال',
                      icon: Icons.share_rounded,
                      isOutlined: true,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم نسخ رابط التوثيق الرسمي للإيصال للمشاركة'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // زر العودة للرئيسية
              CustomButton(
                text: 'العودة للرئيسية',
                icon: Icons.home_rounded,
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationWrapper(),
                    ),
                    (route) => false,
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptItem(String label, String value, {bool isMonospace = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: isMonospace
                  ? const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: AppColors.goldPrimary,
                      fontWeight: FontWeight.bold,
                    )
                  : AppTypography.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
