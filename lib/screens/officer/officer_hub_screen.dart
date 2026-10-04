import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/localization/app_strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/locale_provider.dart';
import '../../core/services/theme_provider.dart';
import '../../core/services/traffic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_background.dart';
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
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final c = GlassColors.of(context);
    final officer = auth.currentUser;
    final officerBadge = officer?.officerBadgeNumber ?? 'SD-TRF-8842';
    final shiftViolations = traffic.getOfficerShiftViolations(officerBadge);
    final accent = c.isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309); // كهرماني أمني

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.local_police_rounded, color: accent),
            const SizedBox(width: 8),
            Text(
              officerBadge,
              style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: localeProvider.isArabic ? 'English' : 'العربية',
            icon: Icon(Icons.language_rounded, color: c.iconOnGlass),
            onPressed: () => localeProvider.toggleLanguage(),
          ),
          IconButton(
            icon: Icon(themeProvider.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: c.iconOnGlass),
            onPressed: () => themeProvider.toggleTheme(),
          ),
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
      body: AppBackground(
        role: AppRole.officer,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الترحيب حسب الوقت
                Text(
                  context.tr(AppStrings.greetingKey()),
                  style: TextStyle(color: c.textMuted, fontSize: 14),
                ),
                Text(
                  '${context.tr('officer_rank')} ${officer?.fullName.split(' ').first ?? ''}',
                  style: TextStyle(color: c.text, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  context.tr('field_ops_active'),
                  style: TextStyle(color: c.textFaint, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // رادار الطوارئ اللحظي
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('emergencies')
                      .where('status', isEqualTo: 'new')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final emergencies = snapshot.data!.docs;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: GlassCard(
                        blur: 15,
                        opacity: c.isDark ? 0.3 : 0.85,
                        tintColor: Colors.redAccent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.emergency_share_rounded, color: Colors.white, size: 28),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    context.tr('field_emergency_call'),
                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${emergencies.length} ${context.tr('reports_count')}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.tr('active_emergencies_msg'),
                              style: const TextStyle(color: Colors.white70),
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(context.tr('opening_radar')), backgroundColor: Colors.redAccent),
                                  );
                                },
                                child: Text(context.tr('open_radar'), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // المهام التكتيكية
                Text(
                  context.tr('tactical_tasks'),
                  style: TextStyle(color: accent, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildActionCard(
                  c: c,
                  title: context.tr('plate_lookup_title'),
                  subtitle: context.tr('plate_lookup_sub'),
                  icon: Icons.qr_code_scanner_rounded,
                  color: AppColors.primary,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlateLookupScreen())),
                ),
                _buildActionCard(
                  c: c,
                  title: context.tr('issue_ticket_title'),
                  subtitle: context.tr('issue_ticket_sub'),
                  icon: Icons.edit_document,
                  color: Colors.orange,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TicketIssuerScreen())),
                ),
                _buildActionCard(
                  c: c,
                  title: context.tr('shift_log_title'),
                  subtitle: context.tr('shift_log_sub'),
                  icon: Icons.history_edu_rounded,
                  color: Colors.blueAccent,
                  badge: '${shiftViolations.length}',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OfficerShiftHistoryScreen())),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required GlassColors c,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        blur: 15,
        opacity: c.glassOpacity,
        tintColor: c.glassTint,
        padding: const EdgeInsets.all(16),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title, style: TextStyle(color: c.text, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                          child: Text(badge, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle, style: TextStyle(color: c.textFaint, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, color: c.textFaint, size: 16),
          ],
        ),
      ),
    );
  }
}
