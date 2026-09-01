import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/sudan_locations.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/traffic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/sudan_plate_widget.dart';

class TicketIssuerScreen extends StatefulWidget {
  final String? prefilledPlate;
  final String? prefilledState;

  const TicketIssuerScreen({
    super.key,
    this.prefilledPlate,
    this.prefilledState,
  });

  @override
  State<TicketIssuerScreen> createState() => _TicketIssuerScreenState();
}

class _TicketIssuerScreenState extends State<TicketIssuerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _plateController;
  String _selectedState = 'خ';

  // قائمة المخالفات المعتمدة وقيمتها
  final List<Map<String, dynamic>> _violationTypes = [
    {'title': 'قطع الإشارة الضوئية الحمراء', 'amount': 50000.0, 'icon': Icons.traffic_rounded},
    {'title': 'تجاوز السرعة القانونية المقررة (رادار)', 'amount': 35000.0, 'icon': Icons.speed_rounded},
    {'title': 'تظليل زجاج المركبة بدون تصريح أمني', 'amount': 30000.0, 'icon': Icons.visibility_off_rounded},
    {'title': 'الوقوف في الممنوع وتعطيل حركة السير', 'amount': 20000.0, 'icon': Icons.local_parking_rounded},
    {'title': 'القيادة برخصة قيادة منتهية أو بدون رخصة', 'amount': 25000.0, 'icon': Icons.badge_outlined},
    {'title': 'استخدام الهاتف المحمول أثناء القيادة', 'amount': 15000.0, 'icon': Icons.phone_android_rounded},
    {'title': 'عدم ارتداء حزام الأمان', 'amount': 15000.0, 'icon': Icons.airline_seat_recline_normal_rounded},
  ];

  late int _selectedViolationIndex;
  String _selectedLocality = SudanLocations.whiteNileLocalities[1];
  final double _latitude = 13.1629;
  final double _longitude = 32.6635;

  @override
  void initState() {
    super.initState();
    _plateController = TextEditingController(text: widget.prefilledPlate ?? '');
    _selectedState = widget.prefilledState ?? 'خ';
    _selectedViolationIndex = 0;
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _issueTicket() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthService>();
    final traffic = context.read<TrafficService>();

    final selectedVio = _violationTypes[_selectedViolationIndex];
    final officer = auth.currentUser;

    try {
      final newTicket = await traffic.issueOfficerTicket(
        plateNumber: _plateController.text.trim(),
        plateStateCode: _selectedState,
        violationType: selectedVio['title'] as String,
        amount: selectedVio['amount'] as double,
        locationName: '$_selectedLocality - تحديد الموقع',
        latitude: _latitude,
        longitude: _longitude,
        officerName: officer?.fullName ?? 'النقيب / طارق عثمان الطيب',
        officerBadge: officer?.officerBadgeNumber ?? 'SD-TRF-8842',
        locality: _selectedLocality,
        city: _selectedLocality,
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
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
              SizedBox(width: 8),
              Expanded(child: Text('تم تحرير المخالفة بنجاح', style: TextStyle(fontSize: 16))),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'رقم الإشعار السيادي:',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 10),
                          ),
                          Text(
                            newTicket.id,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: AppColors.goldPrimary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        newTicket.violationType,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'المبلغ: ${CurrencyFormatter.formatSDG(newTicket.amount)}',
                        style: const TextStyle(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: QrImageView(
                      data: newTicket.qrPayload,
                      version: QrVersions.auto,
                      size: 90.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.cloud_done_rounded, color: AppColors.success, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'تم التزامن السحابي اللحظي وإشعار المواطن فوراً.',
                        style: AppTypography.bodySmall.copyWith(fontSize: 9, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'إغلاق ومتابعة الميدان',
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
              SizedBox(width: 8),
              Expanded(child: Text('خطأ في العملية', style: TextStyle(fontSize: 16))),
            ],
          ),
          content: Text(
            e.toString().contains('permission-denied') 
              ? 'عذراً، لا تمتلك صلاحية كتابة المخالفات حالياً. يرجى التأكد من تسجيل الدخول بحساب ضابط موثق.'
              : e.toString().replaceAll('Exception: ', ''),
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('حسناً، فهمت', style: TextStyle(color: AppColors.goldPrimary)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final traffic = context.watch<TrafficService>();
    final selectedVio = _violationTypes[_selectedViolationIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('محرر المخالفات والضبط الميداني'),
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
                // رأس بيانات اللوحة
                Text(
                  '1. بيانات اللوحة المرصودة',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.goldPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedState,
                            dropdownColor: AppColors.cardElevated,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.goldPrimary),
                            items: SudanLocations.allStates.map((st) {
                              final code = st['code']!;
                              final name = st['name']!;
                              return DropdownMenuItem(
                                value: code,
                                child: Text('ولاية $name ($code)', style: const TextStyle(fontSize: 12, color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedState = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: CustomTextField(
                        controller: _plateController,
                        label: '',
                        hint: 'رقم اللوحة',
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'أدخل رقم اللوحة';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Center(
                  child: SudanPlateWidget(
                    plateNumber: _plateController.text.isEmpty ? '00000' : _plateController.text,
                    stateCode: _selectedState,
                    isCompact: true,
                  ),
                ),

                const SizedBox(height: 24),

                // اختيار نوع المخالفة
                Text(
                  '2. حدد نوع المخالفة المرصودة',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.goldPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                ...List.generate(_violationTypes.length, (index) {
                  final item = _violationTypes[index];
                  final isSelected = _selectedViolationIndex == index;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.cardElevated : AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.error : AppColors.cardBorder,
                        width: isSelected ? 1.6 : 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            _selectedViolationIndex = index;
                          });
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.error.withValues(alpha: 0.2) : AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: isSelected ? AppColors.error : AppColors.textMuted,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                        trailing: Text(
                          CurrencyFormatter.formatSDG(item['amount'] as double),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.goldPrimary : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // الموقع الجغرافي والمحلية (GPS)
                Text(
                  '3. الموقع وتحديد المحلية (نطاق النيل الأبيض)',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.goldPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLocality,
                      dropdownColor: AppColors.cardElevated,
                      isExpanded: true,
                      icon: const Icon(Icons.location_on_rounded, color: AppColors.goldPrimary),
                      items: SudanLocations.whiteNileLocalities.map((loc) {
                        return DropdownMenuItem(
                          value: loc,
                          child: Text(loc, style: const TextStyle(fontSize: 13, color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedLocality = val);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location_rounded, color: AppColors.goldPrimary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$_selectedLocality - تحديد الموقع', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(
                              'إحداثيات الضبط: $_latitude, $_longitude',
                              style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ملخص الغرامة وزر الإصدار
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF220A0A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error, width: 1.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('إجمالي قيمة الغرامة:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text(
                            CurrencyFormatter.formatSDG(selectedVio['amount'] as double),
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.goldPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: traffic.isLoading ? null : _issueTicket,
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text('إصدار الإشعار الآن'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}
