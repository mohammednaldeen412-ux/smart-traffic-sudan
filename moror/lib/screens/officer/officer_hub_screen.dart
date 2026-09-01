import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/traffic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/sovereign_badge.dart';
import '../dashboard/smart_role_router.dart';
import 'officer_shift_history_screen.dart';
import 'plate_lookup_screen.dart';
import 'ticket_issuer_screen.dart';

class OfficerHubScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const OfficerHubScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final traffic = context.watch<TrafficService>();
    final officer = auth.currentUser;
    final officerBadge = officer?.officerBadgeNumber ?? 'SD-TRF-8842';

    final shiftViolations = traffic.getOfficerShiftViolations(officerBadge);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // رأس شاشة الضابط الميداني
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF1E283E),
                                  border: Border.all(color: AppColors.goldPrimary, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.goldPrimary.withValues(alpha: 0.25),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.local_police_rounded,
                                    color: AppColors.goldPrimary,
                                    size: 26,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.goldPrimary,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'الضبط الميداني',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.background,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            officer?.officerBadgeNumber ?? 'SD-TRF-8842',
                                            style: const TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 11,
                                              color: AppColors.goldPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      officer?.fullName ?? 'النقيب / طارق عثمان الطيب',
                                      style: AppTypography.titleSmall.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        // أزرار التحكم (خروج)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                              tooltip: 'تسجيل الخروج',
                              onPressed: () async {
                                await auth.logout();
                                if (!context.mounted) return;
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => const SmartRoleRouter()),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // شارة قطاع العمليات
                    SovereignBadge(
                      title: 'غرفة الضبط والمراقبة الميدانية',
                      subtitle: officer?.officerSector ?? 'شعبة الرقابة والضبط الميداني - قطاع وسط الخرطوم',
                    ),

                    const SizedBox(height: 16),

                    // بنر الضابط الميداني
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        image: const DecorationImage(
                          image: AssetImage('assets/images/officer_header.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // بطاقة نوبة العمل الحية (Live Shift Card)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E283E), Color(0xFF0D121D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldPrimary.withValues(alpha: 0.08),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.success,
                                        boxShadow: [
                                          BoxShadow(color: AppColors.success, blurRadius: 6),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'حالة العمل: نشطة الآن',
                                        style: AppTypography.titleSmall.copyWith(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'الوردية الصباحية',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildShiftStat('المخالفات المحررة', '${shiftViolations.length}', Icons.receipt_rounded, AppColors.goldPrimary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildShiftStat('المركبات المفحوصة', '18', Icons.search_rounded, AppColors.info),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildShiftStat('التعاميم النشطة', '1', Icons.warning_rounded, AppColors.error),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // أزرار العمليات الميدانية التكتيكية
                    Text(
                      'أدوات الرقابة والضبط الميداني',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.goldPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // زر 1: فحص واستعلام اللوحات
                    _buildTacticalActionCard(
                      context,
                      title: 'فحص واستعلام فوري عن مركبة',
                      subtitle: 'إدخال رقم اللوحة لكشف المالك، سريان الترخيص، وحالات الحظر أو السرقة',
                      icon: Icons.qr_code_scanner_rounded,
                      color: AppColors.goldPrimary,
                      badgeText: 'سحابي لحظي',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PlateLookupScreen()),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // زر 2: محرر وإصدار المخالفات السريع
                    _buildTacticalActionCard(
                      context,
                      title: 'إصدار مخالفة وضبط فوري',
                      subtitle: 'تحرير إشعار مخالفة إلكتروني مع توثيق GPS وتوجيهها لحساب المالك',
                      icon: Icons.edit_document,
                      color: AppColors.error,
                      badgeText: 'تحرير فوري',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TicketIssuerScreen()),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // زر 3: سجل الميدان ونوبة العمل
                    _buildTacticalActionCard(
                      context,
                      title: 'سجل الميدان ونوبة العمل',
                      subtitle: 'مراجعة كافة المخالفات التي حررتها اليوم والتحقق من كشوفات الدوريات',
                      icon: Icons.history_edu_rounded,
                      color: AppColors.info,
                      badgeText: '${shiftViolations.length} محررات',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const OfficerShiftHistoryScreen()),
                        );
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTacticalActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color, width: 1.5),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
