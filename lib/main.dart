// lib/main.dart

import 'package:flutter/material.dart';
import 'package:med_exam_app/auth/login_screen.dart';
import 'package:med_exam_app/utils/app_theme.dart';
import 'package:med_exam_app/screens/splash_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:med_exam_app/models/question.dart'; 
import 'package:med_exam_app/models/topic.dart'; 
import 'package:med_exam_app/models/student_class.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ۱. مقداردهی اولیه Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path); 
  
  // ۲. رجیستر کردن آداپتورهای Hive
  Hive.registerAdapter(QuestionAdapter());
  Hive.registerAdapter(TopicAdapter());
  Hive.registerAdapter(SubjectAdapter()); 
  Hive.registerAdapter(StudentClassAdapter()); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سیستم آزمون هوشمند',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const SplashScreen(), // شروع از Splash Screen
      routes: {
         '/login': (context) => const LoginScreen(),
      },
    );
  }
}