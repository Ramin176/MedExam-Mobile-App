import 'package:flutter/material.dart';
import 'package:med_exam_app/models/question.dart';
import 'package:med_exam_app/models/topic.dart';
import 'package:med_exam_app/utils/app_theme.dart';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:med_exam_app/screens/home_screen.dart';

const String API_URL = "https://medexam.saberyinstitute.com/api";

// const String API_URL = "http://192.168.173.30:8000/api"; 
class QuizScreen extends StatefulWidget {
  final Topic topic;
  final List<Question> questions;
  final bool isPractice;
  const QuizScreen({super.key, required this.topic, required this.questions, required this.isPractice});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  Map<int, String> _userAnswers = {};
  Map<int, List<String>> _shuffledOptionsMap = {};
  bool _showExplanation = false; 

  @override
  void initState() { 
    super.initState(); 
    _shuffleAllOptions(); 
  }

  // ۱. قابلیت جابجایی گزینه‌ها در هر بار ورود
  void _shuffleAllOptions() {
    final random = Random();
    for (var question in widget.questions) {
      final List<String> keys = question.type == 'true_false' ? ['A', 'B'] : ['A', 'B', 'C', 'D'];
      keys.shuffle(random);
      _shuffledOptionsMap[question.id] = keys;
    }
  }

  String _getOptionText(Question question, String key) {
    if (question.type == 'true_false') {
      return key == 'A' ? (question.optionA.isEmpty ? 'صحیح' : question.optionA) : (question.optionB.isEmpty ? 'غلط' : question.optionB);
    }
    switch (key) {
      case 'A': return question.optionA;
      case 'B': return question.optionB;
      case 'C': return question.optionC;
      case 'D': return question.optionD;
      default: return '';
    }
  }

  void _selectAnswer(String key) {
    final currentQuestion = widget.questions[_currentQuestionIndex];
    setState(() {
       _userAnswers[currentQuestion.id] = key; 
       _showExplanation = true; // نمایش تشریح بلافاصله
    });

    if (widget.isPractice) {
      final isCorrect = key == currentQuestion.correctAnswer;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isCorrect ? '✅ پاسخ صحیح!' : '❌ پاسخ اشتباه است', textAlign: TextAlign.right),
          backgroundColor: isCorrect ? AppColors.success : AppColors.error,
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  // ۲. حل مشکل قفل شدن: ریست کردن وضعیت برای سوال بعد
  void _nextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _showExplanation = false; // 👈 ریست کردن تشریح برای سوال جدید
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() async {
    int correctCount = 0;
    for (var q in widget.questions) { if (_userAnswers[q.id] == q.correctAnswer) correctCount++; }
    if (!widget.isPractice) { await _submitResultToApi(correctCount); }
    _showResultDialog(correctCount);
  }

  Future<void> _submitResultToApi(int correct) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      await Dio().post('$API_URL/submit-result', data: {'topic_id': widget.topic.id, 'total_questions': widget.questions.length, 'correct_answers': correct},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) { debugPrint(e.toString()); }
  }

  void _showResultDialog(int correct) {
    double percent = (correct / widget.questions.length) * 100;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("نتیجه نهایی", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("نمره شما: ${(correct / widget.questions.length * 20).toStringAsFixed(1)} از ۲۰"),
            const Divider(height: 20),
            Text(percent >= 50 ? "🎉 موفق شدید" : "⚠️ نیاز به مطالعه بیشتر", 
              style: TextStyle(fontWeight: FontWeight.bold, color: percent >= 50 ? AppColors.success : AppColors.error)),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false), child: const Text("بازگشت به خانه"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[_currentQuestionIndex];
    final shuffledKeys = _shuffledOptionsMap[currentQuestion.id]!;
    final themeColor = widget.isPractice ? AppColors.secondary : AppColors.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: themeColor,
          title: Text(widget.isPractice ? 'حالت تمرین' : 'آزمون اصلی'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(6),
            child: LinearProgressIndicator(value: (_currentQuestionIndex + 1) / widget.questions.length, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Colors.white)),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('سوال ${_currentQuestionIndex + 1} از ${widget.questions.length}', style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              if (currentQuestion.fullImageUrl != null)
                Container(
                  width: double.infinity, margin: const EdgeInsets.only(bottom: 20),
                  child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(currentQuestion.fullImageUrl!, fit: BoxFit.cover)),
                ),
              Text(currentQuestion.questionText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.5)),
              const SizedBox(height: 30),
              
              // نمایش گزینه‌ها با ترتیب جابجا شده
              ...shuffledKeys.map((key) => _buildOption(key, currentQuestion, themeColor)),
              
              // بخش تشریح پاسخ تمیز شده
              if (_showExplanation && currentQuestion.explanation != null && currentQuestion.explanation!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📘 تشریح و توضیح پاسخ:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      const SizedBox(height: 8),
                      Text(currentQuestion.explanation!, style: const TextStyle(fontSize: 14, height: 1.5)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: _userAnswers.containsKey(currentQuestion.id) ? _nextQuestion : null,
            child: Text(_currentQuestionIndex < widget.questions.length - 1 ? 'سوال بعدی' : 'مشاهده نتیجه نهایی'),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(String key, Question question, Color themeColor) {
    bool isSelected = _userAnswers[question.id] == key;
    bool isCorrect = key == question.correctAnswer;
    
    Color bgColor = Colors.white;
    if (_showExplanation) {
        if (isCorrect) bgColor = Colors.green.shade100;
        else if (isSelected) bgColor = Colors.red.shade100;
    } else if (isSelected) {
        bgColor = themeColor.withOpacity(0.2);
    }

    return GestureDetector(
      onTap: _showExplanation ? null : () => _selectAnswer(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _showExplanation ? (isCorrect ? Colors.green : (isSelected ? Colors.red : Colors.grey.shade300)) : (isSelected ? themeColor : Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 14, backgroundColor: isSelected ? themeColor : Colors.grey.shade200, child: Text(key, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12))),
            const SizedBox(width: 15),
            Expanded(child: Text(_getOptionText(question, key))),
            if (_showExplanation && isCorrect) const Icon(Icons.check_circle, color: Colors.green),
            if (_showExplanation && isSelected && !isCorrect) const Icon(Icons.cancel, color: Colors.red),
          ],
        ),
      ),
    );
  }
}