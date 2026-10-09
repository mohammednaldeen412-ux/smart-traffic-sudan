import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/services/theme_provider.dart';
import '../../core/services/traffic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/violation_model.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/violation_card.dart';
import '../../widgets/app_background.dart';
import '../../widgets/glass_card.dart';
import '../payment/payment_gateway_screen.dart';
import 'violation_details_screen.dart';

class ViolationsListScreen extends StatefulWidget {
  final String? filterPlate;

  const ViolationsListScreen({
    super.key,
    this.filterPlate,
  });

  @override
  State<ViolationsListScreen> createState() => _ViolationsListScreenState();
}

class _ViolationsListScreenState extends State<ViolationsListScreen> {
  int _selectedFilter = 0; // 0: الكل, 1: غير مسددة, 2: مسددة
  
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _simulateLoading();
  }

  void _simulateLoading() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _handleRefresh() async {
    _simulateLoading();
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final traffic = context.watch<TrafficService>();
    final c = GlassColors.of(context);

    final List<ViolationModel> filtered = traffic.violations.where((v) {
      if (_selectedFilter == 1 && v.isPaid) return false;
      if (_selectedFilter == 2 && !v.isPaid) return false;

      
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(context.tr('violations_record'), style: TextStyle(color: c.text, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: c.text),
      ),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        role: AppRole.citizen,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Column(
              children: [
                // حقل البحث المتكيف مع الثيم
                

                // بطاقة الإجمالي المستحق السريعة
                GlassCard(
                  blur: 10,
                  opacity: c.isDark ? 0.15 : 0.5,
                  tintColor: c.isDark ? AppColors.goldPrimary : AppColors.goldDark,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              color: c.text,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.tr('total_unpaid'),
                              style: AppTypography.bodySmall.copyWith(color: c.text.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                        Text(
                          CurrencyFormatter.formatSDG(traffic.totalUnpaidAmount),
                          style: AppTypography.titleSmall.copyWith(
                            color: c.isDark ? AppColors.goldPrimary : AppColors.goldDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // أزرار الفلترة (الكل / غير مسددة / مسددة)
                Row(
                  children: [
                    _buildFilterChip('${context.tr('all')} (${traffic.violations.length})', 0, c),
                    const SizedBox(width: 8),
                    _buildFilterChip('${context.tr('unpaid')} (${traffic.unpaidViolationsCount})', 1, c),
                    const SizedBox(width: 8),
                    _buildFilterChip('${context.tr('paid')} (${traffic.paidViolationsCount})', 2, c),
                  ],
                ),

                

                // قائمة المخالفات
                Expanded(
                  child: _isLoading
                      ? SkeletonLoader.list(count: 3)
                      : RefreshIndicator(
                          onRefresh: _handleRefresh,
                          color: c.text,
                          backgroundColor: Colors.transparent,
                          child: filtered.isEmpty
                              ? ListView(
                                  children: [
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                                    GlassCard(
                                      blur: 15,
                                      opacity: c.isDark ? 0.1 : 0.3,
                                      tintColor: c.isDark ? Colors.white : Colors.black,
                                      child: Padding(
                                        padding: const EdgeInsets.all(30),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.check_circle_outline_rounded,
                                              size: 64,
                                              color: c.isDark ? AppColors.success : Colors.green[700],
                                            ),
                                            const SizedBox(height: 20),
                                            Text(
                                              context.tr('no_violations_category'),
                                              style: AppTypography.titleMedium.copyWith(color: c.text),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              context.tr('clean_record_msg'),
                                              style: AppTypography.bodySmall.copyWith(color: c.text.withValues(alpha: 0.7)),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final vio = filtered[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: ViolationCard(
                                        violation: vio,
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => ViolationDetailsScreen(violation: vio),
                                            ),
                                          );
                                        },
                                        onPayTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => PaymentGatewayScreen(violation: vio),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, GlassColors c) {
    final isSelected = _selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = index;
          });
        },
        child: GlassCard(
          blur: 10,
          opacity: isSelected ? (c.isDark ? 0.3 : 0.6) : (c.isDark ? 0.05 : 0.2),
          tintColor: isSelected ? (c.isDark ? Colors.white : Colors.black) : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? (c.isDark ? Colors.white : Colors.white) : c.text.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
