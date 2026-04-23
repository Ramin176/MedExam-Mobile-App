import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:med_exam_app/models/student_class.dart';
import 'package:med_exam_app/models/topic.dart';
import 'package:med_exam_app/models/question.dart'; // اضافه شد
import 'package:med_exam_app/screens/quiz/quiz_screen.dart'; // اضافه شد
import 'package:med_exam_app/screens/quiz/quiz_start_screen.dart';
import 'package:med_exam_app/screens/lecture_list_screen.dart'; // اضافه شد
import 'package:med_exam_app/utils/app_theme.dart';
import 'package:dio/dio.dart'; // اضافه شد
import 'package:shared_preferences/shared_preferences.dart'; // اضافه شد
import 'package:hive_flutter/hive_flutter.dart';
class SubjectDetailScreen extends StatefulWidget {
  final Subject subject;
  final DateTime classEndDate;
  const SubjectDetailScreen({super.key, required this.subject, required this.classEndDate});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  final TextEditingController _countController = TextEditingController(text: "50");



void _showRenewalDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
              child: const Icon(Icons.timer_off_outlined, color: Colors.orange, size: 35),
            ),
            const SizedBox(height: 20),
            const Text(
              "اشتراک شما به پایان رسیده است",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
            ),
            const SizedBox(height: 15),
            const Text(
              "برای دسترسی مجدد به بانک سوالات، آزمون‌های جامع رندوم و مطالب آموزشی جدید، لطفاً پلن خود را تمدید کنید.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textGrey, height: 1.6),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                onPressed: () {
                  Navigator.pop(ctx);
                  // هدایت به صفحه خرید پلن (باید لیست پلن‌ها را دوباره بگیریم یا به صفحه اصلی برگردیم)
                  Navigator.of(context).popUntil((route) => route.isFirst); 
                  // راهنمایی: چون پلن‌ها در صفحه اصلی لود می‌شوند، کاربر را به خانه برمی‌گردانیم
                },
                child: const Text("مشاهده پلن‌های تمدید اشتراک"),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("بعداً", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    ),
  );
}
  // متد اجرای آزمون جامع رندوم
  Future<void> _startRandomExam(int count) async {
    // بررسی تاریخ انقضا قبل از شروع
     final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
  bool isOffline = connectivityResult.contains(ConnectivityResult.none);
    if (DateTime.now().isAfter(widget.classEndDate)) {
      _showErrorSnackBar("اشتراک شما منقضی شده است");
      return;
    }
  if (DateTime.now().isAfter(widget.classEndDate)) {
  // _showErrorSnackBar("اشتراک شما منقضی شده است"); // این را پاک کنید
  _showRenewalDialog(context); // این را جایگزین کنید
  return;
}
if (isOffline) {
    // منطق آفلاین: جمع‌آوری سوالات از تمام تاپیک‌های این مضمون در Hive
    List<Question> allSubjectQuestions = [];
    
    for (var topic in widget.subject.topics) {
      var box = await Hive.openBox<Question>('offline_questions_${topic.id}');
      allSubjectQuestions.addAll(box.values);
    }

    if (allSubjectQuestions.isEmpty) {
      _showErrorSnackBar("محتوای این صنف هنوز دانلود نشده است. یکبار آنلاین شوید و دکمه دانلود را بزنید.");
      return;
    }

    // مخلوط کردن و انتخاب تعداد درخواستی
    allSubjectQuestions.shuffle();
    final List<Question> randomQuestions = allSubjectQuestions.take(count).toList();

    Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(
      topic: Topic(id: 0, title: "تمرین جامع آفلاین: ${widget.subject.name}"),
      questions: randomQuestions,
      isPractice: true,
    )));
    return;
  }
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      
      
      final response = await Dio().get(
        "https://medexam.saberyinstitute.com/api/random-exam/${widget.subject.id}?count=$count",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (!mounted) return;
      Navigator.pop(context); // بستن لودینگ

      final List<dynamic> questionsJson = response.data['questions'];
      final List<Question> questions = questionsJson.map((j) => Question.fromJson(j)).toList();

      if (questions.isEmpty) {
        _showErrorSnackBar("سوالی برای این مضمون یافت نشد");
        return;
      }

      Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(
        topic: Topic(id: 0, title: "آزمون جامع: ${widget.subject.name}"),
        questions: questions,
        isPractice: true, // آزمون‌های رندوم معمولاً برای تمرین هستند
      )));
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar("خطا در برقراری ارتباط با سرور");
    }
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Vazirmatn')),
      backgroundColor: AppColors.error,
    ));
  }

  // دیالوگ دریافت تعداد سوالات از محصل
  void _showRandomExamDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 25, right: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ساخت آزمون جامع تصادفی', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              const Text('تعداد سوالات مورد نظر خود را وارد کنید:', style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
              const SizedBox(height: 20),
              TextField(
                controller: _countController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "مثلاً 40",
                  prefixIcon: const Icon(Icons.bolt, color: Colors.orange),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  int count = int.tryParse(_countController.text) ?? 50;
                  Navigator.pop(ctx);
                  _startRandomExam(count);
                },
                child: const Text('شروع آزمون جامع'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.subject.name)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // هدر اصلی (تعداد فصول) - بدون تغییر دیزاین
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(FontAwesomeIcons.listOl, color: AppColors.secondary),
                  const SizedBox(width: 15),
                  Text('تعداد کل فصول: ${widget.subject.topics.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // دکمه‌های جدید (لکچرها و آزمون جامع) - با حفظ استایل اپ
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LectureListScreen(subjectId: widget.subject.id, subjectName: widget.subject.name))),
                    icon: const Icon(FontAwesomeIcons.photoFilm, size: 14),
                    label: const Text('لکچرها', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, minimumSize: const Size(0, 50)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showRandomExamDialog,
                    icon: const Icon(FontAwesomeIcons.shuffle, size: 14),
                    label: const Text('آزمون جامع', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(0, 50)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),
            const Text('لیست عناوین درس:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
            const SizedBox(height: 10),

            // لیست دروس (بدون تغییر دیزاین قبلی)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.subject.topics.length,
              itemBuilder: (context, index) => _buildTopicTile(context, widget.subject.topics[index], index + 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicTile(BuildContext context, Topic topic, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () {
          if (DateTime.now().isAfter(widget.classEndDate)) {
             _showErrorSnackBar("اشتراک شما منقضی شده است");
             return;
          }
          Navigator.push(context, MaterialPageRoute(builder: (context) => QuizStartScreen(topic: topic)));
        },
        leading: CircleAvatar(backgroundColor: AppColors.primary, child: Text('$index', style: const TextStyle(color: Colors.white, fontSize: 14))),
        title: Text(topic.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: const Text('آماده برای آزمون یا تمرین', style: TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.play_circle_fill, color: AppColors.secondary),
      ),
    );
  }
}