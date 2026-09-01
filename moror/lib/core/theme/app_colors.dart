import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ===== DARK MODE =====
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color card = Color(0xFF1E293B);
  static const Color cardElevated = Color(0xFF334155);
  static const Color cardBorder = Color(0xFF334155);
  static const Color inputBackground = Color(0xFF0F172A);

  // PRIMARY (Calm Blue instead of harsh yellow/gold)
  static const Color primary = Color(0xFF3B82F6);
  static const Color goldPrimary = Color(0xFF3B82F6); // Kept for backwards compatibility
  static const Color goldLight = Color(0xFF60A5FA);
  static const Color goldDark = Color(0xFF2563EB);
  static const Color goldMuted = Color(0xFF1D4ED8);
  static const Color goldGlow = Color(0x333B82F6);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient sovereignHeaderGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldBorderGradient = LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0x223B82F6), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color success = Color(0xFF10B981);
  static const Color successGlow = Color(0x3310B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorGlow = Color(0x33EF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textGold = Color(0xFF60A5FA);

  static const Color divider = Color(0xFF334155);
  static const Color glassFill = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x263B82F6);

  // ===== LIGHT MODE =====
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFF1F5F9);
  static const Color lightCardBorder = Color(0xFFE2E8F0);
  static const Color lightInputBackground = Color(0xFFF1F5F9);
  static const Color lightDivider = Color(0xFFE2E8F0);

  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  static const LinearGradient lightCardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient lightHeaderGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color lightGlassFill = Color(0x0A000000);
  static const Color lightGlassBorder = Color(0x1A3B82F6);
}
