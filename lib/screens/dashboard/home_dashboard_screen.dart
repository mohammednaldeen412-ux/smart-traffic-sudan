import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/traffic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_background.dart';
import '../emergency/emergency_hotline_screen.dart';
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
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Request multiple permissions at once
    Map<Permission, PermissionStatus> statuses = await [
      Permission.notification,
      Permission.camera,
      Permission.location,
    ].request();
    
    // We don't need to block UI, just request them so the OS prompts the user.
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final traffic = context.watch<TrafficService>();
    final user = auth.currentUser;
    final c = GlassColors.of(context);

    final unpaidViolations = traffic.violations.where((v) => !v.isPaid).toList();
    final totalUnpaidAmount = unpaidViolations.fold(0.0, (sum, v) => sum + v.amount);
    final hasFines = unpaidViolations.isNotEmpty;

    final alertColor = hasFines
        ? (c.isDark ? const Color(0xFFFF8A80) : const Color(0xFFDC2626))
        : (c.isDark ? const Color(0xFF69F0AE) : const Color(0xFF059669));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        role: AppRole.citizen,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الترحيب بالمواطن حسب الوقت
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr(AppStrings.greetingKey()),
                            style: AppTypography.bodyMedium.copyWith(color: c.textMuted),
                          ),
                          Text(
                            user?.fullName ?? context.tr('citizen'),
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.titleLarge.copyWith(
                              color: c.text,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: c.glassTint.withValues(alpha: 0.15),
                      backgroundImage: user?.profileImageUrl != null
                          ? NetworkImage(user!.profileImageUrl!)
                          : null,
                      child: user?.profileImageUrl == null
                          ? Icon(Icons.person, color: c.iconOnGlass)
                          : null,
                    ),
                  ],
                ),

                
                const SizedBox(height: 16),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 120.0,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    enlargeCenterPage: true,
                    viewportFraction: 1.0,
                  ),
                                    items: [
                    {
                      'img': 'assets/images/banner1.jpg',
                      'text': 'احذر السرعة الزائدة، حياتك أهم'
                    },
                    {
                      'img': 'assets/images/banner2.jpg',
                      'text': 'أسبوع المرور العربي - معاً لطرق آمنة'
                    },
                    {
                      'img': 'assets/images/banner3.jpg',
                      'text': 'تجنب استخدام الهاتف أثناء القيادة'
                    },
                  ].map((item) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: AssetImage(item['img']!),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                item['text']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                const Spacer(flex: 1),


                // البطاقة الزجاجية الرئيسية (حالة السجل)
                GlassCard(
                  blur: 20.0,
                  opacity: c.isDark ? 0.2 : 0.12,
                  tintColor: hasFines ? AppColors.error : AppColors.success,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        hasFines ? Icons.warning_amber_rounded : Icons.verified_user_rounded,
                        size: 64,
                        color: alertColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.tr(hasFines ? 'fines_due' : 'clean_record'),
                        textAlign: TextAlign.center,
                        style: AppTypography.titleLarge.copyWith(
                          color: c.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (hasFines) ...[
                        const SizedBox(height: 8),
                        Text(
                          CurrencyFormatter.formatSDG(totalUnpaidAmount),
                          style: AppTypography.displayMedium.copyWith(
                            color: alertColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => widget.onNavigateTab?.call(2), // الانتقال للمخالفات
                            style: ElevatedButton.styleFrom(
                              backgroundColor: c.isDark ? Colors.white : AppColors.error,
                              foregroundColor: c.isDark ? AppColors.error : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              context.tr('view_and_pay'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        )
                      ] else ...[
                        const SizedBox(height: 8),
                        Text(
                          context.tr('safe_drive_tip'),
                          style: TextStyle(color: c.textMuted, fontSize: 14),
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
                        opacity: c.isDark ? 0.3 : 0.85,
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
                              context.tr('emergency_and_reports'),
                              textAlign: TextAlign.center,
                              style: AppTypography.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // زر المركبات
                    Expanded(
                      child: GlassCard(
                        blur: 15.0,
                        opacity: c.glassOpacity + 0.03,
                        tintColor: c.glassTint,
                        onTap: () => widget.onNavigateTab?.call(1),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.directions_car_rounded, color: c.iconOnGlass, size: 36),
                            const SizedBox(height: 12),
                            Text(
                              context.tr('my_vehicles'),
                              textAlign: TextAlign.center,
                              style: AppTypography.titleSmall.copyWith(color: c.text, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 90), // مساحة لشريط التنقل السفلي
              ],
            ),
          ),
        ),
      ),
    );
  }
}
