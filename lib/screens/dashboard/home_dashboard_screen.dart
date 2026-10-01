import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/traffic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/glass_card.dart';
import '../emergency/emergency_hotline_screen.dart';
import '../payment/payment_gateway_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const HomeDashboardScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final traffic = context.watch<TrafficService>();
    final user = auth.currentUser;

    final unpaidViolations = traffic.violations.where((v) => !v.isPaid).toList();
    final totalUnpaidAmount = unpaidViolations.fold(0.0, (sum, v) => sum + v.amount);
    final hasFines = unpaidViolations.isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          // 1. الفخامة تبدأ من الخلفية
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/citizen_header.jpg'),
                fit: BoxFit.cover,
                // تعتيم خفيف للخلفية لإبراز الزجاج
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الترحيب بالمواطن
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "مرحباً بك،",
                            style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
                          ),
                          Text(
                            user?.fullName ?? context.tr('citizen'),
                            style: AppTypography.headlineSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white24,
                        backgroundImage: user?.profileImageUrl != null
                            ? NetworkImage(user!.profileImageUrl!)
                            : null,
                        child: user?.profileImageUrl == null
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                  
                  const Spacer(flex: 1),

                  // البطاقة الزجاجية الرئيسية (حالة السجل)
                  GlassCard(
                    blur: 20.0,
                    opacity: 0.2,
                    tintColor: hasFines ? AppColors.error : AppColors.success,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          hasFines ? Icons.warning_amber_rounded : Icons.verified_user_rounded,
                          size: 64,
                          color: hasFines ? const Color(0xFFFF8A80) : const Color(0xFF69F0AE),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          hasFines ? "لديك مطالبات مالية" : "سجلك المروري نظيف",
                          style: AppTypography.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (hasFines) ...[
                          const SizedBox(height: 8),
                          Text(
                            CurrencyFormatter.formatSDG(totalUnpaidAmount),
                            style: AppTypography.headlineMedium.copyWith(
                              color: const Color(0xFFFF8A80),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => widget.onNavigateTab?.call(2), // الانتقال للمخالفات
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.error,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "عرض التفاصيل والسداد",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          )
                        ] else ...[
                          const SizedBox(height: 8),
                          const Text(
                            "نتمنى لك قيادة آمنة، تذكر دائماً ربط حزام الأمان.",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ]
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // الأزرار السريعة الزجاجية في الأسفل
                  Row(
                    children: [
                      // زر الطوارئ
                      Expanded(
                        child: GlassCard(
                          blur: 15.0,
                          opacity: 0.3,
                          tintColor: Colors.redAccent,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const EmergencyHotlineScreen(),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emergency_share_rounded, color: Colors.white, size: 36),
                              const SizedBox(height: 12),
                              Text(
                                "طوارئ وبلاغات",
                                style: AppTypography.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // زر المركبات والمخالفات
                      Expanded(
                        child: GlassCard(
                          blur: 15.0,
                          opacity: 0.15,
                          tintColor: Colors.white,
                          onTap: () => widget.onNavigateTab?.call(1),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.directions_car_rounded, color: Colors.white, size: 36),
                              const SizedBox(height: 12),
                              Text(
                                "مركباتي",
                                style: AppTypography.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
