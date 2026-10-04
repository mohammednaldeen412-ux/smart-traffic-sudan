import 'package:flutter/material.dart';

/// نوع الواجهة لتحديد هوية الخلفية
enum AppRole { citizen, officer, auth }

/// خلفية موحدة للتطبيق تتغير حسب (الدور) و(الوضع الفاتح/الداكن)
/// مصممة لتُظهر التأثير الزجاجي (Glassmorphism) بوضوح عبر دوائر لونية ناعمة خلف البطاقات.
class AppBackground extends StatelessWidget {
  final AppRole role;
  final Widget child;

  const AppBackground({super.key, required this.role, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _palette(role, isDark);

    return Stack(
      children: [
        // التدرج الأساسي
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: palette.base,
              ),
            ),
          ),
        ),
        // دوائر الإضاءة (هي ما يعطي الزجاج عمقه)
        _blob(top: -120, right: -80, size: 320, color: palette.blobA),
        _blob(top: 260, left: -110, size: 280, color: palette.blobB),
        _blob(bottom: -100, right: -60, size: 300, color: palette.blobC),
        child,
      ],
    );
  }

  Widget _blob({double? top, double? left, double? right, double? bottom, required double size, required Color color}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
          ),
        ),
      ),
    );
  }

  static _BgPalette _palette(AppRole role, bool isDark) {
    switch (role) {
      // المواطن: طابع مدني هادئ (أزرق سماوي + أخضر زمردي)
      case AppRole.citizen:
        return isDark
            ? const _BgPalette(
                base: [Color(0xFF0F172A), Color(0xFF0A0E17)],
                blobA: Color(0x553B82F6),
                blobB: Color(0x4410B981),
                blobC: Color(0x446366F1),
              )
            : const _BgPalette(
                base: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
                blobA: Color(0x6693C5FD),
                blobB: Color(0x556EE7B7),
                blobC: Color(0x55A5B4FC),
              );
      // الضابط: طابع أمني رسمي (كحلي عميق + كهرماني + أحمر خافت للطوارئ)
      case AppRole.officer:
        return isDark
            ? const _BgPalette(
                base: [Color(0xFF0B1426), Color(0xFF05080F)],
                blobA: Color(0x551E40AF),
                blobB: Color(0x44F59E0B),
                blobC: Color(0x33EF4444),
              )
            : const _BgPalette(
                base: [Color(0xFFE0E7FF), Color(0xFFF1F5F9)],
                blobA: Color(0x6693C5FD),
                blobB: Color(0x55FCD34D),
                blobC: Color(0x44FCA5A5),
              );
      // شاشات الدخول: محايدة
      case AppRole.auth:
        return isDark
            ? const _BgPalette(
                base: [Color(0xFF1E293B), Color(0xFF0A0E17)],
                blobA: Color(0x553B82F6),
                blobB: Color(0x33D4AF37),
                blobC: Color(0x336366F1),
              )
            : const _BgPalette(
                base: [Color(0xFFF1F5F9), Color(0xFFFFFFFF)],
                blobA: Color(0x5593C5FD),
                blobB: Color(0x44FDE68A),
                blobC: Color(0x44C7D2FE),
              );
    }
  }
}

class _BgPalette {
  final List<Color> base;
  final Color blobA;
  final Color blobB;
  final Color blobC;
  const _BgPalette({required this.base, required this.blobA, required this.blobB, required this.blobC});
}

/// ألوان النصوص والزجاج المناسبة للوضع الحالي
class GlassColors {
  final bool isDark;
  GlassColors.of(BuildContext context) : isDark = Theme.of(context).brightness == Brightness.dark;

  Color get text => isDark ? Colors.white : const Color(0xFF0F172A);
  Color get textMuted => isDark ? Colors.white70 : const Color(0xFF475569);
  Color get textFaint => isDark ? Colors.white54 : const Color(0xFF64748B);
  /// لون صبغة الزجاج المحايد
  Color get glassTint => isDark ? Colors.white : const Color(0xFF1E3A8A);
  /// شفافية الزجاج المحايد (أقل في الفاتح حتى لا يبهت)
  double get glassOpacity => isDark ? 0.12 : 0.06;
  Color get iconOnGlass => isDark ? Colors.white : const Color(0xFF1E293B);
}
