
// // lib/screens/quiz/quiz_screen.dart
// import 'package:flutter/material.dart';
// import 'package:med_exam_app/models/question.dart';
// import 'package:med_exam_app/models/topic.dart';
// import 'package:med_exam_app/utils/app_theme.dart';
// import 'dart:math';
// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:med_exam_app/screens/home_screen.dart';

// const String API_URL = "https://medexam.saberyinstitute.com/api";

// class QuizScreen extends StatefulWidget {
//   final Topic topic;
//   final List<Question> questions;
//   final bool isPractice;

//   const QuizScreen({
//     super.key,
//     required this.topic,
//     required this.questions,
//     required this.isPractice,
//   });

//   @override
//   State<QuizScreen> createState() => _QuizScreenState();
// }

// class _QuizScreenState extends State<QuizScreen> {
//   int _currentQuestionIndex = 0;
//   Map<int, String> _userAnswers = {};
//   Map<int, List<String>> _shuffledOptionsMap = {};

//   @override
//   void initState() {
//     super.initState();
//     _shuffleAllOptions();
//   }

//   void _shuffleAllOptions() {
//     final random = Random();
//     for (var question in widget.questions) {
//       final List<String> keys = question.type == 'true_false' ? ['A', 'B'] : ['A', 'B', 'C', 'D'];
//       if (widget.isPractice) keys.shuffle(random);
//       _shuffledOptionsMap[question.id] = keys;
//     }
//   }

//   String _getOptionText(Question question, String key) {
//     if (question.type == 'true_false') {
//       return key == 'A' ? (question.optionA.isEmpty ? 'صحیح' : question.optionA) : (question.optionB.isEmpty ? 'غلط' : question.optionB);
//     }
//     switch (key) {
//       case 'A': return question.optionA;
//       case 'B': return question.optionB;
//       case 'C': return question.optionC;
//       case 'D': return question.optionD;
//       default: return '';
//     }
//   }

//   void _selectAnswer(String key) {
//     final currentQuestion = widget.questions[_currentQuestionIndex];
    
//     if (widget.isPractice) {
//       _showPracticeFeedback(key, currentQuestion);
//     } else {
//       setState(() {
//         _userAnswers[currentQuestion.id] = key;
//       });
//     }
//   }

//   void _showPracticeFeedback(String key, Question currentQuestion) {
//     final isCorrect = key == currentQuestion.correctAnswer;
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(isCorrect ? '✅ پاسخ صحیح!' : '❌ اشتباه! پاسخ درست: ${_getOptionText(currentQuestion, currentQuestion.correctAnswer)}', textAlign: TextAlign.right),
//         backgroundColor: isCorrect ? Colors.green : Colors.red,
//         duration: const Duration(milliseconds: 1500),
//       ),
//     );

//     Future.delayed(const Duration(milliseconds: 1600), () {
//       if (_currentQuestionIndex < widget.questions.length - 1) {
//         setState(() => _currentQuestionIndex++);
//       } else {
//         _finishQuiz();
//       }
//     });
//   }

//   void _finishQuiz() async {
//     int correctCount = 0;
//     for (var q in widget.questions) {
//       if (_userAnswers[q.id] == q.correctAnswer) correctCount++;
//     }

//     if (!widget.isPractice) {
//       await _submitResultToApi(correctCount);
//     }
//     _showResultDialog(correctCount);
//   }

//   Future<void> _submitResultToApi(int correct) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('authToken');
//       await Dio().post(
//         '$API_URL/submit-result',
//         data: {
//           'topic_id': widget.topic.id,
//           'total_questions': widget.questions.length,
//           'correct_answers': correct,
//         },
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );
//     } catch (e) { print("Error submitting: $e"); }
//   }

//   void _showResultDialog(int correct) {
//     double percent = (correct / widget.questions.length) * 100;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text("نتیجه آزمون", textAlign: TextAlign.center),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text("تعداد کل سوالات: ${widget.questions.length}"),
//             Text("پاسخ‌های صحیح: $correct", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
//             Text("نمره نهایی: ${(correct / widget.questions.length * 20).toStringAsFixed(1)} از ۲۰"),
//             const SizedBox(height: 20),
//             Text(percent >= 50 ? "🎉 تبریک! کامیاب شدید" : "⚠️ تلاش بیشتر لازم است"),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false),
//             child: const Text("بازگشت به خانه"),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentQuestion = widget.questions[_currentQuestionIndex];
//     final shuffledKeys = _shuffledOptionsMap[currentQuestion.id]!;
//     final titleColor = widget.isPractice ? Colors.green : AppColors.primary;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: titleColor,
//         title: Text(widget.isPractice ? 'حالت تمرین (بدون ثبت نمره)' : 'آزمون اصلی'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             LinearProgressIndicator(value: (_currentQuestionIndex + 1) / widget.questions.length, color: titleColor),
//             const SizedBox(height: 20),
//             // نمایش عکس سوال (اگر وجود داشت)
//             if (currentQuestion.fullImageUrl != null)
//               Container(
//                 margin: const EdgeInsets.only(bottom: 15),
//                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300)),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: Image.network(
//                     currentQuestion.fullImageUrl!,
//                     loadingBuilder: (context, child, progress) => progress == null ? child : const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
//                     errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
//                   ),
//                 ),
//               ),
//             Text(currentQuestion.questionText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.right, textDirection: TextDirection.rtl),
//             const SizedBox(height: 30),
//             ...shuffledKeys.map((key) => Card(
//               color: _userAnswers[currentQuestion.id] == key ? titleColor.withOpacity(0.2) : Colors.white,
//               child: ListTile(
//                 title: Text(_getOptionText(currentQuestion, key), textAlign: TextAlign.right),
//                 onTap: () => _selectAnswer(key),
//               ),
//             )),
//           ],
//         ),
//       ),
//       bottomNavigationBar: widget.isPractice ? null : Padding(
//         padding: const EdgeInsets.all(20),
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, minimumSize: const Size(double.infinity, 50)),
//           onPressed: _userAnswers.containsKey(currentQuestion.id) 
//             ? () => _currentQuestionIndex < widget.questions.length - 1 ? setState(() => _currentQuestionIndex++) : _finishQuiz()
//             : null,
//           child: Text(_currentQuestionIndex < widget.questions.length - 1 ? 'سوال بعدی' : 'پایان و ثبت نمره'),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:med_exam_app/models/question.dart';
import 'package:med_exam_app/models/topic.dart';
import 'package:med_exam_app/utils/app_theme.dart';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:med_exam_app/screens/home_screen.dart';

const String API_URL = "https://medexam.saberyinstitute.com/api";

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

  @override
  void initState() { super.initState(); _shuffleAllOptions(); }

  void _shuffleAllOptions() {
    final random = Random();
    for (var question in widget.questions) {
      final List<String> keys = question.type == 'true_false' ? ['A', 'B'] : ['A', 'B', 'C', 'D'];
      if (widget.isPractice) keys.shuffle(random);
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
    if (widget.isPractice) { _showPracticeFeedback(key, currentQuestion); } 
    else { setState(() { _userAnswers[currentQuestion.id] = key; }); }
  }

  void _showPracticeFeedback(String key, Question currentQuestion) {
    final isCorrect = key == currentQuestion.correctAnswer;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? '✅ پاسخ صحیح!' : '❌ اشتباه! پاسخ درست: ${_getOptionText(currentQuestion, currentQuestion.correctAnswer)}', textAlign: TextAlign.right),
        backgroundColor: isCorrect ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (_currentQuestionIndex < widget.questions.length - 1) { setState(() => _currentQuestionIndex++); } 
      else { _finishQuiz(); }
    });
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
    } catch (e) { print(e); }
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
            _buildResultRow("تعداد کل سوالات", "${widget.questions.length}"),
            _buildResultRow("پاسخ‌های صحیح", "$correct", color: AppColors.success),
            _buildResultRow("نمره از ۲۰", (correct / widget.questions.length * 20).toStringAsFixed(1)),
            const Divider(height: 30),
            Text(percent >= 50 ? "🎉 تبریک! موفق شدید" : "⚠️ نیاز به مطالعه بیشتر", style: TextStyle(fontWeight: FontWeight.bold, color: percent >= 50 ? AppColors.success : AppColors.error)),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false), child: const Text("بازگشت به خانه"))
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color))]),
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
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300)),
                  child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(currentQuestion.fullImageUrl!, fit: BoxFit.cover)),
                ),
              Text(currentQuestion.questionText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.5)),
              const SizedBox(height: 30),
              ...shuffledKeys.map((key) => _buildOption(key, currentQuestion, themeColor)),
            ],
          ),
        ),
        bottomNavigationBar: widget.isPractice ? null : Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: _userAnswers.containsKey(currentQuestion.id) ? () {
              if (_currentQuestionIndex < widget.questions.length - 1) { setState(() => _currentQuestionIndex++); } else { _finishQuiz(); }
            } : null,
            child: Text(_currentQuestionIndex < widget.questions.length - 1 ? 'سوال بعدی' : 'مشاهده نتیجه نهایی'),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(String key, Question question, Color themeColor) {
    bool isSelected = _userAnswers[question.id] == key;
    return GestureDetector(
      onTap: () => _selectAnswer(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? themeColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? themeColor : Colors.grey.shade300, width: 1.5),
          boxShadow: isSelected ? [BoxShadow(color: themeColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 14, backgroundColor: isSelected ? Colors.white : themeColor.withOpacity(0.1), child: Text(key, style: TextStyle(color: isSelected ? themeColor : themeColor, fontSize: 12, fontWeight: FontWeight.bold))),
            const SizedBox(width: 15),
            Expanded(child: Text(_getOptionText(question, key), style: TextStyle(color: isSelected ? Colors.white : AppColors.textDark, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
          ],
        ),
      ),
    );
  }
}