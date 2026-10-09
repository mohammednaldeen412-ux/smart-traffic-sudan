import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/services/image_upload_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/violation_model.dart';
import '../../widgets/app_background.dart';
import '../../widgets/glass_card.dart';

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
  final _descriptionController = TextEditingController();
  File? _selectedImage;
  bool _isSubmitting = false;

  Future<void> _submitDispute() async {
    final text = _descriptionController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.isArabic ? 'الرجاء كتابة سبب الاعتراض' : 'Please enter the reason for dispute'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      // حفظ الاعتراض في قاعدة البيانات ليلتقطه السيرفر
      await FirebaseFirestore.instance.collection('objections').add({
        'userId': user?.uid ?? 'unknown',
        'violationId': widget.violation.id,
        'plateNumber': widget.violation.fullPlateDisplay,
        'reason': text,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.goldPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64),
              const SizedBox(height: 16),
              Text(
                context.isArabic ? 'تم استلام اعتراضك' : 'Dispute Received',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                context.isArabic
                    ? 'المخالفة الآن "قيد المراجعة" ولن يتم احتساب غرامات تأخير عليها حتى يتم الرد عليك من الإدارة.'
                    : 'The violation is now "Under Review". No late penalties will apply until administration responds.',
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary),
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    context.tr('ok_btn'),
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.tr('error_prefix')} $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = GlassColors.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.isArabic ? 'تقديم اعتراض' : 'Submit Dispute',
          style: TextStyle(color: c.text, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: c.text),
      ),
      body: AppBackground(
        role: AppRole.citizen,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassCard(
                  blur: 15,
                  opacity: c.isDark ? 0.2 : 0.45,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('violation_details_title'),
                        style: AppTypography.titleSmall.copyWith(
                          color: c.isDark ? AppColors.goldPrimary : AppColors.goldDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.violation.violationType,
                              style: TextStyle(color: c.text, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatSDG(widget.violation.amount),
                            style: TextStyle(
                              color: c.isDark ? AppColors.goldPrimary : AppColors.goldDark,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${context.tr('vehicle_plate_label')} ${widget.violation.fullPlateDisplay}',
                        style: TextStyle(color: c.textMuted),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  context.isArabic ? 'سبب الاعتراض' : 'Dispute Reason',
                  style: TextStyle(color: c.text, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  style: TextStyle(color: c.text),
                  decoration: InputDecoration(
                    hintText: context.isArabic ? 'اكتب مبررات الاعتراض هنا...' : 'Write dispute justifications here...',
                    hintStyle: TextStyle(color: c.textMuted),
                    filled: true,
                    fillColor: c.isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: c.text.withValues(alpha: 0.15)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: c.text.withValues(alpha: 0.15)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.5),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
                    if (pickedFile != null) {
                      setState(() {
                        _selectedImage = File(pickedFile.path);
                      });
                    }
                  },
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: Text(_selectedImage == null ? 'إرفاق إثبات / صورة' : 'تم اختيار الإثبات ✔'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.text,
                    side: BorderSide(color: c.text.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: _isSubmitting ? null : _submitDispute,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(
                            context.isArabic ? 'إرسال طلب مراجعة للإدارة' : 'Submit Review Request',
                            style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
