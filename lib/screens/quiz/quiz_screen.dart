// lib/screens/quiz/quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:med_exam_app/models/question.dart';
import 'package:med_exam_app/models/topic.dart';
import 'package:med_exam_app/utils/app_theme.dart';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:med_exam_app/screens/home_screen.dart'; // برای بازگشت به صفحه اصلی

// --- تنظیمات API ---
const String API_URL = "http://192.168.86.30:8000/api";

class QuizScreen extends StatefulWidget {
  final Topic topic;
  final List<Question> questions;
  final bool isPractice; // حالت تمرین

  const QuizScreen({
    super.key,
    required this.topic,
    required this.questions,
    required this.isPractice,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _correctCount = 0;
  Map<int, String> _userAnswers = {}; // {Q_ID: 'A' or 'B' or 'C' or 'D'}
  
  // نگهداری لیست گزینه‌های رندوم شده برای هر سوال
  // {Q_ID: ['A', 'D', 'B', 'C']}
  Map<int, List<String>> _shuffledOptionsMap = {}; 

  @override
  void initState() {
    super.initState();
    // در شروع، گزینه‌های تمام سوالات را رندوم‌سازی می‌کنیم
    _shuffleAllOptions();
  }

  // --- الگوریتم رندوم‌سازی (Shuffle) گزینه‌ها ---
  void _shuffleAllOptions() {
    final random = Random();
    for (var question in widget.questions) {
      // ساخت لیست گزینه‌ها
      final List<String> originalKeys = ['A', 'B', 'C', 'D'];
      
      // اگر حالت تمرین فعال بود، گزینه‌ها را جابجا می‌کنیم.
      if (widget.isPractice) {
          originalKeys.shuffle(random); 
      }
      
      _shuffledOptionsMap[question.id] = originalKeys;
    }
  }

  // گرفتن متن گزینه‌ها بر اساس کلید رندوم شده
  String _getOptionText(Question question, String key) {
      switch (key) {
          case 'A': return question.optionA;
          case 'B': return question.optionB;
          case 'C': return question.optionC;
          case 'D': return question.optionD;
          default: return '';
      }
  }

  // منطق انتخاب پاسخ
  void _selectAnswer(String originalKey) {
    if (widget.isPractice) {
        // در حالت تمرین، فقط بازخورد می‌دهیم و جلو می‌رویم. نمره ثبت نمی‌شود.
         _showPracticeFeedback(originalKey);
         return;
    }

    setState(() {
      final currentQuestion = widget.questions[_currentQuestionIndex];
      _userAnswers[currentQuestion.id] = originalKey; 

      // برای آزمون اصلی، بلافاصله به سوال بعدی می‌رویم
      if (_currentQuestionIndex < widget.questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        // اگر سوال آخر بود، آزمون تمام شده است
        _finishQuiz();
      }
    });
  }
  
  // بازخورد برای حالت تمرین
  void _showPracticeFeedback(String originalKey) {
      final currentQuestion = widget.questions[_currentQuestionIndex];
      final isCorrect = originalKey == currentQuestion.correctAnswer;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCorrect ? 'پاسخ صحیح!' : 'پاسخ اشتباه است. پاسخ درست: ${_getOptionText(currentQuestion, currentQuestion.correctAnswer)}',
            textAlign: TextAlign.right,
          ),
          backgroundColor: isCorrect ? AppColors.success : AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // رفتن به سوال بعدی بعد از بازخورد
      Future.delayed(const Duration(seconds: 2), () {
          if (_currentQuestionIndex < widget.questions.length - 1) {
            setState(() {
              _currentQuestionIndex++;
            });
          } else {
              // اگر سوال آخر بود، دوباره به اول می‌رویم (تمرین نامحدود)
              setState(() {
                  _currentQuestionIndex = 0;
                  _shuffleAllOptions(); // رندوم‌سازی مجدد گزینه‌ها
              });
              _showSnackBar('تمرین این فصل به اتمام رسید. مجدداً شروع شد.');
          }
      });
  }

  // پایان آزمون و ارسال نمره به API
  void _finishQuiz() {
    if (widget.isPractice) return; // در حالت تمرین نمره ثبت نمی‌شود

    // محاسبه نمره
    int correctCount = 0;
    for (var question in widget.questions) {
      if (_userAnswers[question.id] == question.correctAnswer) {
        correctCount++;
      }
    }
    _correctCount = correctCount;

    // ارسال به API
    _submitResultToApi();
  }
  
  // ارسال نمره به API (با منطق نمره از ۲۰)
  Future<void> _submitResultToApi() async {
      try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('authToken');
          if (token == null) return;
          
          await Dio().post(
              '$API_URL/submit-result',
              data: {
                  'topic_id': widget.topic.id,
                  'total_questions': widget.questions.length,
                  'correct_answers': _correctCount,
              },
              options: Options(
                  headers: {'Authorization': 'Bearer $token'},
              ),
          );
          
          _showSnackBar('نتایج آزمون شما با موفقیت ثبت شد!', isError: false);
          // هدایت به صفحه اصلی بعد از ثبت نمره
          if(mounted) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (Route<dynamic> route) => false,
              );
          }

      } on DioException catch (e) {
          print("Error submitting result: $e");
          _showSnackBar('خطا در ثبت نمره. لطفاً اتصال اینترنت را چک کنید.', isError: true);
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
    final currentQuestion = widget.questions[_currentQuestionIndex];
    final shuffledKeys = _shuffledOptionsMap[currentQuestion.id]!;
    
    // رنگ عنوان بر اساس حالت آزمون/تمرین
    final titleColor = widget.isPractice ? AppColors.success : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: titleColor,
        title: Text(
          widget.isPractice ? 'حالت تمرین (نامحدود)' : 'آزمون اصلی',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // کارت پیشرفت
            Card(
              color: titleColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'سوال ${_currentQuestionIndex + 1} از ${widget.questions.length}',
                  style: TextStyle(color: titleColor, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // متن سوال
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // نمایش تصویر (اگر وجود دارد)
                    if (currentQuestion.image != null) 
                        Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child:
                            //  Image.network(
                            //     // باید آدرس کامل سرور را بدهیم
                            //     'http://192.168.86.30:8000/storage/questions/${currentQuestion.image}', 
                            //     height: 200, 
                            //     fit: BoxFit.contain
                            // ),
                            Image.network(
  'http://192.168.86.30:8000/storage/questions/${currentQuestion.image}', 
  height: 200,
  fit: BoxFit.contain,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return SizedBox(
      height: 200,
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
              : null,
        ),
      ),
    );
  },
  errorBuilder: (context, error, stackTrace) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
            SizedBox(height: 5),
            Text("تصویر موجود نیست", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  },
),

                        ),

                    Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          currentQuestion.questionText,
                          style: const TextStyle(fontSize: 18, height: 1.5, color: AppColors.textDark),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // گزینه‌ها
                    ...shuffledKeys.map((key) {
                      final optionText = _getOptionText(currentQuestion, key);
                      
                      // رنگ‌بندی برای حالت تمرین
                      Color? tileColor = Colors.white;
                      if (widget.isPractice && _userAnswers[currentQuestion.id] != null) {
                          if (key == currentQuestion.correctAnswer) {
                              tileColor = AppColors.success.withOpacity(0.2);
                          } else if (key == _userAnswers[currentQuestion.id]) {
                              tileColor = AppColors.error.withOpacity(0.2);
                          }
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          color: tileColor,
                          child: ListTile(
                            onTap: () => _selectAnswer(key),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            title: Text(
                              optionText,
                              style: const TextStyle(fontSize: 16, color: AppColors.textDark),
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                            ),
                            leading: CircleAvatar(
                                backgroundColor: titleColor,
                                child: Text(key, style: const TextStyle(color: AppColors.textLight)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // دکمه بعدی/پایان
      bottomNavigationBar: widget.isPractice ? null : Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
            onPressed: () {
                 if (_currentQuestionIndex < widget.questions.length - 1) {
                    _currentQuestionIndex++;
                 } else {
                     // سوال آخر
                     _finishQuiz();
                 }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: AppColors.textLight,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text(
                _currentQuestionIndex < widget.questions.length - 1 ? 'سوال بعدی' : 'پایان آزمون و ثبت نمره',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
        ),
    ),
    );
  }
}