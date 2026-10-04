import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/services/traffic_service.dart';
import '../../core/theme/app_typography.dart';
import '../../models/vehicle_model.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/skeleton_loader.dart';
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
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(context.tr('vehicles_management'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // خلفية داكنة مع تدرج لوني يعطي طابع الفخامة
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.8, -0.6),
                radius: 1.5,
                colors: [Color(0xFF1E293B), Color(0xFF0A0E17)],
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                children: [
                  // حقل البحث الزجاجي
                  GlassCard(
                    blur: 10.0,
                    opacity: 0.1,
                    tintColor: Colors.white,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim();
                        });
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'ابحث برقم اللوحة أو الموديل...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white54),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // فلاتر زجاجية
                  Row(
                    children: [
                      _buildGlassFilterChip('الكل (${traffic.vehicles.length})', 0),
                      const SizedBox(width: 8),
                      _buildGlassFilterChip('المرخصة (${traffic.vehicles.where((v) => v.isVerified).length})', 1),
                      const SizedBox(width: 8),
                      _buildGlassFilterChip('منتهية/مراجعة (${traffic.vehicles.where((v) => !v.isVerified).length})', 2),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: _isLoading
                        ? SkeletonLoader.list(count: 3)
                        : RefreshIndicator(
                            onRefresh: _handleRefresh,
                            color: Colors.white,
                            backgroundColor: const Color(0xFF1E293B),
                            child: filteredVehicles.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    itemCount: filteredVehicles.length,
                                    itemBuilder: (context, index) {
                                      final vehicle = filteredVehicles[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: _buildGlassVehicleCard(vehicle, context),
                                      );
                                    },
                                  ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassFilterChip(String label, int index) {
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
          opacity: isSelected ? 0.3 : 0.05,
          tintColor: isSelected ? Colors.white : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        GlassCard(
          blur: 15,
          opacity: 0.1,
          tintColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.directions_car_filled_outlined, size: 64, color: Colors.white30),
                const SizedBox(height: 20),
                Text(
                  'لا توجد مركبات',
                  style: AppTypography.titleMedium.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'لا توجد مركبات مسجلة بهذا الرقم الوطني في نظام المرور حالياً.',
                  style: AppTypography.bodySmall.copyWith(color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassVehicleCard(VehicleModel vehicle, BuildContext context) {
    return GlassCard(
      blur: 15,
      opacity: 0.15,
      tintColor: vehicle.isVerified ? const Color(0xFF69F0AE) : const Color(0xFFFF8A80),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => VehicleDetailsScreen(vehicle: vehicle)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // أيقونة المركبة
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            
            // تفاصيل المركبة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicle.make} ${vehicle.model}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: vehicle.isLicenseExpired
                            ? const Color(0xFFFF8A80).withValues(alpha: 0.2)
                            : vehicle.isVerified 
                              ? const Color(0xFF69F0AE).withValues(alpha: 0.2) 
                              : const Color(0xFFFF8A80).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          vehicle.isLicenseExpired ? 'منتهية الترخيص' : vehicle.isVerified ? 'مرخصة وموثقة' : 'غير مرخصة',
                          style: TextStyle(
                            color: vehicle.isLicenseExpired ? const Color(0xFFFF8A80) : vehicle.isVerified ? const Color(0xFF69F0AE) : const Color(0xFFFF8A80),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        vehicle.fullPlateDisplay,
                        style: const TextStyle(color: Colors.white70, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 16),
          ],
        ),
      ),
    );
  }
}
