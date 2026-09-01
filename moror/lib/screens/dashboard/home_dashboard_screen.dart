import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/traffic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/sovereign_badge.dart';
import '../../widgets/vehicle_card.dart';
import '../../widgets/violation_card.dart';
import '../emergency/emergency_hotline_screen.dart';
import '../payment/payment_gateway_screen.dart';
import '../profile/digital_license_screen.dart';
import '../vehicles/add_vehicle_screen.dart';
import '../vehicles/vehicle_details_screen.dart';
import '../violations/violation_details_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const HomeDashboardScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final traffic = context.watch<TrafficService>();
    final user = auth.currentUser;

    final unpaidViolations = traffic.violations.where((v) => !v.isPaid).toList();
    final totalUnpaidAmount = unpaidViolations.fold(0.0, (sum, v) => sum + v.amount);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: Theme.of(context).cardColor,
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 600));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Welcome Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                                  backgroundImage: user?.profileImageUrl != null
                                      ? NetworkImage(user!.profileImageUrl!)
                                      : null,
                                  child: user?.profileImageUrl == null
                                      ? const Icon(Icons.person, color: AppColors.primary, size: 24)
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'مرحباً بك،',
                                            style: AppTypography.bodySmall.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          const Icon(
                                            Icons.verified_rounded,
                                            size: 10,
                                            color: AppColors.primary,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        user?.fullName ?? 'المواطن',
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
                          const SizedBox(width: 6),
                          // Emergency Call Button
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const EmergencyHotlineScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.error.withValues(alpha: 0.5),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.emergency_rounded,
                                    color: AppColors.error,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'طوارئ 777',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Sovereign Header Badge
                      const SovereignBadge(),

                      const SizedBox(height: 16),

                      // Main Banner Image
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                          image: const DecorationImage(
                            image: AssetImage('assets/images/citizen_header.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Summary Stats Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'المخالفات المستحقة',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    CurrencyFormatter.formatSDG(totalUnpaidAmount),
                                    style: AppTypography.titleLarge.copyWith(
                                      color: unpaidViolations.isNotEmpty
                                          ? AppColors.error
                                          : AppColors.success,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    ' مخالفات غير مدفوعة',
                                    style: AppTypography.bodySmall.copyWith(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (unpaidViolations.isNotEmpty)
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => PaymentGatewayScreen(
                                        violation: unpaidViolations.first,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.payment, size: 16),
                                label: const Text('سداد الكل'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Quick Services Section Title
                      Text(
                        'الخدمات السريعة',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Quick Services Grid (Clean Responsive Layout)
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.05,
                        children: [
                          _buildServiceCard(
                            context: context,
                            title: 'مركباتي',
                            icon: Icons.directions_car_rounded,
                            color: Colors.blue,
                            onTap: () => onNavigateTab?.call(1),
                          ),
                          _buildServiceCard(
                            context: context,
                            title: 'المخالفات',
                            icon: Icons.receipt_long_rounded,
                            color: Colors.orange,
                            onTap: () => onNavigateTab?.call(2),
                          ),
                          _buildServiceCard(
                            context: context,
                            title: 'رخصتي الرقمية',
                            icon: Icons.badge_rounded,
                            color: Colors.teal,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const DigitalLicenseScreen(),
                                ),
                              );
                            },
                          ),
                          _buildServiceCard(
                            context: context,
                            title: 'سداد سريع',
                            icon: Icons.payment_rounded,
                            color: Colors.green,
                            onTap: () {
                              if (unpaidViolations.isNotEmpty) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PaymentGatewayScreen(
                                      violation: unpaidViolations.first,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('لا توجد مخالفات غير مدفوعة حالياً'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                          ),
                          _buildServiceCard(
                            context: context,
                            title: 'إضافة مركبة',
                            icon: Icons.add_circle_outline_rounded,
                            color: Colors.purple,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AddVehicleScreen(),
                                ),
                              );
                            },
                          ),
                          _buildServiceCard(
                            context: context,
                            title: 'بلاغ طوارئ',
                            icon: Icons.support_agent_rounded,
                            color: Colors.red,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const EmergencyHotlineScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Vehicles Preview Title & Action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'مركباتي المسجلة',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => onNavigateTab?.call(1),
                            child: const Text('عرض الكل'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      if (traffic.vehicles.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.directions_car_outlined, size: 40, color: AppColors.textMuted),
                              const SizedBox(height: 8),
                              Text(
                                'لا توجد مركبات مسجلة باسمك حالياً',
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
                                  );
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('إضافة مركبة جديدة'),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: traffic.vehicles.length > 2 ? 2 : traffic.vehicles.length,
                          itemBuilder: (context, index) {
                            final veh = traffic.vehicles[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: VehicleCard(
                                vehicle: veh,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => VehicleDetailsScreen(vehicle: veh),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 16),

                      // Recent Violations Preview
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'أحدث المخالفات',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => onNavigateTab?.call(2),
                            child: const Text('عرض الكل'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      if (traffic.violations.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'سجلك نظيف! لا توجد مخالفات مسجلة',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: traffic.violations.length > 2 ? 2 : traffic.violations.length,
                          itemBuilder: (context, index) {
                            final viol = traffic.violations[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ViolationCard(
                                violation: viol,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ViolationDetailsScreen(violation: viol),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
