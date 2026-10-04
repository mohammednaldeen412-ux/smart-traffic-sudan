import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/locale_provider.dart';
import '../core/services/theme_provider.dart';

/// شريط علوي صغير لتبديل اللغة (ع / EN) والوضع (فاتح / داكن)
/// يُستخدم في شاشات الدخول والتفعيل قبل تسجيل الدخول.
class AuthTopBar extends StatelessWidget {
  /// true عندما يوضع فوق خلفية داكنة ثابتة (مثل بوابة الضباط)
  final bool forceLight;

  const AuthTopBar({super.key, this.forceLight = false});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final theme = context.watch<ThemeProvider>();
    final isDark = forceLight || Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white : const Color(0xFF0F172A);
    final bg = isDark ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.05);
    final border = isDark ? Colors.white24 : Colors.black12;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // زر اللغة
        _Pill(
          bg: bg,
          border: border,
          onTap: () => locale.toggleLanguage(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language_rounded, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(
                locale.isArabic ? 'English' : 'العربية',
                style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // زر الوضع
        _Pill(
          bg: bg,
          border: border,
          onTap: () => theme.toggleTheme(),
          child: Icon(
            theme.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 18,
            color: fg,
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color bg;
  final Color border;
  const _Pill({required this.child, required this.onTap, required this.bg, required this.border});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
          ),
          child: child,
        ),
      ),
    );
  }
}
