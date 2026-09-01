import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      image: AppAssets.onboarding1,
      title: 'منظومة المرور الذكي',
      subtitle: 'إدارة رقمية متكاملة لشوارع السودان',
      description:
          'تحكم ذكي وفوري في حركة المرور من خلال منصة رقمية تجمع الضابط والمواطن في بيئة واحدة آمنة ومتصلة.',
      icon: Icons.traffic_rounded,
    ),
    _OnboardingData(
      image: AppAssets.onboarding2,
      title: 'رخصتك في جيبك',
      subtitle: 'وثائقك الرسمية دائماً معك',
      description:
          'استعرض رخصتك الرقمية وبيانات مركباتك وسجل مخالفاتك في أي وقت وأي مكان بضغطة واحدة.',
      icon: Icons.credit_card_rounded,
    ),
    _OnboardingData(
      image: AppAssets.onboarding3,
      title: 'سداد آمن وفوري',
      subtitle: 'ادفع غراماتك بكل يسر وأمان',
      description:
          'نظام دفع إلكتروني متكامل موثوق وآمن. سدد مخالفاتك وقدم اعتراضاتك دون الحاجة لزيارة الإدارة.',
      icon: Icons.shield_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bg = isDark ? AppColors.background : AppColors.lightBackground;
    final textPrimary =
        isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = isDark ? AppColors.cardBorder : AppColors.lightCardBorder;
    final goldAccent = isDark ? AppColors.goldPrimary : AppColors.goldDark;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // خلفية ضبابية للصفحة الحالية
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: Image.asset(
                _pages[_currentPage].image,
                key: ValueKey(_currentPage),
                fit: BoxFit.cover,
                color: isDark
                    ? Colors.black.withValues(alpha: 0.72)
                    : Colors.white.withValues(alpha: 0.55),
                colorBlendMode: BlendMode.srcOver,
              ),
            ),
          ),

          // طبقة Blur فوق الخلفية
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
              child: Container(color: Colors.transparent),
            ),
          ),

          // المحتوى
          SafeArea(
            child: Column(
              children: [
                // شريط علوي: لوغو + تبديل الثيم
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // لوغو صغير
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.card.withValues(alpha: 0.85)
                              : AppColors.lightCard.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Image.asset(
                          isDark ? AppAssets.logoDark : AppAssets.logoLight,
                          width: 38,
                          height: 38,
                          fit: BoxFit.contain,
                        ),
                      ),

                      // زر تخطي
                      if (_currentPage < _pages.length - 1)
                        TextButton(
                          onPressed: _completeOnboarding,
                          child: Text(
                            'تخطي',
                            style: AppTypography.bodyMedium.copyWith(
                              color: textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // PageView للشرائح
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index], isDark, textPrimary,
                          textSecondary, goldAccent, cardColor, borderColor);
                    },
                  ),
                ),

                // مؤشرات الصفحات + أزرار
                _buildBottomSection(isDark, textPrimary, textSecondary,
                    goldAccent, cardColor, borderColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(
    _OnboardingData data,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color goldAccent,
    Color cardColor,
    Color borderColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // بطاقة الصورة الرئيسية بتأثير زجاجي
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                  child: Container(
                    height: 260,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: goldAccent.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(27),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            data.image,
                            fit: BoxFit.cover,
                          ),
                          // طبقة شفافة ذهبية في الأسفل
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 80,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    (isDark
                                            ? AppColors.background
                                            : AppColors.lightBackground)
                                        .withValues(alpha: 0.8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // أيقونة الشريحة
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    goldAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color:
                                      goldAccent.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Icon(
                                data.icon,
                                color: goldAccent,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // العنوان الرئيسي
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  Text(
                    data.title,
                    style: AppTypography.displayMedium.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: goldAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: goldAccent.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      data.subtitle,
                      style: AppTypography.titleSmall.copyWith(
                        color: goldAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: textSecondary,
                      height: 1.7,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color goldAccent,
    Color cardColor,
    Color borderColor,
  ) {
    final isLast = _currentPage == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          // مؤشرات الصفحة (Dots)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == i
                      ? goldAccent
                      : goldAccent.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // أزرار التنقل
          Row(
            children: [
              // زر السابق
              if (_currentPage > 0) ...[
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Icon(Icons.arrow_forward_ios_rounded),
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // زر التالي / البدء
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (isLast) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(isLast ? 'ابدأ الآن' : 'التالي'),
                      const SizedBox(width: 8),
                      Icon(
                        isLast
                            ? Icons.rocket_launch_rounded
                            : Icons.arrow_back_ios_rounded,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String image;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  const _OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });
}
