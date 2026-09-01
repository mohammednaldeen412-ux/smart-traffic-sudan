import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/services/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import 'officer_hub_screen.dart';
import 'officer_shift_history_screen.dart';
import 'plate_lookup_screen.dart';
import 'ticket_issuer_screen.dart';

class OfficerNavigationWrapper extends StatefulWidget {
  final int initialIndex;

  const OfficerNavigationWrapper({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<OfficerNavigationWrapper> createState() => _OfficerNavigationWrapperState();
}

class _OfficerNavigationWrapperState extends State<OfficerNavigationWrapper> {
  late int _currentIndex;
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

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

    final List<Widget> screens = [
      OfficerHubScreen(onNavigateTab: _onTabTapped),
      const PlateLookupScreen(),
      const TicketIssuerScreen(),
      const OfficerShiftHistoryScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
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
          // Exit app cleanly to phone home screen
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
      backgroundColor: bg,
      extendBody: true, // يمتد المحتوى خلف شريط التنقل الزجاجي
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
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
                    currentIndex: _currentIndex,
                    onTap: _onTabTapped,
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
                        icon: const Icon(Icons.shield_outlined),
                        activeIcon: Icon(Icons.shield_rounded, color: activeColor),
                        label: 'مركز القيادة',
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.search_rounded),
                        activeIcon: Icon(Icons.search_rounded, color: activeColor),
                        label: 'فحص اللوحات',
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.edit_note_outlined),
                        activeIcon: Icon(Icons.edit_note_rounded, color: activeColor),
                        label: 'إصدار مخالفة',
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.history_rounded),
                        activeIcon: Icon(Icons.history_rounded, color: activeColor),
                        label: 'سجل الوردية',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      ), // close PopScope
    );
  }
}
