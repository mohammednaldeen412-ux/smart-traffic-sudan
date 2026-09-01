import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/theme_provider.dart';
import '../../core/services/traffic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/vehicle_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/vehicle_card.dart';
import 'add_vehicle_screen.dart';
import 'vehicle_details_screen.dart';

class VehiclesListScreen extends StatefulWidget {
  const VehiclesListScreen({super.key});

  @override
  State<VehiclesListScreen> createState() => _VehiclesListScreenState();
}

class _VehiclesListScreenState extends State<VehiclesListScreen> {
  int _selectedFilter = 0; // 0: الكل, 1: موثقة, 2: قيد المراجعة
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _handleRefresh() async {
    _simulateLoading();
    await Future.delayed(const Duration(milliseconds: 800));
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
    final inputBg = isDark ? AppColors.inputBackground : AppColors.lightInputBackground;
    final cardBorder = isDark ? AppColors.cardBorder : AppColors.lightCardBorder;

    List<VehicleModel> filteredVehicles = traffic.vehicles.where((v) {
      if (_selectedFilter == 1 && !v.isVerified) return false;
      if (_selectedFilter == 2 && v.isVerified) return false;

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchPlate = v.plateNumber.contains(query) || v.fullPlateDisplay.contains(query);
        final matchMake = v.make.toLowerCase().contains(query);
        final matchModel = v.model.toLowerCase().contains(query);
        return matchPlate || matchMake || matchModel;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('إدارة المركبات والتراخيص'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.goldPrimary),
            tooltip: 'إضافة مركبة',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddVehicleScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            children: [
              // حقل البحث
              TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'ابحث برقم اللوحة، الماركة، أو الموديل...',
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

              // فلتر الفئات
              Row(
                children: [
                  _buildFilterChip('الكل (${traffic.vehicles.length})', 0),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'موثقة (${traffic.vehicles.where((v) => v.isVerified).length})',
                    1,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'قيد المراجعة (${traffic.vehicles.where((v) => !v.isVerified).length})',
                    2,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Expanded(
                child: _isLoading
                    ? SkeletonLoader.list(count: 3)
                    : RefreshIndicator(
                        onRefresh: _handleRefresh,
                        color: AppColors.goldPrimary,
                        backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
                        child: filteredVehicles.isEmpty
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
                                            Icons.directions_car_filled_outlined,
                                            size: 48,
                                            color: AppColors.goldPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'لا توجد مركبات تطابق البحث',
                                          style: AppTypography.titleMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'يمكنك إضافة مركبة جديدة وربطها برقمك الوطني بسهولة',
                                          style: AppTypography.bodySmall,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 20),
                                        CustomButton(
                                          text: 'إضافة مركبة جديدة',
                                          icon: Icons.add_rounded,
                                          width: 220,
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => const AddVehicleScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: filteredVehicles.length,
                                itemBuilder: (context, index) {
                                  final vehicle = filteredVehicles[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: VehicleCard(
                                      vehicle: vehicle,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => VehicleDetailsScreen(vehicle: vehicle),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
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
