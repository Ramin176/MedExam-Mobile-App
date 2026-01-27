// lib/screens/quiz/quiz_start_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:med_exam_app/models/question.dart';
import 'package:med_exam_app/models/topic.dart';
import 'package:med_exam_app/screens/quiz/quiz_screen.dart';
import 'package:med_exam_app/utils/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- تنظیمات API ---
const String API_URL = "http://192.168.86.30:8000/api";

class QuizStartScreen extends StatefulWidget {
  final Topic topic;

  const QuizStartScreen({super.key, required this.topic});

  @override
  State<QuizStartScreen> createState() => _QuizStartScreenState();
}

class _QuizStartScreenState extends State<QuizStartScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  
  // وضعیت آزمون برای نمایش متن مناسب
  bool _isPracticeMode = false; // فعلاً پیش فرض آزمون اصلی است

  @override
  void initState() {
    super.initState();
    // در این مرحله نمی‌توانیم بفهمیم حالت تمرین است یا نه، در متد fetchQuestions مشخص می‌شود
    // فعلاً نمایش را بر اساس آزمون اصلی می‌گذاریم
  }

  // متد اصلی برای دریافت سوالات و چک کردن رمز استاد
  Future<void> _fetchQuestions({String? password}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null) return;

      Map<String, dynamic> queryParams = {};
      if (password != null && password.isNotEmpty) {
        queryParams['password'] = password;
      }

      final response = await Dio().get(
        '$API_URL/questions/${widget.topic.id}',
        queryParameters: queryParams,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      // اگر موفق بود
      if (response.statusCode == 200) {
        final List<dynamic> questionsJson = response.data['questions'];
        final List<Question> questions = questionsJson.map((json) => Question.fromJson(json)).toList();
        
        // --- هدایت به صفحه آزمون ---
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              topic: widget.topic,
              questions: questions,
              isPractice: _isPracticeMode, // ارسال حالت تمرین
            ),
          ),
        );
        
      }
    } on DioException catch (e) {
      String errorMessage = 'خطای ارتباط با سرور.';
      // اگر رمز عبور اشتباه باشد (کد 403)
      if (e.response?.statusCode == 403) {
        errorMessage = e.response!.data['message'] ?? 'رمز عبور استاد الزامی یا اشتباه است.';
        // در این مرحله، اگر خطا 403 نبود، یعنی وارد حالت تمرین شده است.
        // چون این API بر اساس وضعیت قبلی کاربر تصمیم می‌گیرد، ما می‌توانیم فرض کنیم
        // اگر کاربر قبلاً آزمون داده و رمز را نفرستاده، باید به صورت خودکار وارد شود.
        // برای حالت تمرین، نیازی به فیلد رمز نیست.
        setState(() {
          _isPracticeMode = true; // فرضی: اگر کاربر آزمون داده است
        });
      } else if (e.response != null) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }
      _showSnackBar(errorMessage, isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شروع آزمون'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // کارت عنوان فصل
            Card(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('عنوان:', style: TextStyle(color: AppColors.textLight, fontSize: 16)),
                    const SizedBox(height: 5),
                    Text(
                      widget.topic.title,
                      style: const TextStyle(color: AppColors.textLight, fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // بخش توضیحات
            const Text(
              '** توجه: برای ورود به آزمون اصلی، رمز عبور موقت استاد الزامی است. اگر قبلاً آزمون داده‌اید، می‌توانید بدون رمز وارد حالت تمرین شوید.',
              style: TextStyle(color: AppColors.textDark, fontSize: 14),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 30),

            // فیلد ورود رمز استاد
            _isPracticeMode 
                ? const SizedBox.shrink() // در حالت تمرین فیلد مخفی می‌شود
                : _buildPasswordField(),
            
            _isPracticeMode ? const SizedBox(height: 0) : const SizedBox(height: 30),

            // دکمه شروع آزمون
            SizedBox(
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () {
                        // اگر حالت تمرین فعال بود، بدون رمز وارد می‌شود
                        if (_isPracticeMode) {
                            _fetchQuestions();
                        } else {
                            // در غیر این صورت باید رمز وارد شود
                            _fetchQuestions(password: _passwordController.text);
                        }
                      },
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.textLight, strokeWidth: 3))
                    : const Icon(FontAwesomeIcons.circlePlay, size: 24),
                label: Text(
                  _isPracticeMode ? 'شروع تمرین نامحدود' : 'ورود و شروع آزمون',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPracticeMode ? AppColors.success : AppColors.primary,
                  foregroundColor: AppColors.textLight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // تابع کمکی برای ساخت فیلد رمز
  Widget _buildPasswordField() {
      return TextFormField(
          controller: _passwordController,
          obscureText: true,
          textAlign: TextAlign.right,
          keyboardType: TextInputType.text,
          style: const TextStyle(color: AppColors.textDark),
          decoration: InputDecoration(
              labelText: 'رمز عبور موقت استاد',
              labelStyle: const TextStyle(color: AppColors.textDark),
              prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Icon(FontAwesomeIcons.key, color: AppColors.primaryDark),
              ),
          ),
      );
  }
}