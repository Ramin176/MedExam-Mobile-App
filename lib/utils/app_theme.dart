// lib/utils/app_theme.dart

import 'package:flutter/material.dart';

// رنگ های اصلی (ترکیب رنگ گرم و سرد)
class AppColors {
  static const Color primary = Color(0xFFFFA000); // Amber (عنبر)
  static const Color primaryDark = Color(0xFFF57C00); // نارنجی تیره
  static const Color background = Color(0xFFF5F5F5); // خاکستری روشن
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Colors.white;
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color card = Colors.white;
}

// تم اصلی برنامه
final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Vazirmatn', // اگر فونت فارسی دارید
  appBarTheme: const AppBarTheme(
    color: AppColors.primary,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.textLight),
    titleTextStyle: TextStyle(color: AppColors.textLight, fontSize: 20, fontWeight: FontWeight.bold),
  ),
  cardTheme: CardTheme(
    color: AppColors.card,
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: AppColors.primary,
    textTheme: ButtonTextTheme.primary,
  ),
  useMaterial3: true,
);