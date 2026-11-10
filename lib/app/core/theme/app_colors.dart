import 'package:flutter/material.dart';

/// Centralized color palette for the Shoploc application.
/// Incorporates Shoploc's official logo colors (Royal Blue & Vibrant Orange)
/// alongside premium women's fashion & boutique aesthetic tones.
class AppColors {
  AppColors._();

  // Official Shoploc Logo Colors
  static const Color brandBlue = Color(0xFF0082CA); // "Shop" vibrant blue
  static const Color brandOrange = Color(0xFFEE7003); // "Loc" vibrant orange
  static const Color brandGrey = Color(0xFF4A4A4A); // Handcart trolley charcoal grey

  // Primary Brand Theme Colors
  static const Color primary = Color(0xFF0082CA); // Shoploc Official Blue as Primary
  static const Color primaryDark = Color(0xFF00649C);
  static const Color primaryLight = Color(0xFF339BD5);
  static const Color primaryMuted = Color(0xFFE6F3FA);

  // Secondary & Accents
  static const Color secondary = Color(0xFFEE7003); // Shoploc Official Orange
  static const Color secondaryLight = Color(0xFFFFF0E6);
  static const Color accent = Color(0xFFEE7003);
  static const Color accentSoft = Color(0xFFFFF4EC);
  static const Color blush = Color(0xFFF8EDE8); // Subtle feminine warm blush
  static const Color sage = Color(0xFF6B8E70); // Olive / Sage

  // Backgrounds
  static const Color scaffoldBackground = Color(0xFFFAFAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF4F3EF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF8F7F4);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF6E6D6B);
  static const Color textTertiary = Color(0xFFA09F9D);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF8C8A87);

  // Status Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF0288D1);
  static const Color infoLight = Color(0xFFE1F5FE);

  // Borders & Dividers
  static const Color border = Color(0xFFE5E2DC);
  static const Color borderLight = Color(0xFFEFECE6);
  static const Color divider = Color(0xFFECEAE4);

  // Shadows
  static const Color shadowLight = Color(0x08000000);
  static const Color shadow = Color(0x0F000000);
  static const Color shadowMedium = Color(0x1A000000);

  // Product Badge Colors
  static const Color discountBadge = Color(0xFFEE7003); // Match brand orange
  static const Color newBadge = Color(0xFF0082CA); // Match brand blue
  static const Color bestSellerBadge = Color(0xFFC07A18);
  static const Color trendingBadge = Color(0xFF884EA0);

  // Shimmer / Placeholder
  static const Color shimmerBase = Color(0xFFECEAE5);
  static const Color shimmerHighlight = Color(0xFFF7F5F0);
}
