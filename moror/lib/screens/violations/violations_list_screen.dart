import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/theme_provider.dart';
import '../../core/services/traffic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/violation_model.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/violation_card.dart';
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
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.filterPlate != null) {
      _searchQuery = widget.filterPlate!;
      _searchController.text = widget.filterPlate!;
    }
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final traffic = context.watch<TrafficService>();
    final isDark = context.watch<ThemeProvider>().isDark;

    final bg = isDark ? AppColors.background : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final surfaceColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final inputBg = isDark ? AppColors.inputBackground : AppColors.lightInputBackground;
    final cardBorder = isDark ? AppColors.cardBorder : AppColors.lightCardBorder;

    final List<ViolationModel> filtered = traffic.violations.where((v) {
      if (_selectedFilter == 1 && v.isPaid) return false;
      if (_selectedFilter == 2 && !v.isPaid) return false;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchPlate = v.plateNumber.contains(q) || v.fullPlateDisplay.contains(q);
        final matchType = v.violationType.toLowerCase().contains(q);
        final matchLoc = v.locationName.toLowerCase().contains(q);
        return matchPlate || matchType || matchLoc;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('سجل المخالفات والغرامات'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            children: [
              // حقل البحث المتكيف مع الثيم
              TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'ابحث برقم اللوحة، الموقع، أو نوع المخالفة...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.goldPrimary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textMuted),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: inputBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.2),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // بطاقة الإجمالي المستحق السريعة
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.goldPrimary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'المجموع غير المسدد:',
                          style: AppTypography.bodySmall.copyWith(color: textSecondary),
                        ),
                      ],
                    ),
                    Text(
                      CurrencyFormatter.formatSDG(traffic.totalUnpaidAmount),
                      style: AppTypography.titleSmall.copyWith(
                        color: isDark ? AppColors.goldPrimary : AppColors.goldDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // أزرار الفلترة (الكل / غير مسددة / مسددة)
              Row(
                children: [
                  _buildFilterChip('الكل (${traffic.violations.length})', 0),
                  const SizedBox(width: 8),
                  _buildFilterChip('غير مسددة (${traffic.unpaidViolationsCount})', 1),
                  const SizedBox(width: 8),
                  _buildFilterChip('مسددة (${traffic.paidViolationsCount})', 2),
                ],
              ),

              const SizedBox(height: 16),

              // قائمة المخالفات مع دعم شاشة التحميل الهيكلية والرفع للتحديث
              Expanded(
                child: _isLoading
                    ? SkeletonLoader.list(count: 3)
                    : RefreshIndicator(
                        onRefresh: _handleRefresh,
                        color: AppColors.goldPrimary,
                        backgroundColor: surfaceColor,
                        child: filtered.isEmpty
                            ? ListView(
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: isDark ? AppColors.card : AppColors.lightCard,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: cardBorder),
                                          ),
                                          child: const Icon(
                                            Icons.check_circle_outline_rounded,
                                            size: 48,
                                            color: AppColors.success,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'لا توجد مخالفات في هذه الفئة',
                                          style: AppTypography.titleMedium,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'سجل القيادة نظيف والالتزام بالقوانين مستمر',
                                          style: AppTypography.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final vio = filtered[index];
                                  return ViolationCard(
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
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilter == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = index;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.goldPrimary.withValues(alpha: 0.18)
                : (isDark ? AppColors.surface : AppColors.lightSurface),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.goldPrimary
                  : (isDark ? AppColors.cardBorder : AppColors.lightCardBorder),
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? (isDark ? AppColors.goldPrimary : AppColors.goldDark)
                  : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
