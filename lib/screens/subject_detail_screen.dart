// // lib/screens/subject_detail_screen.dart

// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:med_exam_app/models/student_class.dart';
// import 'package:med_exam_app/models/topic.dart';
// import 'package:med_exam_app/screens/quiz/quiz_start_screen.dart';
// import 'package:med_exam_app/utils/app_theme.dart';

// class SubjectDetailScreen extends StatelessWidget {
//   final Subject subject;
//   final DateTime classEndDate; // اضافه شدن تاریخ انقضا به ورودی صفحه

//   const SubjectDetailScreen({
//     super.key, 
//     required this.subject, 
//     required this.classEndDate
//   });

//   // متد کمکی برای نمایش پیام خطا
//   void _showSnackBar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Vazirmatn')),
//         backgroundColor: AppColors.error,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(subject.name),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(15),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // کارت عنوان مضمون
//             Card(
//               color: AppColors.primaryDark,
//               child: ListTile(
//                 leading: const Icon(FontAwesomeIcons.tag, color: AppColors.textLight, size: 20),
//                 title: Text(
//                   'تعداد کل عناوین: ${subject.topics.length}',
//                   style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold),
//                   textAlign: TextAlign.right,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             const Padding(
//               padding: EdgeInsets.only(right: 5, bottom: 10),
//               child: Text(
//                 'فصول و عناوین درس:',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
//                 textAlign: TextAlign.right,
//               ),
//             ),

//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: subject.topics.length,
//               itemBuilder: (context, index) {
//                 final topic = subject.topics[index];
//                 return _buildTopicCard(context, topic, index + 1);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTopicCard(BuildContext context, Topic topic, int index) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: InkWell(
//         onTap: () {
//           // چک کردن تاریخ اعتبار پکیج قبل از ورود
//           if (DateTime.now().isAfter(classEndDate)) {
//             _showSnackBar(context, "خطا: اعتبار این صنف تمام شده است. لطفا دوباره خریداری کنید.");
//             return;
//           }
          
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => QuizStartScreen(topic: topic),
//             ),
//           );
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(15.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Icon(FontAwesomeIcons.arrowLeft, color: AppColors.primaryDark),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.only(right: 15.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         'فصل $index: ${topic.title}',
//                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                         textAlign: TextAlign.right,
//                         textDirection: TextDirection.rtl,
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'آماده برای آزمون یا تمرین',
//                         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                         textAlign: TextAlign.right,
//                         textDirection: TextDirection.rtl,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               CircleAvatar(
//                 backgroundColor: AppColors.primary.withOpacity(0.1),
//                 child: Text(
//                   '$index',
//                   style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:med_exam_app/models/student_class.dart';
import 'package:med_exam_app/models/topic.dart';
import 'package:med_exam_app/screens/quiz/quiz_start_screen.dart';
import 'package:med_exam_app/utils/app_theme.dart';

class SubjectDetailScreen extends StatelessWidget {
  final Subject subject;
  final DateTime classEndDate;
  const SubjectDetailScreen({super.key, required this.subject, required this.classEndDate});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(subject.name)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(FontAwesomeIcons.listOl, color: AppColors.secondary),
                  const SizedBox(width: 15),
                  Text('تعداد کل فصول: ${subject.topics.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subject.topics.length,
              itemBuilder: (context, index) => _buildTopicTile(context, subject.topics[index], index + 1),
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
          if (DateTime.now().isAfter(classEndDate)) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("اشتراک شما منقضی شده است")));
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