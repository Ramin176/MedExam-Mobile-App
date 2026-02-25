// // lib/utils/app_theme.dart

// import 'package:flutter/material.dart';

// // رنگ های اصلی (ترکیب رنگ گرم و سرد)
// class AppColors {
//   static const Color primary = Color(0xFFFFA000); // Amber (عنبر)
//   static const Color primaryDark = Color(0xFFF57C00); // نارنجی تیره
//   static const Color background = Color(0xFFF5F5F5); // خاکستری روشن
//   static const Color textDark = Color(0xFF212121);
//   static const Color textLight = Colors.white;
//   static const Color success = Color(0xFF4CAF50);
//   static const Color error = Color(0xFFF44336);
//   static const Color card = Colors.white;
// }

// // تم اصلی برنامه
// final ThemeData appTheme = ThemeData(
//   primaryColor: AppColors.primary,
//   scaffoldBackgroundColor: AppColors.background,
//   fontFamily: 'Vazirmatn', // اگر فونت فارسی دارید
//   appBarTheme: const AppBarTheme(
//     color: AppColors.primary,
//     elevation: 0,
//     iconTheme: IconThemeData(color: AppColors.textLight),
//     titleTextStyle: TextStyle(color: AppColors.textLight, fontSize: 20, fontWeight: FontWeight.bold),
//   ),
//   cardTheme: CardTheme(
//     color: AppColors.card,
//     elevation: 3,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//   ),
//   inputDecorationTheme: InputDecorationTheme(
//     filled: true,
//     fillColor: Colors.white,
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(10),
//       borderSide: BorderSide.none,
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(10),
//       borderSide: const BorderSide(color: AppColors.primary, width: 2),
//     ),
//   ),
//   buttonTheme: const ButtonThemeData(
//     buttonColor: AppColors.primary,
//     textTheme: ButtonTextTheme.primary,
//   ),
//   useMaterial3: true,
// );
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1A535C); // سبز-آبی تیره حرفه‌ای
    static const Color primaryDark = Color(0xFF0A365C); // اضافه شد

  static const Color secondary = Color(0xFF4ECDC4); // فیروزه‌ای ملایم
  static const Color accent = Color(0xFFFF6B6B); // قرمز مرجانی برای موارد خاص
  static const Color background = Color(0xFFF7F9FC); // پس‌زمینه بسیار روشن و آرام‌بخش
  static const Color surface = Colors.white;
   static const Color textLight = Colors.white;
  static const Color textDark = Color(0xFF2D3436);
  static const Color textGrey = Color(0xFF636E72);
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Vazirmatn', // حتما فونت وزیر را در pubspec داشته باشید
  
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
    ),
  ),

  cardTheme: CardTheme(
    color: AppColors.surface,
    elevation: 2,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.secondary, width: 2),
    ),
  ),
);