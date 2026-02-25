// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:med_exam_app/models/student_class.dart';
// import 'package:med_exam_app/utils/app_theme.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';

// class PlanScreen extends StatefulWidget {
//   final List<StudentClass> availablePlans;

//   const PlanScreen({super.key, required this.availablePlans});

//   @override
//   State<PlanScreen> createState() => _PlanScreenState();
// }

// class _PlanScreenState extends State<PlanScreen> {
//   String _userName = "";
//   String _userEmail = "";
//   String _adminTelegram = "Ramin0121"; // مقدار پیش‌فرض

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   // بارگذاری اطلاعات از SharedPreferences
//   Future<void> _loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _userName = prefs.getString('userName') ?? "کاربر ناشناس";
//       _userEmail = prefs.getString('userEmail') ?? "بدون ایمیل";
//       _adminTelegram = prefs.getString('adminTelegram') ?? "Ramin0121";
//     });
//   }

//   // متد ارسال پیام حرفه‌ای به تلگرام
//   void _sendOrderToTelegram(StudentClass plan, String duration, String price) async {
//     final String message = """
// *📣 سفارش جدید اشتراک*
// - - - - - - - - - - - - - - - - - -
// *اطلاعات کاربر:*
// 👤 *نام:* $_userName
// ✉️ *ایمیل:* $_userEmail

// *جزئیات سفارش:*
// 📦 *نام بسته:* ${plan.name}
// 📚 *شامل موضوعات:* تمام مضامین مربوطه
// ⏳ *مدت زمان:* $duration
// 💵 *قیمت:* $price افغانی
// - - - - - - - - - - - - - - - - - -
// *اقدام مورد نیاز:*
// لطفاً پس از بررسی، اشتراک را از طریق پنل مدیریت برای کاربر فعال نمایید.
// - - - - - - - - - - - - - - - - - -
// *⚠️ توجه برای کاربر:*
// *لطفاً تصویر فیش پرداختی خود را در همین صفحه تلگرام برای ما ارسال کنید تا سفارش شما تایید شود.*
// """;

//     final url = Uri.parse("https://t.me/$_adminTelegram?text=${Uri.encodeComponent(message)}");

//     if (await canLaunchUrl(url)) {
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     } else {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("برنامه تلگرام یافت نشد یا آیدی نامعتبر است.")),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('عضویت ویژه و خرید پلن'),
//         centerTitle: true,
//       ),
//       body: widget.availablePlans.isEmpty
//           ? const Center(child: Text("هیچ پلنی برای نمایش وجود ندارد."))
//           : ListView.builder(
//               padding: const EdgeInsets.all(15),
//               itemCount: widget.availablePlans.length,
//               itemBuilder: (context, index) {
//                 final plan = widget.availablePlans[index];
//                 return _buildFullPlanCard(plan);
//               },
//             ),
//     );
//   }

//   // ساخت کارت پلن با دو دکمه ماهوار و سمستروار
//   Widget _buildFullPlanCard(StudentClass plan) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 20),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       elevation: 4,
//       child: Column(
//         children: [
//           // سربرگ کارت
//           Container(
//             padding: const EdgeInsets.all(15),
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
//             ),
//             child: Text(
//               plan.name,
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
//               textAlign: TextAlign.center,
//             ),
//           ),

//           const SizedBox(height: 10),

//           // گزینه اول: اشتراک ماهوار
//           _buildPlanOption(
//             title: "اشتراک یک‌ماهه",
//             price: plan.monthlyPrice,
//             icon: Icons.calendar_month,
//             color: Colors.blue,
//             onTap: () => _sendOrderToTelegram(plan, "یک‌ماهه", plan.monthlyPrice),
//           ),

//           const Divider(height: 1, indent: 20, endIndent: 20),

//           // گزینه دوم: اشتراک سمستروار
//           _buildPlanOption(
//             title: "اشتراک کامل سمستر",
//             price: plan.semesterPrice,
//             icon: Icons.school,
//             color: Colors.green,
//             onTap: () => _sendOrderToTelegram(plan, "سمستروار (کامل)", plan.semesterPrice),
//           ),

//           const SizedBox(height: 15),

//           // دکمه مشاهده نحوه پرداخت
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//             child: ElevatedButton.icon(
//               onPressed: () => _showPaymentInstructions(),
//               icon: const Icon(Icons.info_outline, size: 20),
//               label: const Text("مشاهده نحوه پرداخت"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF00796B),
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 45),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // آیتم‌های لیست داخل کارت
//   Widget _buildPlanOption({
//     required String title,
//     required String price,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       onTap: onTap,
//       leading: Icon(icon, color: color),
//       title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
//       subtitle: const Text("ثبت سفارش از طریق تلگرام"),
//       trailing: Text(
//         "$price افغانی",
//         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
//       ),
//     );
//   }

//   // دیالوگ راهنمای پرداخت
//   void _showPaymentInstructions() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text("نحوه پرداخت و فعال‌سازی", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 15),
//               const Text(
//                 "کاربر محترم ابتدا به حساب عزیزی بانک 659285329538 هزینه پلن مورد نظر را پرداخت نموده، سپس عکس فیش را به اکانت تلگرام ارسال کنید تا اشتراک شما فعال گردد.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(height: 1.5),
//                 textDirection: TextDirection.rtl,
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
//                 child: const Text("متوجه شدم"),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:med_exam_app/models/student_class.dart';
import 'package:med_exam_app/utils/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PlanScreen extends StatefulWidget {
  final List<StudentClass> availablePlans;
  const PlanScreen({super.key, required this.availablePlans});
  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  String _userName = "";
  String _userEmail = "";
  String _adminTelegram = "Ramin0121";

  @override
  void initState() { super.initState(); _loadUserData(); }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? "کاربر";
      _userEmail = prefs.getString('userEmail') ?? "";
      _adminTelegram = prefs.getString('adminTelegram') ?? "Ramin0121";
    });
  }

  void _sendOrderToTelegram(StudentClass plan, String duration, String price) async {
    final String message = "سفارش جدید اشتراک:\nکاربر: $_userName\nبسته: ${plan.name}\nمدت: $duration\nقیمت: $price افغانی";
    final url = Uri.parse("https://t.me/$_adminTelegram?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(url)) { await launchUrl(url, mode: LaunchMode.externalApplication); }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('عضویت ویژه')),
        body: widget.availablePlans.isEmpty
            ? const Center(child: Text("پلنی یافت نشد."))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.availablePlans.length,
                itemBuilder: (context, index) => _buildFullPlanCard(widget.availablePlans[index]),
              ),
      ),
    );
  }

  Widget _buildFullPlanCard(StudentClass plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
            child: Text(plan.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
          ),
          _buildOption("اشتراک یک‌ماهه", plan.monthlyPrice, Icons.calendar_today, () => _sendOrderToTelegram(plan, "یک‌ماهه", plan.monthlyPrice)),
          const Divider(height: 1),
          _buildOption("اشتراک کامل سمستر", plan.semesterPrice, Icons.school, () => _sendOrderToTelegram(plan, "کامل", plan.semesterPrice)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(onPressed: _showPaymentInstructions, child: const Text("راهنمای پرداخت")),
          )
        ],
      ),
    );
  }

  Widget _buildOption(String title, String price, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: Text("$price افغانی", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
      onTap: onTap,
    );
  }

  void _showPaymentInstructions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("راهنمای فعال‌سازی", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const Text("مبلغ را به حساب عزیزی بانک ۶۵۹۲۸۵۳۲۹۵۳۸ واریز کرده و تصویر فیش را در تلگرام ارسال کنید.", textAlign: TextAlign.center, style: TextStyle(height: 1.5)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("متوجه شدم")),
          ],
        ),
      ),
    );
  }
}