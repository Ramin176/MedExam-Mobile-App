// // lib/screens/splash_screen.dart

// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:med_exam_app/screens/home_screen.dart';
// import 'package:med_exam_app/utils/app_theme.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   // چک کردن توکن برای لاگین خودکار
//   void _checkLoginStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('authToken');

//     await Future.delayed(const Duration(seconds: 3)); // نمایش Splash به مدت ۳ ثانیه

//     if (token != null && token.isNotEmpty) {
//       // اگر توکن داشت، مستقیم به صفحه اصلی می‌رود
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const HomeScreen()),
//       );
//     } else {
//       // در غیر این صورت به صفحه لاگین می‌رود
//       Navigator.pushReplacementNamed(context, '/login');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [AppColors.primaryDark, AppColors.primary],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(FontAwesomeIcons.graduationCap, size: 100, color: AppColors.textLight),
//               SizedBox(height: 20),
//               Text(
//                 'سیستم آزمون هوشمند',
//                 style: TextStyle(
//                   color: AppColors.textLight,
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 'آفلاین، سریع و امن',
//                 style: TextStyle(
//                   color: AppColors.textLight,
//                   fontSize: 18,
//                 ),
//               ),
//               SizedBox(height: 50),
//               CircularProgressIndicator(color: AppColors.textLight),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:med_exam_app/screens/home_screen.dart';
import 'package:med_exam_app/utils/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // لوگوی برنامه با سایه ملایم
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(FontAwesomeIcons.userNurse, size: 100, color: Colors.white),
            ),
            const SizedBox(height: 25),
            const Text(
              'سیستم آزمون پرتو',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 10),
            Text(
              'تخصصی، سریع و آفلاین',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
            ),
            const Spacer(),
            const CircularProgressIndicator(color: AppColors.secondary),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}