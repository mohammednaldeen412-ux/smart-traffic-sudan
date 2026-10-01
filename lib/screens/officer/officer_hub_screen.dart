import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/traffic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../dashboard/smart_role_router.dart';
import 'officer_shift_history_screen.dart';
import 'plate_lookup_screen.dart';
import 'ticket_issuer_screen.dart';

class OfficerHubScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;
  const OfficerHubScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final traffic = context.watch<TrafficService>();
    final officer = auth.currentUser;
    final officerBadge = officer?.officerBadgeNumber ?? 'SD-TRF-8842';
    final shiftViolations = traffic.getOfficerShiftViolations(officerBadge);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17), // Dark Navy/Black background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.local_police_rounded, color: AppColors.goldPrimary),
            const SizedBox(width: 8),
            Text(
              officerBadge,
              style: const TextStyle(color: AppColors.goldPrimary, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () async {
              await auth.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SmartRoleRouter()));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Text(
                'النقيب / ${officer?.fullName?.split(' ').first ?? 'طارق'}',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                'غرفة العمليات الميدانية - وردية نشطة',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Real-time Emergency Radar
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('emergencies')
                    .where('status', isEqualTo: 'new')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const SizedBox.shrink(); // No emergencies
                  }
                  
                  final emergencies = snapshot.data!.docs;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: GlassCard(
                      blur: 15,
                      opacity: 0.3,
                      tintColor: Colors.redAccent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.emergency_share_rounded, color: Colors.white, size: 28),
                              const SizedBox(width: 8),
                              const Text(
                                'نداء طوارئ ميداني',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('${emergencies.length} بلاغ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'توجد بلاغات طوارئ نشطة في محيطك الجغرافي تتطلب استجابة فورية.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                // هنا سيتم فتح شاشة تفاصيل الطوارئ والخريطة
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('جاري فتح الرادار...'), backgroundColor: Colors.redAccent),
                                );
                              },
                              child: const Text('فتح رادار التوجيه', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Tactical Actions
              const Text(
                'المهام التكتيكية',
                style: TextStyle(color: AppColors.goldPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildActionCard(
                title: 'فحص واستعلام فوري',
                subtitle: 'إدخال رقم اللوحة لكشف المالك وحالات السرقة',
                icon: Icons.qr_code_scanner_rounded,
                color: AppColors.goldPrimary,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlateLookupScreen())),
              ),
              
              _buildActionCard(
                title: 'تحرير مخالفة مرورية',
                subtitle: 'إصدار إشعار إلكتروني فوري بحق المركبة',
                icon: Icons.edit_document,
                color: Colors.orangeAccent,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TicketIssuerScreen())),
              ),
              
              _buildActionCard(
                title: 'سجل النوبة الميدانية',
                subtitle: 'مراجعة كافة المخالفات التي حررتها اليوم',
                icon: Icons.history_edu_rounded,
                color: Colors.blueAccent,
                badge: '${shiftViolations.length}',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OfficerShiftHistoryScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161C28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Text(badge, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
      ),
    );
  }
}
