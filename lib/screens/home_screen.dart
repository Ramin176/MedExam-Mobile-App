
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:med_exam_app/auth/login_screen.dart';
// import 'package:med_exam_app/screens/results_screen.dart';
// import 'package:med_exam_app/screens/subject_detail_screen.dart';
// import 'package:med_exam_app/screens/plan_screen.dart'; 
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:med_exam_app/models/student_class.dart';
// import 'package:med_exam_app/utils/app_theme.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:connectivity_plus/connectivity_plus.dart'; 
// import 'package:hive_flutter/hive_flutter.dart';

// // --- تنظیمات API ---
// const String API_URL = "https://medexam.saberyinstitute.com/api";

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   Future<Map<String, List<StudentClass>>>? _classesFuture;
//   String _userName = 'کاربر';
  
//   List<StudentClass> _activeClasses = [];
//   List<StudentClass> _allClasses = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadUserInfo();
//     _classesFuture = _fetchClassesData();
//   }

//   void _loadUserInfo() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _userName = prefs.getString('userName') ?? 'کاربر محترم';
//     });
//   }
  
//   void _logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('authToken');
    
//     if (token != null) {
//       try {
//         await Dio().post('$API_URL/logout', options: Options(headers: {'Authorization': 'Bearer $token'}));
//       } catch (e) {
//         print("Logout API Error: $e");
//       }
//     }
    
//     await prefs.remove('authToken');
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => const LoginScreen()),
//       (Route<dynamic> route) => false,
//     );
//   }
//   // بخشی از متد _fetchClassesData در lib/screens/home_screen.dart

//   Future<Map<String, List<StudentClass>>> _fetchClassesData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('authToken');
    
//     final connection = await Connectivity().checkConnectivity();
//     final isOnline = connection != ConnectivityResult.none;
    
//     final classBox = await Hive.openBox<StudentClass>('activeClasses');
    
//     if (!isOnline) {
//         _activeClasses = classBox.values.toList();
//         _allClasses = _activeClasses; 
//         return {'active': _activeClasses, 'all': _allClasses};
//     }
    
//     try {
//         // ۱. دریافت کلاس‌های فعال من
//         final activeResponse = await Dio().get('$API_URL/my-classes', options: Options(headers: {'Authorization': 'Bearer $token'}));
        
//         // ۲. دریافت تمام کلاس‌های موجود برای صفحه پلن‌ها
//         final allResponse = await Dio().get('$API_URL/all-classes', options: Options(headers: {'Authorization': 'Bearer $token'}));
        
//         final List<dynamic> activeJsonList = activeResponse.data;
//         final List<dynamic> allJsonList = allResponse.data; // اصلاح شد
        
//         setState(() {
//           _activeClasses = activeJsonList.map((json) => StudentClass.fromJson(json)).toList();
//           _allClasses = allJsonList.map((json) => StudentClass.fromJson(json)).toList();
//         });
        
//         // ذخیره در Hive
//         await classBox.clear();
//         for (var cls in _activeClasses) {
//             await classBox.put(cls.id, cls);
//         }
        
//         return {'active': _activeClasses, 'all': _allClasses};

//     } catch (e) {
//         print("Error: $e");
//         return {'active': classBox.values.toList(), 'all': []};
//     }
//   }
//   // متد اصلی برای دریافت و همگام سازی داده ها (Offline-First)
//   // Future<Map<String, List<StudentClass>>> _fetchClassesData() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   final token = prefs.getString('authToken');
    
//   //   final connection = await Connectivity().checkConnectivity();
//   //   final isOnline = connection != ConnectivityResult.none;
    
//   //   final classBox = await Hive.openBox<StudentClass>('activeClasses');
    
//   //   // اگر آنلاین نبودیم، از Hive می‌خوانیم
//   //   if (!isOnline) {
//   //       _activeClasses = classBox.values.toList();
//   //       _allClasses = _activeClasses; 
        
//   //       if (_activeClasses.isEmpty) {
//   //           return Future.error('اتصال اینترنت قطع است و دیتای آفلاینی موجود نیست.');
//   //       }
//   //       _showSnackBar('شما در حالت آفلاین هستید. دیتای قبلی نمایش داده می‌شود.');
//   //       return {'active': _activeClasses, 'all': _allClasses};
//   //   }
    
//   //   // اگر آنلاین بودیم، دکتا را از API می‌گیریم
//   //   try {
//   //       final activeResponse = await Dio().get('$API_URL/my-classes', options: Options(headers: {'Authorization': 'Bearer $token'}));
//   //       final allResponse = await Dio().get('$API_URL/all-classes', options: Options(headers: {'Authorization': 'Bearer $token'}));
        
//   //       final List<dynamic> activeJsonList = activeResponse.data;
//   //       final List<dynamic> allJsonList = allResponse.data;
        
//   //       _activeClasses = activeJsonList.map((json) => StudentClass.fromJson(json)).toList();
//   //       _allClasses = allJsonList.map((json) => StudentClass.fromJson(json)).toList();
        
//   //       // --- ذخیره در Hive (همگام سازی) ---
//   //       await classBox.clear();
//   //       for (var cls in _activeClasses) {
//   //           await classBox.put(cls.id, cls);
//   //       }
//   //       _showSnackBar('داده‌ها با موفقیت از سرور همگام سازی شدند.');
        
//   //       return {'active': _activeClasses, 'all': _allClasses};

//   //   } on DioException catch (e) {
//   //       // اگر آنلاین بودیم ولی خطا داد (مثلاً توکن منقضی)
//   //       if (e.response?.statusCode == 401) _logout();
        
//   //       // تلاش نهایی برای خواندن از Hive در صورت خطای آنلاین
//   //       if (classBox.values.isNotEmpty) {
//   //            _activeClasses = classBox.values.toList();
//   //            _allClasses = _activeClasses;
//   //            _showSnackBar('خطا در اتصال به سرور. دیتای آفلاین نمایش داده می‌شود.');
//   //            return {'active': _activeClasses, 'all': _allClasses};
//   //       }
//   //       return Future.error('خطا در دریافت اطلاعات: ${e.message}');
//   //   }
//   // }

//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, textAlign: TextAlign.right),
//         backgroundColor: isError ? AppColors.error : AppColors.success,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('صفحه اصلی'),
//         actions: [
//           // دکمه آپدیت دیتا (Sync)
//           IconButton(
//             icon: const Icon(FontAwesomeIcons.arrowsRotate),
//             onPressed: () {
//                 setState(() {
//                     _classesFuture = _fetchClassesData(); // دوباره دیتا را فچ می‌کند
//                 });
//             },
//             tooltip: 'به‌روزرسانی داده‌ها',
//           ),
//           // دکمه کارنامه
//           IconButton(
//             icon: const Icon(FontAwesomeIcons.squarePollVertical),
//             onPressed: () {
//               Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultsScreen()));
//             },
//             tooltip: 'کارنامه',
//           ),
//           // دکمه خروج
//           IconButton(
//             icon: const Icon(FontAwesomeIcons.arrowRightFromBracket),
//             onPressed: _logout,
//             tooltip: 'خروج از حساب',
//           ),
//         ],
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // کارت خوش آمدگویی مدرن و دکمه خرید
//           Container(
//             padding: const EdgeInsets.all(20),
//             color: AppColors.primary,
//             width: double.infinity,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 SizedBox(
//                   height: 40,
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       Navigator.push(context, MaterialPageRoute(builder: (_) => PlanScreen(availablePlans: _allClasses)));
//                     },
//                     icon: const Icon(FontAwesomeIcons.tags, size: 18),
//                     label: const Text('خرید پلن'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryDark,
//                       foregroundColor: AppColors.textLight,
//                     ),
//                   ),
//                 ),
//                 Text(
//                   'خوش آمدید، $_userName',
//                   style: const TextStyle(
//                     color: AppColors.textLight,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.right,
//                 ),
//               ],
//             ),
//           ),
//           // ... (بقیه UI)
//           const Padding(
//             padding: EdgeInsets.only(top: 20, right: 20, bottom: 10),
//             child: Text(
//               'صنف‌ها و مضامین فعال شما:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
//               textAlign: TextAlign.right,
//             ),
//           ),
          
//           Expanded(
//             child: FutureBuilder<Map<String, List<StudentClass>>>(
//               future: _classesFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('خطا: ${snapshot.error}', textAlign: TextAlign.center));
//                 } else if (!snapshot.hasData || snapshot.data!['active']!.isEmpty) {
//                   return const Center(child: Text('شما در هیچ صنفی فعال نیستید. برای شروع به بخش خرید پلن مراجعه کنید.', 
//                                         textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)));
//                 } else {
//                   final activeClasses = snapshot.data!['active']!;
//                   return ListView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                     itemCount: activeClasses.length,
//                     itemBuilder: (context, index) {
//                       final studentClass = activeClasses[index];
//                       return _buildClassCard(context, studentClass);
//                     },
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   // ساختار کارت صنف (طراحی مدرن)
//   Widget _buildClassCard(BuildContext context, StudentClass studentClass) {
//     // final daysRemaining = studentClass.endDate.difference(DateTime.now()).inDays;
//       final now = DateTime.now();
//   final daysRemaining = studentClass.endDate.difference(now).inDays;
  
//   // ۲. بررسی اینکه آیا صنف منقضی شده یا خیر
//   bool isExpired = now.isAfter(studentClass.endDate);
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//         color: isExpired ? Colors.grey.shade300 : Colors.white,
//       child: ExpansionTile(
//          enabled: !isExpired, 
//         tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//         leading: const Icon(FontAwesomeIcons.bookOpen, color: AppColors.primary, size: 30),
//         title: Text(
//           // studentClass.name,
//             studentClass.name + (isExpired ? " (منقضی شده)" : ""),
//           style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 18,        color: isExpired ? Colors.grey : AppColors.textDark
// ),
//           textAlign: TextAlign.right,
//         ),
//         subtitle: Text(
//           isExpired ? "مدت اعتبار این پکیج به اتمام رسیده است"
//           : 'باقیمانده: $daysRemaining روز',                 style: TextStyle(color: isExpired ? Colors.red : (daysRemaining < 7 ? Colors.orange : Colors.grey)),

//           textAlign: TextAlign.right,
//         ),
//         children: isExpired ? [] : studentClass.subjects.map((subject) {
//           return ListTile(
//             contentPadding: const EdgeInsets.only(right: 40, left: 20, bottom: 5),
//             leading: const Icon(FontAwesomeIcons.chevronLeft, size: 15, color: AppColors.primaryDark),
//             title: Text(subject.name, textAlign: TextAlign.right),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SubjectDetailScreen(subject: subject,        classEndDate: studentClass.endDate, // ارسال تاریخ انقضا به صفحه بعد
// ),
//                 ),
//               );
//             },
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:med_exam_app/auth/login_screen.dart';
import 'package:med_exam_app/screens/results_screen.dart';
import 'package:med_exam_app/screens/subject_detail_screen.dart';
import 'package:med_exam_app/screens/plan_screen.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:med_exam_app/models/student_class.dart';
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
  String _userName = 'کاربر';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _classesFuture = _fetchClassesData();
  }

  void _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { _userName = prefs.getString('userName') ?? 'کاربر محترم'; });
  }
  
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token != null) {
      try { await Dio().post('$API_URL/logout', options: Options(headers: {'Authorization': 'Bearer $token'})); } catch (e) { debugPrint(e.toString()); }
    }
    await prefs.remove('authToken');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (r) => false);
  }

  // متد فچ دیتا بدون استفاده از setState داخلی (برای جلوگیری از تداخل)
  Future<Map<String, List<StudentClass>>> _fetchClassesData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final connection = await Connectivity().checkConnectivity();
    final isOnline = connection != ConnectivityResult.none;
    
    // باز کردن باکس Hive
    var classBox = await Hive.openBox<StudentClass>('activeClasses');
    
    if (!isOnline) {
        List<StudentClass> cached = classBox.values.toList();
        return {'active': cached, 'all': cached};
    }

    try {
        final dio = Dio();
        final options = Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
        
        final activeResponse = await dio.get('$API_URL/my-classes', options: options);
        final allResponse = await dio.get('$API_URL/all-classes', options: options);
        
        final List<dynamic> activeJsonList = activeResponse.data;
        final List<dynamic> allJsonList = allResponse.data;
        
        List<StudentClass> activeClasses = activeJsonList.map((json) => StudentClass.fromJson(json)).toList();
        List<StudentClass> allClasses = allJsonList.map((json) => StudentClass.fromJson(json)).toList();
        
        // ذخیره آفلاین
        await classBox.clear();
        for (var cls in activeClasses) { await classBox.put(cls.id, cls); }
        
        return {'active': activeClasses, 'all': allClasses};
    } catch (e) {
        debugPrint("Error Fetching Data: $e");
        // اگر خطا داد، دیتای آفلاین را برگردان
        List<StudentClass> cached = classBox.values.toList();
        if (cached.isNotEmpty) return {'active': cached, 'all': []};
        throw Exception("خطا در اتصال به سرور");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('میز کار آزمون'),
          leading: IconButton(icon: const Icon(FontAwesomeIcons.arrowRightFromBracket, size: 18), onPressed: _logout),
          actions: [
             IconButton(icon: const Icon(FontAwesomeIcons.squarePollVertical, size: 18), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultsScreen()))),
            IconButton(icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 18), onPressed: () => setState(() { _classesFuture = _fetchClassesData(); })),
          ],
        ),
        body: Column(
          children: [
            _buildWelcomeHeader(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.layerGroup, color: AppColors.primary, size: 20),
                  SizedBox(width: 10),
                  Text('صنف‌های فعال شما', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('خطا در بارگذاری اطلاعات'),
                          TextButton(onPressed: () => setState(() { _classesFuture = _fetchClassesData(); }), child: const Text('تلاش مجدد'))
                        ],
                      ),
                    );
                  }
                  
                  final activeClasses = snapshot.data?['active'] ?? [];
                  if (activeClasses.isEmpty) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text('شما صنف فعالی ندارید. لطفاً اشتراک تهیه کنید.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    ));
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: activeClasses.length,
                    itemBuilder: (context, index) => _buildClassCard(activeClasses[index], snapshot.data!['all']!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary, 
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(110, 45)
            ),
            onPressed: () async {
               final data = await _classesFuture;
               if (!mounted) return;
               Navigator.push(context, MaterialPageRoute(builder: (_) => PlanScreen(availablePlans: data?['all'] ?? [])));
            },
            icon: const Icon(FontAwesomeIcons.cartPlus, size: 14),
            label: const Text('خرید پلن', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('خوش آمدید،', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
              Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(StudentClass studentClass, List<StudentClass> allClasses) {
    final now = DateTime.now();
    final daysRemaining = studentClass.endDate.difference(now).inDays;
    bool isExpired = now.isAfter(studentClass.endDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        enabled: !isExpired,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isExpired ? Colors.grey[200] : AppColors.secondary.withOpacity(0.1),
          child: Icon(FontAwesomeIcons.bookOpen, color: isExpired ? Colors.grey : AppColors.primary, size: 18),
        ),
        title: Text(studentClass.name, style: TextStyle(fontWeight: FontWeight.bold, color: isExpired ? Colors.grey : AppColors.textDark)),
        subtitle: Text(isExpired ? "منقضی شده" : 'باقیمانده: $daysRemaining روز', style: TextStyle(color: isExpired ? Colors.red : AppColors.textGrey, fontSize: 12)),
        children: studentClass.subjects.map((subject) => ListTile(
          contentPadding: const EdgeInsets.only(right: 30, left: 20),
          title: Text(subject.name, style: const TextStyle(fontSize: 14)),
          leading: const Icon(Icons.arrow_back_ios, size: 12, color: AppColors.secondary),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SubjectDetailScreen(subject: subject, classEndDate: studentClass.endDate))),
        )).toList(),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:med_exam_app/auth/login_screen.dart';
// import 'package:med_exam_app/screens/results_screen.dart';
// import 'package:med_exam_app/screens/subject_detail_screen.dart';
// import 'package:med_exam_app/screens/plan_screen.dart'; 
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:med_exam_app/models/student_class.dart';
// import 'package:med_exam_app/utils/app_theme.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:connectivity_plus/connectivity_plus.dart'; 
// import 'package:hive_flutter/hive_flutter.dart';

// const String API_URL = "https://medexam.saberyinstitute.com/api";

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   Future<Map<String, List<StudentClass>>>? _classesFuture;
//   String _userName = 'کاربر';
//   List<StudentClass> _activeClasses = [];
//   List<StudentClass> _allClasses = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadUserInfo();
//     _classesFuture = _fetchClassesData();
//   }

//   void _loadUserInfo() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() { _userName = prefs.getString('userName') ?? 'کاربر محترم'; });
//   }
  
//   void _logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('authToken');
//     if (token != null) {
//       try { await Dio().post('$API_URL/logout', options: Options(headers: {'Authorization': 'Bearer $token'})); } catch (e) { print(e); }
//     }
//     await prefs.remove('authToken');
//     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (r) => false);
//   }

//   Future<Map<String, List<StudentClass>>> _fetchClassesData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('authToken');
//     final connection = await Connectivity().checkConnectivity();
//     final isOnline = connection != ConnectivityResult.none;
//     final classBox = await Hive.openBox<StudentClass>('activeClasses');
//     if (!isOnline) {
//         _activeClasses = classBox.values.toList();
//         _allClasses = _activeClasses; 
//         return {'active': _activeClasses, 'all': _allClasses};
//     }
//     try {
//         final activeResponse = await Dio().get('$API_URL/my-classes', options: Options(headers: {'Authorization': 'Bearer $token'}));
//         final allResponse = await Dio().get('$API_URL/all-classes', options: Options(headers: {'Authorization': 'Bearer $token'}));
//         final List<dynamic> activeJsonList = activeResponse.data;
//         final List<dynamic> allJsonList = allResponse.data;
//         setState(() {
//           _activeClasses = activeJsonList.map((json) => StudentClass.fromJson(json)).toList();
//           _allClasses = allJsonList.map((json) => StudentClass.fromJson(json)).toList();
//         });
//         await classBox.clear();
//         for (var cls in _activeClasses) { await classBox.put(cls.id, cls); }
//         return {'active': _activeClasses, 'all': _allClasses};
//     } catch (e) { return {'active': classBox.values.toList(), 'all': []}; }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('میز کار آزمون'),
//           actions: [
//             IconButton(icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 18), onPressed: () => setState(() { _classesFuture = _fetchClassesData(); })),
//             IconButton(icon: const Icon(FontAwesomeIcons.squarePollVertical, size: 18), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultsScreen()))),
//             IconButton(icon: const Icon(FontAwesomeIcons.arrowRightFromBracket, size: 18), onPressed: _logout),
//           ],
//         ),
//         body: Column(
//           children: [
//             _buildWelcomeHeader(),
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Row(
//                 children: [
//                   Icon(FontAwesomeIcons.layerGroup, color: AppColors.primary, size: 20),
//                   SizedBox(width: 10),
//                   Text('صنف‌های فعال شما', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: FutureBuilder<Map<String, List<StudentClass>>>(
//                 future: _classesFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
//                   if (snapshot.hasError) return Center(child: Text('خطا در دریافت اطلاعات'));
//                   final activeClasses = snapshot.data!['active']!;
//                   if (activeClasses.isEmpty) return const Center(child: Text('لیست صنف‌های شما خالی است.'));
//                   return ListView.builder(
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
//       padding: const EdgeInsets.all(24),
//       decoration: const BoxDecoration(
//         color: AppColors.primary,
//         borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('خوش آمدید،', style: TextStyle(color: Colors.white70, fontSize: 14)),
//               Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
//             ],
//           ),
//           ElevatedButton.icon(
//             style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, minimumSize: const Size(100, 40)),
//             onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlanScreen(availablePlans: _allClasses))),
//             icon: const Icon(FontAwesomeIcons.cartPlus, size: 16),
//             label: const Text('خرید پلن'),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildClassCard(StudentClass studentClass) {
//     final now = DateTime.now();
//     final daysRemaining = studentClass.endDate.difference(now).inDays;
//     bool isExpired = now.isAfter(studentClass.endDate);
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: ExpansionTile(
//         enabled: !isExpired,
//         leading: CircleAvatar(
//           backgroundColor: isExpired ? Colors.grey[200] : AppColors.secondary.withOpacity(0.1),
//           child: Icon(FontAwesomeIcons.bookOpen, color: isExpired ? Colors.grey : AppColors.primary, size: 18),
//         ),
//         title: Text(studentClass.name + (isExpired ? " (منقضی)" : ""), style: TextStyle(fontWeight: FontWeight.bold, color: isExpired ? Colors.grey : AppColors.textDark)),
//         subtitle: Text(isExpired ? "مدت اعتبار تمام شده" : 'باقیمانده: $daysRemaining روز', style: TextStyle(color: isExpired ? Colors.red : AppColors.textGrey, fontSize: 12)),
//         children: isExpired ? [] : studentClass.subjects.map((subject) => ListTile(
//           contentPadding: const EdgeInsets.symmetric(horizontal: 24),
//           title: Text(subject.name, style: const TextStyle(fontSize: 14)),
//           trailing: const Icon(Icons.arrow_forward_ios, size: 14),
//           onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SubjectDetailScreen(subject: subject, classEndDate: studentClass.endDate))),
//         )).toList(),
//       ),
//     );
//   }
// }