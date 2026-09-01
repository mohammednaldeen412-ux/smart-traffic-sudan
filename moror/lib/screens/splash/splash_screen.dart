import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/sovereign_badge.dart';
import '../onboarding/onboarding_screen.dart';
import '../dashboard/smart_role_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;
  late Animation<double> _progressValue;
  late Animation<double> _textFade;

  final String _statusText = 'تهيئة المنظومة الرقمية...';

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    _logoController.forward();
    _progressController.forward();

    final auth = context.read<AuthService>();
    int waited = 0;
    while (!auth.isInitialized && waited < 15) {
      await Future.delayed(const Duration(milliseconds: 100));
      waited++;
    }

    if (!mounted) return;
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            onboardingDone ? const SmartRoleRouter() : const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: AnimatedBuilder(
              animation: _pulseOpacity,
              builder: (context, child) => Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.goldPrimary
                      .withValues(alpha: 0.07 * _pulseOpacity.value),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goldLight.withValues(alpha: 0.04),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const SovereignBadge(),
                  const Spacer(flex: 2),

                  // Logo with pulse ring
                  Center(
                    child: AnimatedBuilder(
                      animation: Listenable.merge(
                          [_logoController, _pulseController]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScale.value * _pulseScale.value,
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.goldPrimary.withValues(
                                        alpha: 0.12 * _pulseOpacity.value),
                                    border: Border.all(
                                      color: AppColors.goldPrimary.withValues(
                                          alpha: 0.3 * _pulseOpacity.value),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.card,
                                    border: Border.all(
                                      color: AppColors.goldPrimary,
                                      width: 2.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.goldGlow.withValues(
                                            alpha:
                                                0.4 * _pulseOpacity.value),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.local_police_rounded,
                                      size: 56,
                                      color: AppColors.goldPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        Text(
                          'مرور السودان الذكي',
                          style: AppTypography.displayMedium.copyWith(
                            color: AppColors.goldPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'SMART TRAFFIC SUDAN',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.goldLight.withValues(alpha: 0.7),
                            letterSpacing: 3.0,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'المنظومة الرقمية القومية للمرور والسلامة',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Progress Bar & Status
                  AnimatedBuilder(
                    animation: _progressValue,
                    builder: (context, child) {
                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 4,
                              width: 180,
                              child: LinearProgressIndicator(
                                value: _progressValue.value,
                                backgroundColor: AppColors.cardBorder,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.goldPrimary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _statusText,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'الإدارة العامة للمرور © 2026',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
