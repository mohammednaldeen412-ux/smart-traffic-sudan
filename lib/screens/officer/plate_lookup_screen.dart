import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/services/traffic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/vehicle_model.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../officer/ticket_issuer_screen.dart';

class PlateLookupScreen extends StatefulWidget {
  const PlateLookupScreen({super.key});
  @override
  State<PlateLookupScreen> createState() => _PlateLookupScreenState();
}

class _PlateLookupScreenState extends State<PlateLookupScreen> {
  final _plateController = TextEditingController();
  VehicleModel? _result;
  UserModel? _ownerResult;
  bool _hasSearched = false;
  bool _isLoading = false;

  Future<void> _search() async {
    final plate = _plateController.text.trim();
    if (plate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رقم اللوحة للبحث'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() { _isLoading = true; _hasSearched = false; });
    final traffic = context.read<TrafficService>();
    final found = await traffic.lookupVehicleByPlate(plate);
    
    UserModel? owner;
    if (found != null && found.userId.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(found.userId).get();
        if (doc.exists) {
          owner = UserModel.fromJson(doc.data()!);
        }
      } catch (e) {
        debugPrint('Error fetching owner details: $e');
      }
    }

    setState(() {
      _result = found;
      _ownerResult = owner;
      _hasSearched = true;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('الاستعلام عن مركبة')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? AppColors.cardBorder : AppColors.lightCardBorder)),
              ),
              child: Column(
                children: [
                  CustomTextField(
                    controller: _plateController,
                    label: 'رقم اللوحة',
                    hint: 'مثال: خ 5 1234',
                    prefixIcon: Icons.search_rounded
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'بحث',
                    icon: Icons.search,
                    isLoading: _isLoading,
                    onPressed: _search,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Results
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_hasSearched && _result == null)
              _buildNotFound()
            else if (_hasSearched && _result != null)
              Expanded(child: _buildResult(_result!, _ownerResult)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? AppColors.cardBorder : AppColors.lightCardBorder)),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off, size: 56, color: Colors.orange),
          SizedBox(height: 12),
          Text('المركبة غير مسجلة في النظام', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text('تأكد من رقم اللوحة أو أن المركبة غير مسجلة رسمياً', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildResult(VehicleModel v, UserModel? owner) {
    final isWanted = v.isWanted;
    
    // License formatting
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    final formattedExpiry = v.licenseExpiryDate != null ? dateFormat.format(v.licenseExpiryDate!) : 'غير محدد';
    final isExpired = v.isLicenseExpired;
    final daysLeft = v.daysUntilExpiry;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Alert Banner
          if (isWanted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      v.wantedReason != null 
                        ? '⚠️ تنبيه أمني: أمر حجز! (${v.wantedReason})'
                        : '⚠️ تنبيه أمني: هذه المركبة مطلوبة!', 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)
                    ),
                  ),
                ],
              ),
            ),
          if (isWanted) const SizedBox(height: 12),

          // Vehicle Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isWanted ? Colors.red : AppColors.primary.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plate number display
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade700, width: 2),
                    ),
                    child: Text(
                      v.plateNumber,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A), letterSpacing: 4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _row(Icons.directions_car, 'الشركة / الموديل', '${v.make} ${v.model}'),
                const Divider(height: 20),
                _row(Icons.palette, 'اللون', v.color),
                const Divider(height: 20),
                _row(Icons.numbers, 'رقم الشاسي', v.chassisNumber),
                const Divider(height: 20),
                _row(
                  v.isVerified ? Icons.verified : Icons.pending,
                  'الحالة',
                  v.isVerified ? 'موثقة ✓' : 'قيد المراجعة',
                  color: v.isVerified ? Colors.green : Colors.orange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // License Duration Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('بيانات الترخيص', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(height: 20),
                _row(Icons.calendar_month, 'تاريخ الإنتهاء', formattedExpiry),
                if (v.licenseExpiryDate != null) ...[
                  const Divider(height: 20),
                  _row(
                    isExpired ? Icons.warning_amber : Icons.check_circle_outline,
                    'حالة الترخيص',
                    isExpired ? 'منتهي الصلاحية' : 'ساري (متبقي $daysLeft يوم)',
                    color: isExpired ? Colors.red : Colors.green,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Owner Details Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تفاصيل مالك المركبة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(height: 20),
                if (owner != null) ...[
                  _row(Icons.person, 'الاسم', owner.fullName),
                  const Divider(height: 20),
                  _row(Icons.badge, 'الرقم الوطني', owner.nationalId),
                  const Divider(height: 20),
                  _row(Icons.phone, 'رقم الهاتف', owner.phoneNumber),
                ] else ...[
                  const Row(
                    children: [
                      Icon(Icons.person_off, color: Colors.grey),
                      SizedBox(width: 10),
                      Text('لا توجد بيانات مسجلة لمالك هذه المركبة', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Certificate Image
          if (v.certificateImageUrl.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('شهادة البحث المرفقة:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(v.certificateImageUrl, width: double.infinity, height: 180, fit: BoxFit.cover,
                    loadingBuilder: (c, w, p) => p == null ? w : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),

          // Issue Ticket Button
          CustomButton(
            text: 'إصدار مخالفة لهذه المركبة',
            icon: Icons.receipt_long,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => TicketIssuerScreen(prefilledPlate: v.plateNumber),
              ));
            },
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? AppColors.primary),
        const SizedBox(width: 10),
        Text('$label: ', style: AppTypography.bodyMedium.copyWith(color: (Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondary : AppColors.lightTextSecondary))),
        Expanded(child: Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: color))),
      ],
    );
  }
}
