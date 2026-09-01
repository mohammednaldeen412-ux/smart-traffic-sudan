import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/sudan_locations.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/vehicle_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  final _colorController = TextEditingController();
  final _chassisController = TextEditingController();

  File? _certificateImage;
  bool _isLoading = false;
  String _selectedStateCode = 'ن أ'; // افتراضي: النيل الأبيض

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    _chassisController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _certificateImage = File(pickedFile.path));
    }
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final user = context.read<AuthService>().currentUser;
    final db = FirebaseFirestore.instance;
    final plate = _plateController.text.trim();

    try {
      // 1. التحقق من عدم تكرار رقم اللوحة
      final query = await db
          .collection('vehicles')
          .where('plateNumber', isEqualTo: plate)
          .get();
      if (query.docs.isNotEmpty) {
        throw Exception('رقم اللوحة هذا مسجل مسبقاً في النظام!');
      }

      // 2. استخدام placeholder بدل Firebase Storage (مؤقتاً)
      // الصورة تظهر محلياً على الشاشة ولكن يُحفظ placeholder في قاعدة البيانات
      const String imageUrl =
          'https://placehold.co/400x300/1a2942/d4af37?text=شهادة+البحث';

      // 3. حفظ بيانات المركبة في Firestore
      final docId = db.collection('vehicles').doc().id;
      final vehicle = VehicleModel(
        id: docId,
        userId: user!.id,
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        plateNumber: plate,
        plateStateCode: _selectedStateCode,
        color: _colorController.text.trim(),
        chassisNumber: _chassisController.text.trim(),
        // نستخدم الرابط الحقيقي إذا نجح الرفع، أو الـ placeholder إذا فشل أو لم يرفع
        certificateImageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await db.collection('vehicles').doc(docId).set(vehicle.toJson());

      messenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('تمت إضافة المركبة بنجاح وهي قيد المراجعة'),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );
      nav.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'إضافة مركبة جديدة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── بيانات المركبة ──
              Container(
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
                      children: [
                        const Icon(Icons.directions_car_rounded,
                            color: AppColors.goldPrimary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'معلومات المركبة الأساسية',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.goldPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _makeController,
                      label: 'الشركة المصنعة',
                      hint: 'مثال: تويوتا',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'هذا الحقل مطلوب' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _modelController,
                      label: 'الموديل',
                      hint: 'مثال: كورولا',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'هذا الحقل مطلوب' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _plateController,
                      label: 'رقم اللوحة',
                      hint: 'مثال: خ 5 1234',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'هذا الحقل مطلوب' : null,
                    ),
                    const SizedBox(height: 12),
                    // ── اختيار ولاية الترخيص ──
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ولاية الترخيص',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedStateCode,
                              isExpanded: true,
                              dropdownColor: AppColors.card,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.goldPrimary),
                              items: SudanLocations.allStates.map((state) {
                                return DropdownMenuItem<String>(
                                  value: state['code']!,
                                  child: Text(
                                    '${state['name']} (${state['code']})',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedStateCode = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _colorController,
                      label: 'اللون',
                      hint: 'مثال: أبيض',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'هذا الحقل مطلوب' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _chassisController,
                      label: 'رقم الشاسي',
                      hint: 'رقم هيكل المركبة',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'هذا الحقل مطلوب' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── قسم الصورة (اختياري) ──
              Container(
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
                      children: [
                        const Icon(Icons.file_copy_rounded,
                            color: AppColors.goldPrimary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'صورة شهادة البحث (اختيارية)',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.goldPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'اختياري',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.info,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'يمكنك إضافة صورة الشهادة الآن أو لاحقاً من تفاصيل المركبة',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _certificateImage != null
                                ? AppColors.success
                                : AppColors.cardBorder,
                            width: _certificateImage != null ? 2 : 1,
                          ),
                          image: _certificateImage != null
                              ? DecorationImage(
                                  image: FileImage(_certificateImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _certificateImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_rounded,
                                    size: 44,
                                    color: AppColors.goldPrimary
                                        .withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'اضغط لاختيار صورة شهادة البحث',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'من المعرض أو الكاميرا',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textMuted,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              )
                            : Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _certificateImage = null),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.error,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    if (_certificateImage != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'تم اختيار الصورة بنجاح',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── تنبيه مؤقت ──
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.info, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'سيتم مراجعة بيانات المركبة من قِبل الإدارة خلال 24 ساعة. يمكن رفع المستندات لاحقاً.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.info,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              CustomButton(
                text: 'حفظ وإضافة المركبة',
                isLoading: _isLoading,
                onPressed: _saveVehicle,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
