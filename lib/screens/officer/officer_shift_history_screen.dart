import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/traffic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/violation_card.dart';
import '../violations/violation_details_screen.dart';

class OfficerShiftHistoryScreen extends StatelessWidget {
  const OfficerShiftHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final traffic = context.watch<TrafficService>();
    final officer = auth.currentUser;
    final officerBadge = officer?.officerBadgeNumber ?? 'SD-TRF-8842';

    final shiftTickets = traffic.getOfficerShiftViolations(officerBadge);
    final totalFinesAmount = shiftTickets.fold(0.0, (sum, v) => sum + v.amount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('سجل الميدان ونوبة العمل'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة إحصائيات الوردية
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.sovereignHeaderGradient,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${shiftTickets.length}',
                          style: AppTypography.displayMedium.copyWith(
                            color: AppColors.goldPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text('مخالفة محررة', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                    Container(width: 1, height: 40, color: AppColors.divider),
                    Column(
                      children: [
                        Text(
                          CurrencyFormatter.formatNumber(totalFinesAmount),
                          style: AppTypography.displayMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text('إجمالي الغرامات (ج.س)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'المخالفات المحررة في الوردية الحالية',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.goldPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: shiftTickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.assignment_turned_in_outlined, size: 48, color: AppColors.goldPrimary),
                            const SizedBox(height: 12),
                            Text('لم يتم تحرير مخالفات حتى الآن في هذه الوردية', style: AppTypography.bodyMedium),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: shiftTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = shiftTickets[index];
                          return ViolationCard(
                            violation: ticket,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ViolationDetailsScreen(violation: ticket),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
