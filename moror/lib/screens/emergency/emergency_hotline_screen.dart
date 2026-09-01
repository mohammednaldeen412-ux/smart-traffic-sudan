import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EmergencyHotlineScreen extends StatefulWidget {
  const EmergencyHotlineScreen({super.key});

  @override
  State<EmergencyHotlineScreen> createState() => _EmergencyHotlineScreenState();
}

class _EmergencyHotlineScreenState extends State<EmergencyHotlineScreen> {
  final _descriptionController = TextEditingController();
  String _selectedRoad = 'طريق الخرطوم - بورتسودان القومي';
  bool _isSubmitting = false;

  final List<String> _highways = [
    'طريق الخرطوم - بورتسودان القومي',
    'طريق التحدي (الخرطوم - عطبرة - هيا)',
    'طريق شريان الشمال (أم درمان - دنقلا)',
    'طريق الصادرات (أم درمان - بارا - الأبيض)',
    'طريق الخرطوم - ود مدني السريع',
    'طريق القضارف - كسلا - بورتسودان',
    'طريق كوستي - الأبيض القومي',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.goldPrimary),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
            SizedBox(width: 8),
            Text('تم استلام البلاغ'),
          ],
        ),
        content: const Text(
          'تم إرسال إحداثيات موقعك وبلاغك بنجاح إلى أقرب دورية نجدة على الطريق السريع.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('حسناً', style: TextStyle(color: AppColors.goldPrimary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('طوارئ ونجدة المرور السريع 777'),
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
              // بطاقة الطوارئ الرئيسية
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B0D0D), Color(0xFF1E0A0A), Color(0xFF141A29)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.error,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.error, width: 2),
                      ),
                      child: const Icon(
                        Icons.phone_in_talk_rounded,
                        color: AppColors.error,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'خط النجدة الموحد للإدارة العامة للمرور',
                      style: AppTypography.titleSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '777',
                      style: AppTypography.displayLarge.copyWith(
                        color: AppColors.goldPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 44,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('جاري الاتصال المباشر بغرفة طوارئ المرور السريع 777...'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      },
                      icon: const Icon(Icons.call_rounded, color: Colors.white),
                      label: const Text('اتصال فوري بالعمليات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // جهات الطوارئ الأخرى
              Text(
                'أرقام الطوارئ القومية',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.goldPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildEmergencyTile(
                      title: 'الإسعاف المركزي',
                      number: '998',
                      icon: Icons.medical_services_rounded,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEmergencyTile(
                      title: 'الدفاع المدني',
                      number: '999',
                      icon: Icons.local_fire_department_rounded,
                      color: const Color(0xFFF97316),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // قسم بلاغ عن حادث أو عائق على الطريق
              Text(
                'إرسال إشارة استغاثة أو بلاغ حادث (SOS)',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.goldPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

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
                    Text(
                      'حدد الطريق القومي أو الشارع',
                      style: AppTypography.titleSmall.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRoad,
                          dropdownColor: AppColors.cardElevated,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.goldPrimary),
                          items: _highways.map((road) {
                            return DropdownMenuItem<String>(
                              value: road,
                              child: Text(road, style: const TextStyle(fontSize: 12, color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedRoad = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'تفاصيل البلاغ / نوع الطارئ',
                      hint: 'مثال: تعطل مركبة، حادث تصادم، عائق على الطريق عند الكيلو 45...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 14),
                    CustomButton(
                      text: 'إرسال البلاغ مع الموقع الجغرافي الفوري',
                      icon: Icons.send_rounded,
                      isLoading: _isSubmitting,
                      onPressed: _submitReport,
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

  Widget _buildEmergencyTile({
    required String title,
    required String number,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                number,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
