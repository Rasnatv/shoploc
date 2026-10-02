import 'package:flutter/material.dart';
import 'appcolors.dart';

/// Reusable text styles.
class AppText {
  AppText._();
  static const String serif = 'serif';

  static const TextStyle logo = TextStyle(
      fontSize: 28,
      fontFamily: serif,
      fontWeight: FontWeight.w600,
      color: AppColors.dark);
  static const TextStyle title = TextStyle(
      fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.dark);
  static const TextStyle subtitle = TextStyle(
      fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.dark);
  static const TextStyle body = TextStyle(fontSize: 13, color: AppColors.dark);
  static const TextStyle caption =
  TextStyle(fontSize: 12, color: AppColors.grey);
  static const TextStyle small = TextStyle(fontSize: 11, color: AppColors.grey);
  static const TextStyle price = TextStyle(
      fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.background,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.dark),
      titleTextStyle: TextStyle(
          color: AppColors.dark, fontSize: 17, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
        elevation: 0,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.dark,
        side: const BorderSide(color: AppColors.border),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: AppColors.dark,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.dark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
