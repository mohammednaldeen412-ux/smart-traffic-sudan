import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/localization/app_strings.dart';
import '../../widgets/app_background.dart';
import '../../widgets/glass_card.dart';

class DriverLicenseScreen extends StatelessWidget {
  const DriverLicenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Dummy data for visual design
    final issueDate = '2023-05-12';
    final expiryDate = '2028-05-12';
    final points = 0;
    final status = 'سارية المفعول';
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(context.tr('digital_license_full'), style: TextStyle(color: GlassColors.of(context).text, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: GlassColors.of(context).text),
      ),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        role: AppRole.citizen,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // The Digital License Card
            GlassCard(
              padding: EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E293B).withValues(alpha: 0.8),
                      const Color(0xFF0F172A).withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // Header of the card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                        border: const Border(bottom: BorderSide(color: Colors.white12)),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset('assets/images/logo.png', width: 30, height: 30, errorBuilder: (c, e, s) => const Icon(Icons.security, color: Color(0xFFD4AF37))),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('رخصة قيادة سودانية', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('Sudanese Driving License', style: TextStyle(color: Colors.white54, fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                          const Icon(Icons.contactless_rounded, color: Colors.white54),
                        ],
                      ),
                    ),
                    
                    // Body of the card
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Photo
                          Container(
                            width: 80,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
                              image: DecorationImage(
                                image: NetworkImage(user.profileImageUrl ?? 'https://ui-avatars.com/api/?name=${user.fullName}&background=random'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  _buildLicenseRow(context.tr('name_label'), user.fullName),
                                  const SizedBox(height: 8),
                                  _buildLicenseRow(context.tr('national_id_label'), user.nationalId),
                                  const SizedBox(height: 8),
                                  _buildLicenseRow(context.tr('category_label') ?? 'الفئة:', context.tr('category_private') ?? 'ملاكي (عامة)'),
                                  const SizedBox(height: 8),
                                  _buildLicenseRow(context.tr('issue_date') ?? 'تاريخ الإصدار:', issueDate),
                                  const SizedBox(height: 8),
                                  _buildLicenseRow(context.tr('expiry_date') ?? 'تاريخ الانتهاء:', expiryDate),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Footer Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.white12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${context.tr('license_number_label')} ${user.driverLicenseNumber}', style: const TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'monospace')),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                              ),
                              child: Text(context.tr('active'), style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Status and Points
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      child: Column(
                        children: [
                          const Icon(Icons.speed_rounded, color: Colors.blueAccent, size: 32),
                          const SizedBox(height: 8),
                          Text('$points', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          Text(context.tr('traffic_points') ?? 'النقاط المرورية', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GlassCard(
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent, size: 32),
                          const SizedBox(height: 8),
                          Text(context.tr('active'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          Text(context.tr('license_status') ?? 'حالة الرخصة', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Renewal Action
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('license_valid_msg') ?? 'رخصتك سارية المفعول ولا تحتاج لتجديد حالياً')));
                },
                icon: const Icon(Icons.autorenew_rounded),
                label: Text(context.tr('renew_license') ?? 'طلب تجديد الرخصة', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          ),
      ),
    );
  }

  Widget _buildLicenseRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 90, child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11))),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
      ],
    );
  }
}
