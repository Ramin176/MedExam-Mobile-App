// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:med_exam_app/auth/login_screen.dart';
// import 'package:med_exam_app/screens/results_screen.dart';
// import 'package:med_exam_app/screens/subject_detail_screen.dart';
// import 'package:med_exam_app/screens/plan_screen.dart'; 
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:med_exam_app/models/student_class.dart';
// import 'package:med_exam_app/models/question.dart'; 
// import 'package:med_exam_app/utils/app_theme.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:connectivity_plus/connectivity_plus.dart'; 
// import 'package:hive_flutter/hive_flutter.dart';


// const String API_URL = "https://medexam.saberyinstitute.com/api";

// // const String API_URL = "http://192.168.173.30:8000/api"; 

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   Future<Map<String, List<StudentClass>>>? _classesFuture;
//   String _userName = 'کاربر';

//   @override
//   void initState() {
//     super.initState();
//     _loadUserInfo();
//     _classesFuture = _fetchClassesListData(); // فراخوانی تابع درست
//     _syncPendingResults(); 
//   }

//   void _loadUserInfo() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() { _userName = prefs.getString('userName') ?? 'کاربر محترم'; });
//   }

//   // ۱. ارسال نمرات آفلاین به سرور
//   Future<void> _syncPendingResults() async {
//     final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
//     if (connectivityResult.contains(ConnectivityResult.none)) return;

//     var pendingBox = await Hive.openBox('pending_results');
//     if (pendingBox.isEmpty) return;

//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('authToken');
//     final dio = Dio();
//     List<int> keysToDelete = [];

//     for (var key in pendingBox.keys) {
//       final data = pendingBox.get(key);
//       try {
//         await dio.post('$API_URL/submit-result', data: data, options: Options(headers: {'Authorization': 'Bearer $token'}));
//         keysToDelete.add(key);
//       } catch (e) { debugPrint("Sync error: $e"); }
//     }

//     for (var key in keysToDelete) { await pendingBox.delete(key); }
//   }

//   // ۲. دریافت لیست صنف‌ها (این تابع نباید با تابع دانلود اشتباه شود)
//   Future<Map<String, List<StudentClass>>> _fetchClassesListData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('authToken');
//     var classBox = await Hive.openBox<StudentClass>('activeClasses');
//     var settingsBox = await Hive.openBox('settings');
//     final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
//     if (connectivityResult.contains(ConnectivityResult.none)) {
//       return {'active': classBox.values.toList(), 'all': []};
//     }

//     try {
//       final dio = Dio();
//       final options = Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
//       final activeRes = await dio.get('$API_URL/my-classes', options: options);
//       final allRes = await dio.get('$API_URL/all-classes', options: options);
//        final settingsRes = await dio.get('$API_URL/settings', options: options);
//     if (settingsRes.statusCode == 200) {
//       await settingsBox.put('admin_telegram', settingsRes.data['admin_telegram']);
//     }
//       List<StudentClass> active = (activeRes.data as List).map((j) => StudentClass.fromJson(j)).toList();
//       List<StudentClass> all = (allRes.data as List).map((j) => StudentClass.fromJson(j)).toList();
      
//       await classBox.clear();
//       for (var c in active) { await classBox.put(c.id, c); }
//       return {'active': active, 'all': all};
//     } catch (e) {
//       return {'active': classBox.values.toList(), 'all': []};
//     }
//   }

//   // ۳. دانلود محتوای سوالات برای آفلاین
//   Future<void> _downloadFullClassContent(int classId) async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//      builder: (_) => const Center(
//   child: Card(
//     child: Padding(
//       padding: EdgeInsets.all(20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CircularProgressIndicator(),
//           SizedBox(height: 15),
//           Text("در حال دانلود سوالات...")
//         ],
//       ),
//     ),
//   ),
// ),
//       );

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('authToken');
//       final response = await Dio().get("$API_URL/sync-class/$classId", options: Options(headers: {'Authorization': 'Bearer $token'}));

//       if (response.statusCode == 200) {
//         final List<dynamic> subjectsJson = response.data;
//         for (var subject in subjectsJson) {
//           for (var topic in subject['topics']) {
//             var qBox = await Hive.openBox<Question>('offline_questions_${topic['id']}');
//             await qBox.clear();
//             List<Question> qList = (topic['questions'] as List).map((j) => Question.fromJson(j)).toList();
//             await qBox.addAll(qList);
//           }
//         }
//         if (!mounted) return;
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ تمام سوالات صنف برای استفاده آفلاین دانلود شد."), backgroundColor: AppColors.success));
//       }
//     } catch (e) {
//       if (mounted) Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ خطا در دانلود: $e"), backgroundColor: AppColors.error));
//     }
//   }

//   void _logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('authToken');
//     if (!mounted) return;
//     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('میز کار آزمون'),
//           leading: IconButton(icon: const Icon(FontAwesomeIcons.arrowRightFromBracket, size: 18), onPressed: _logout),
//           actions: [
//             IconButton(icon: const Icon(FontAwesomeIcons.squarePollVertical, size: 18), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultsScreen()))),
//             IconButton(icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 18), onPressed: () {
//               setState(() { _classesFuture = _fetchClassesListData(); });
//               _syncPendingResults();
//             }),
//           ],
//         ),
//         body: Column(
//           children: [
//             _buildWelcomeHeader(),
//             const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), child: Row(children: [Icon(FontAwesomeIcons.layerGroup, color: AppColors.primary, size: 20), SizedBox(width: 10), Text('صنف‌های فعال شما', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))])),
//             Expanded(
//               child: FutureBuilder<Map<String, List<StudentClass>>>(
//                 future: _classesFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
//                   if (snapshot.hasError) return const Center(child: Text('خطا در بارگذاری اطلاعات'));
//                   final activeClasses = snapshot.data?['active'] ?? [];
//                   return ListView.builder(
//                     padding: const EdgeInsets.only(bottom: 20),
//                     itemCount: activeClasses.length,
//                     itemBuilder: (context, index) => _buildClassCard(activeClasses[index]),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWelcomeHeader() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
//       decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           ElevatedButton.icon(
//             style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white, minimumSize: const Size(110, 45)),
//             onPressed: () async {
//               final data = await _classesFuture;
//               if (data != null && data['all'] != null && data['all']!.isNotEmpty) {
//                 Navigator.push(context, MaterialPageRoute(builder: (_) => PlanScreen(availablePlans: data['all']!)));
//               }
//             },
//             icon: const Icon(FontAwesomeIcons.cartPlus, size: 14),
//             label: const Text('خرید پلن'),
//           ),
//           Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('خوش آمدید،', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)), Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))]),
//         ],
//       ),
//     );
//   }

// //   Widget _buildClassCard(StudentClass studentClass) {
// //     final now = DateTime.now();
// //     bool isExpired = now.isAfter(studentClass.endDate);

// //     return Card(
// //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //       child: ExpansionTile(
// //         enabled: !isExpired,
// //         leading: Icon(FontAwesomeIcons.bookOpen, color: isExpired ? Colors.grey : AppColors.primary, size: 18),
// //         title: Text(studentClass.name, style: TextStyle(fontWeight: FontWeight.bold, color: isExpired ? Colors.grey : AppColors.textDark)),
// //         subtitle: Text(isExpired ? "منقضی شده" : 'باقیمانده: ${studentClass.endDate.difference(now).inDays} روز'),
// //         // دکمه دانلود در سمت چپ
// //         trailing: IconButton(
// //           icon: const Icon(Icons.cloud_download, color: AppColors.secondary),
// //           onPressed: () => _downloadFullClassContent(studentClass.id),
// //         ),
// //         // مضامین داخل صنف
// //         children: studentClass.subjects.map((subject) => ListTile(
// //           contentPadding: const EdgeInsets.symmetric(horizontal: 30),
// //           title: Text(subject.name, style: const TextStyle(fontSize: 14)),
// //           leading: const Icon(Icons.arrow_back_ios, size: 12, color: AppColors.secondary),
// //           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SubjectDetailScreen(subject: subject, classEndDate: studentClass.endDate))),
// //         )).toList(),
// //       ),
// //     );
// //   }
// // }
// Widget _buildClassCard(StudentClass studentClass) {
//   final now = DateTime.now();
//   bool isExpired = now.isAfter(studentClass.endDate);

//   return Card(
//     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//     child: ExpansionTile(
//       enabled: !isExpired,
//       // ۱. آیکون سمت راست (کتاب)
//       leading: Icon(FontAwesomeIcons.bookOpen, 
//         color: isExpired ? Colors.grey : AppColors.primary, size: 18),
      
//       // ۲. بخش عنوان شامل نام صنف و دکمه دانلود در کنار هم
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Text(studentClass.name, 
//               style: TextStyle(fontWeight: FontWeight.bold, 
//               color: isExpired ? Colors.grey : AppColors.textDark)),
//           ),
//           // دکمه دانلود را اینجا آوردیم تا مزاحم باز شدن صنف نشود
//           if (!isExpired)
//             IconButton(
//               icon: const Icon(Icons.cloud_download, color: AppColors.secondary, size: 22),
//               onPressed: () => _downloadFullClassContent(studentClass.id),
//             ),
//         ],
//       ),
      
//       subtitle: Text(isExpired ? "منقضی شده" : 'باقیمانده: ${studentClass.endDate.difference(now).inDays} روز'),
      
//       // ۳. فلش بازکننده (trailing را خالی گذاشتیم تا خودِ فلاتر فلش را برگرداند)
//       trailing: isExpired ? const Icon(Icons.lock_outline, color: Colors.grey) : null,

//       // ۴. مضامین داخل صنف که وقتی کلیک کنید نمایش داده می‌شوند
//       children: studentClass.subjects.isEmpty 
//         ? [const Padding(padding: EdgeInsets.all(10), child: Text("مضمونی برای این صنف ثبت نشده است"))]
//         : studentClass.subjects.map((subject) => ListTile(
//             contentPadding: const EdgeInsets.symmetric(horizontal: 30),
//             title: Text(subject.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
//             leading: const Icon(Icons.menu_book, size: 16, color: AppColors.secondary),
//             trailing: const Icon(Icons.arrow_forward_ios, size: 12),
//             onTap: () {
//               Navigator.push(context, MaterialPageRoute(
//                 builder: (context) => SubjectDetailScreen(
//                   subject: subject, 
//                   classEndDate: studentClass.endDate
//                 )
//               ));
//             },
//           )).toList(),
//     ),
//   );
// }
// }
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:med_exam_app/auth/login_screen.dart';
import 'package:med_exam_app/models/lecture.dart';
import 'package:med_exam_app/screens/manual_grades_screen.dart';
import 'package:med_exam_app/screens/results_screen.dart';
import 'package:med_exam_app/screens/subject_detail_screen.dart';
import 'package:med_exam_app/screens/plan_screen.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:med_exam_app/models/student_class.dart';
import 'package:med_exam_app/models/question.dart'; 
import 'package:med_exam_app/utils/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; 
import 'package:hive_flutter/hive_flutter.dart';

const String API_URL = "https://medexam.saberyinstitute.com/api";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Map<String, List<StudentClass>>>? _classesFuture;
  String _userName = 'کاربر محترم';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _classesFuture = _fetchClassesListData();
    _syncPendingResults(); 
  }

  void _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { _userName = prefs.getString('userName') ?? 'کاربر محترم'; });
  }

  // متد همگام‌سازی نمرات آفلاین
  Future<void> _syncPendingResults() async {
    final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) return;

    var pendingBox = await Hive.openBox('pending_results');
    if (pendingBox.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final dio = Dio();
    List<int> keysToDelete = [];

    for (var key in pendingBox.keys) {
      final data = pendingBox.get(key);
      try {
        await dio.post('$API_URL/submit-result', data: data, options: Options(headers: {'Authorization': 'Bearer $token'}));
        keysToDelete.add(key);
      } catch (e) { debugPrint("Sync error: $e"); }
    }
    for (var key in keysToDelete) { await pendingBox.delete(key); }
  }

  // دریافت اطلاعات صنف‌ها و تنظیمات
  Future<Map<String, List<StudentClass>>> _fetchClassesListData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    var classBox = await Hive.openBox<StudentClass>('activeClasses');
    var settingsBox = await Hive.openBox('settings');
   var allPlansBox = await Hive.openBox<StudentClass>('allAvailablePlans');
    final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return {'active': classBox.values.toList(), 'all': allPlansBox.values.toList()};
    }

    try {
      final dio = Dio();
      final options = Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
      
      final activeRes = await dio.get('$API_URL/my-classes', options: options);
      final allRes = await dio.get('$API_URL/all-classes', options: options);
      final settingsRes = await dio.get('$API_URL/settings', options: options);

      if (settingsRes.statusCode == 200) {
        await settingsBox.put('admin_telegram', settingsRes.data['admin_telegram']);
      }

      List<StudentClass> active = (activeRes.data as List).map((j) => StudentClass.fromJson(j)).toList();
      List<StudentClass> all = (allRes.data as List).map((j) => StudentClass.fromJson(j)).toList();
       await allPlansBox.clear();
      for (var p in all) { await allPlansBox.put(p.id, p); }
      await classBox.clear();
      for (var c in active) { await classBox.put(c.id, c); }
      return {'active': active, 'all': all};
    } catch (e) {
      return {'active': classBox.values.toList(),'all': allPlansBox.values.toList()};
    }
  }

  // متد دانلود محتوا با طراحی جدید دیالوگ
  Future<void> _downloadFullClassContent(int classId) async {
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.secondary, strokeWidth: 3),
            const SizedBox(height: 20),
            const Text("در حال دریافت سوالات...", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Vazirmatn')),
            const SizedBox(height: 5),
            const Text("بسته آفلاین در حال آماده‌سازی است", style: TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'Vazirmatn')),
          ],
        ),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final response = await Dio().get("$API_URL/sync-class/$classId", options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200) {
        final List<dynamic> subjectsJson = response.data;
        for (var subject in subjectsJson) {
           var lecBox = await Hive.openBox<Lecture>('cached_lectures_${subject['id']}');
      await lecBox.clear();
      if (subject['lectures'] != null) {
        List<Lecture> lecList = (subject['lectures'] as List).map((j) => Lecture.fromJson(j)).toList();
        await lecBox.addAll(lecList);
      }
          for (var topic in subject['topics']) {
            var qBox = await Hive.openBox<Question>('offline_questions_${topic['id']}');
            await qBox.clear();
            List<Question> qList = (topic['questions'] as List).map((j) => Question.fromJson(j)).toList();
            await qBox.addAll(qList);
          }
        }
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ این صنف با موفقیت آفلاین شد")));
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ خطا در دانلود. اینترنت را چک کنید")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F6), // رنگ پس‌زمینه آرام‌بخش
        body: Column(
          children: [
            _buildCustomHeader(), // هدر بازطراحی شده
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.layerGroup, size: 18, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text('دسترسی به صنف‌ها', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<Map<String, List<StudentClass>>>(
                future: _classesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(child: Text("خطا در دریافت اطلاعات صنف‌ها"));
                  }
                  final activeClasses = snapshot.data?['active'] ?? [];
                  if (activeClasses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.folderOpen, size: 50, color: Colors.grey[300]),
                          const SizedBox(height: 15),
                          const Text("صنف فعالی یافت نشد", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    itemCount: activeClasses.length,
                    itemBuilder: (context, index) => _buildModernClassCard(activeClasses[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- بخش هدر خیره‌کننده (Stunning Header) ---
  Widget _buildCustomHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, Color(0xFF1E6F7B)], // گرادینت حرفه‌ای
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          // ردیف اول: عنوان و آیکون‌های سیستمی
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('میز کار آزمون', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              Row(
                children: [
                  _buildHeaderCircleIcon(FontAwesomeIcons.rotate, () {
                    setState(() { _classesFuture = _fetchClassesListData(); });
                    _syncPendingResults();
                  }),
                  const SizedBox(width: 10),
                  _buildHeaderCircleIcon(FontAwesomeIcons.chartSimple, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultsScreen()));
                  }),
                  const SizedBox(width: 10),
                  _buildHeaderCircleIcon(FontAwesomeIcons.powerOff, () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('authToken');
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
                  }),
                    const SizedBox(width: 10),
                  _buildHeaderCircleIcon(FontAwesomeIcons.fileSignature, () {
  Navigator.push(context, MaterialPageRoute(builder: (_) => const ManualGradesScreen()));
}),
                ],
              )
            ],
          ),
          const SizedBox(height: 30),
          // ردیف دوم: خوش‌آمدگویی و دکمه پلن
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white24,
                    child: Icon(FontAwesomeIcons.userGraduate, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('خوش آمدید،', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                      Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              // دکمه خرید پلن با استایل مدرن
              InkWell(
                onTap: () async {
                  final data = await _classesFuture;
                  if (data != null && data['all'] != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PlanScreen(availablePlans: data['all']!)));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                  ),
                  child: const Row(
                    children: [
                      Icon(FontAwesomeIcons.crown, color: Colors.white, size: 14),
                      SizedBox(width: 8),
                      Text('خرید پلن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ویجت کمکی برای آیکون‌های دایره‌ای هدر
  Widget _buildHeaderCircleIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  // کارت مدرن صنف‌ها
  Widget _buildModernClassCard(StudentClass studentClass) {
    final now = DateTime.now();
    bool isExpired = now.isAfter(studentClass.endDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          enabled: !isExpired,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isExpired ? Colors.grey[100] : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(FontAwesomeIcons.graduationCap, color: isExpired ? Colors.grey : AppColors.primary, size: 20),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(studentClass.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: isExpired ? Colors.grey : AppColors.textDark))),
              if (!isExpired)
                IconButton(
                  icon: const Icon(FontAwesomeIcons.circleArrowDown, color: AppColors.secondary, size: 22),
                  onPressed: () => _downloadFullClassContent(studentClass.id),
                ),
            ],
          ),
          subtitle: Text(
            isExpired ? "🔴 منقضی شده" : "⏳ اعتبار تا: ${studentClass.endDate.year}/${studentClass.endDate.month}/${studentClass.endDate.day}",
            style: const TextStyle(fontSize: 12),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25))),
              child: Column(
                children: studentClass.subjects.map((subject) => _buildSubjectTile(subject, studentClass.endDate)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectTile(dynamic subject, DateTime endDate) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: const Icon(FontAwesomeIcons.bookMedical, size: 16, color: AppColors.secondary),
      title: Text(subject.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_left, size: 20, color: Colors.grey),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectDetailScreen(subject: subject, classEndDate: endDate))),
    );
  }
}