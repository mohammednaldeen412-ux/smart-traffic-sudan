import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/traffic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/violation_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class DisputeViolationScreen extends StatefulWidget {
  final ViolationModel violation;

  const DisputeViolationScreen({
    super.key,
    required this.violation,
  });

  @override
  State<DisputeViolationScreen> createState() => _DisputeViolationScreenState();
}

class _DisputeViolationScreenState extends State<DisputeViolationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  String _selectedReason = 'خطأ في رصد اللوحة (المركبة لم تكن في الموقع)';
  bool _hasAttachedEvidence = true;
  bool _agreedToTerms = true;

  final List<String> _disputeReasons = [
    'خطأ في رصد اللوحة (المركبة لم تكن في الموقع)',
    'تم بيع ونقل ملكية المركبة قبل تاريخ المخالفة',
    'حالة طوارئ وإسعاف إنساني قاهرة',
    'عطل فني في الإشارة أو عدم وضوح اللوحات الإرشادية',
    'سبب آخر مدعوم بالإثباتات الرسمية',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitDispute() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى الإقرار بصحة أسباب ومستندات الاعتراض'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final auth = context.read<AuthService>();
    final traffic = context.read<TrafficService>();

    final dispute = await traffic.submitDispute(
      violationId: widget.violation.id,
      userId: auth.currentUser?.id ?? 'usr_sudan_001',
      plateNumber: widget.violation.fullPlateDisplay,
      reasonCategory: _selectedReason,
      description: _descriptionController.text.trim(),
      evidenceAttachment: _hasAttachedEvidence ? 'evidence_attachment.jpg' : null,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.goldPrimary, width: 1.5),
        ),
        title: const Center(
          child: Icon(
            Icons.task_alt_rounded,
            color: AppColors.success,
            size: 54,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تم استلام طلب الاعتراض بنجاح!',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'رقم طلب الاعتراض السيادي:',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.goldPrimary),
              ),
              child: Text(
                dispute.id,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: AppColors.goldPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'سيتم فحص التسجيلات ومراجعة كاميرات المراقبة من قِبل اللجنة الفنية لشرطة المرور والرد خلال 48 ساعة.',
              style: AppTypography.bodySmall.copyWith(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          CustomButton(
            text: 'حسناً، العودة للتفاصيل',
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final traffic = context.watch<TrafficService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تقديم اعتراض رسمي على المخالفة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ملخص المخالفة المعترض عليها
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'بيانات المخالفة المرصودة',
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.goldPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatSDG(widget.violation.amount),
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.goldPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.violation.violationType,
                        style: AppTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'اللوحة: ${widget.violation.fullPlateDisplay}  •  الموقع: ${widget.violation.locationName}',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'سبب الاعتراض القانوني',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.goldPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // قائمة أسباب الاعتراض
                ..._disputeReasons.map((reason) {
                  final isSelected = _selectedReason == reason;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.cardElevated : AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.goldPrimary : AppColors.cardBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            _selectedReason = reason;
                          });
                        },
                        leading: Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? AppColors.goldPrimary : AppColors.textMuted,
                          size: 20,
                        ),
                        title: Text(
                          reason,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // شرح الاعتراض
                CustomTextField(
                  controller: _descriptionController,
                  label: 'شرح وتوضيح حيثيات الاعتراض بالتفصيل',
                  hint: 'اذكر التفاصيل الدقيقة ومبررات إسقاط المخالفة...',
                  maxLines: 4,
                  validator: (val) {
                    if (val == null || val.trim().length < 10) {
                      return 'يرجى تقديم شرح وافٍ لا يقل عن 10 أحرف';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // إرفاق الأدلة والصور
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _hasAttachedEvidence
                          ? AppColors.success.withValues(alpha: 0.5)
                          : AppColors.cardBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_rounded,
                          color: AppColors.goldPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إرفاق صور أو مستندات ثبوتية',
                              style: AppTypography.titleSmall.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _hasAttachedEvidence
                                  ? '✅ تم إرفاق صورة/وثيقة إثبات'
                                  : 'اضغط للرفع من الكاميرا أو المعرض',
                              style: AppTypography.bodySmall.copyWith(
                                color: _hasAttachedEvidence ? AppColors.success : AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _hasAttachedEvidence ? Icons.check_circle : Icons.upload_file_rounded,
                          color: _hasAttachedEvidence ? AppColors.success : AppColors.goldPrimary,
                        ),
                        onPressed: () {
                          setState(() {
                            _hasAttachedEvidence = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم إرفاق مستند الإثبات بنجاح')),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // إقرار بصحة البيانات
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreedToTerms,
                        activeColor: AppColors.goldPrimary,
                        checkColor: AppColors.background,
                        side: const BorderSide(color: AppColors.cardBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _agreedToTerms = val ?? true;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'أقر بصحة البيانات المقدمة وأتحمل المسؤولية القانونية في حال تقديم معلومات مضللة',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // زر إرسال الاعتراض
                CustomButton(
                  text: 'إرسال طلب الاعتراض للجنة الفنية',
                  icon: Icons.gavel_rounded,
                  isLoading: traffic.isLoading,
                  onPressed: _submitDispute,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
