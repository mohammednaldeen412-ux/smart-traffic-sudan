import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/services/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import 'admin_dashboard_screen.dart';
import '../profile/profile_settings_screen.dart';

class AdminNavigationWrapper extends StatefulWidget {
  const AdminNavigationWrapper({super.key});

  @override
  State<AdminNavigationWrapper> createState() => _AdminNavigationWrapperState();
}

class _AdminNavigationWrapperState extends State<AdminNavigationWrapper> {
  int _selectedIndex = 0;
  DateTime? _lastBackPress;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const Scaffold(body: Center(child: Text('إدارة الضباط والقوات'))),
    const Scaffold(body: Center(child: Text('التقارير السيادية'))),
    const ProfileSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bg = isDark ? AppColors.background : AppColors.lightBackground;
    final navbarBg = isDark
        ? AppColors.surface.withValues(alpha: 0.75)
        : AppColors.lightSurface.withValues(alpha: 0.85);
    final borderColor = isDark
        ? AppColors.goldPrimary.withValues(alpha: 0.25)
        : AppColors.goldDark.withValues(alpha: 0.20);
    final activeColor = isDark ? AppColors.goldPrimary : AppColors.goldDark;
    final inactiveColor = isDark ? AppColors.textMuted : AppColors.lightTextMuted;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return;
        }
        final now = DateTime.now();
        if (_lastBackPress == null || now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
          _lastBackPress = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('اضغط مرة أخرى للخروج من التطبيق'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
      backgroundColor: bg,
      extendBody: true, // يمتد المحتوى خلف شريط التنقل الزجاجي
      body: _screens[_selectedIndex],
      bottomNavigationBar: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 18, right: 18, bottom: 20, top: 4),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: navbarBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: borderColor,
                      width: 1.5,
                    ),
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _selectedIndex,
                    onTap: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    backgroundColor: Colors.transparent,
                    selectedItemColor: activeColor,
                    unselectedItemColor: inactiveColor,
                    selectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      fontFamily: 'Cairo',
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w500,
                    ),
                    type: BottomNavigationBarType.fixed,
                    elevation: 0,
                    items: [
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.dashboard_customize_outlined),
                        activeIcon: Icon(Icons.dashboard_customize_rounded, color: activeColor),
                        label: 'الإدارة العامة',
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.groups_outlined),
                        activeIcon: Icon(Icons.groups_rounded, color: activeColor),
                        label: 'الضباط',
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.analytics_outlined),
                        activeIcon: Icon(Icons.analytics_rounded, color: activeColor),
                        label: 'التقارير',
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.settings_suggest_outlined),
                        activeIcon: Icon(Icons.settings_suggest_rounded, color: activeColor),
                        label: 'الإعدادات',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}
