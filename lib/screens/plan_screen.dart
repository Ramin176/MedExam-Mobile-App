
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:med_exam_app/models/student_class.dart';
// import 'package:med_exam_app/utils/app_theme.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// class PlanScreen extends StatefulWidget {
//   final List<StudentClass> availablePlans;
//   const PlanScreen({super.key, required this.availablePlans});
//   @override
//   State<PlanScreen> createState() => _PlanScreenState();
// }

// class _PlanScreenState extends State<PlanScreen> {
//   String _userName = "";
//   String _userEmail = "";
//   String _adminTelegram = "Ramin0121";

//   @override
//   void initState() { super.initState(); _loadUserData(); }

//   Future<void> _loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _userName = prefs.getString('userName') ?? "کاربر";
//       _userEmail = prefs.getString('userEmail') ?? "";
//       _adminTelegram = prefs.getString('adminTelegram') ?? "Ramin0121";
//     });
//   }

//   void _sendOrderToTelegram(StudentClass plan, String duration, String price) async {
//     final String message = "سفارش جدید اشتراک:\nکاربر: $_userName\nبسته: ${plan.name}\nمدت: $duration\nقیمت: $price افغانی";
//     final url = Uri.parse("https://t.me/$_adminTelegram?text=${Uri.encodeComponent(message)}");
//     if (await canLaunchUrl(url)) { await launchUrl(url, mode: LaunchMode.externalApplication); }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(title: const Text('عضویت ویژه')),
//         body: widget.availablePlans.isEmpty
//             ? const Center(child: Text("پلنی یافت نشد."))
//             : ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: widget.availablePlans.length,
//                 itemBuilder: (context, index) => _buildFullPlanCard(widget.availablePlans[index]),
//               ),
//       ),
//     );
//   }

//   Widget _buildFullPlanCard(StudentClass plan) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 20),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             width: double.infinity,
//             decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
//             child: Text(plan.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
//           ),
//           _buildOption("اشتراک یک‌ماهه", plan.monthlyPrice, Icons.calendar_today, () => _sendOrderToTelegram(plan, "یک‌ماهه", plan.monthlyPrice)),
//           const Divider(height: 1),
//           _buildOption("اشتراک کامل سمستر", plan.semesterPrice, Icons.school, () => _sendOrderToTelegram(plan, "کامل", plan.semesterPrice)),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: ElevatedButton(onPressed: _showPaymentInstructions, child: const Text("راهنمای پرداخت")),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildOption(String title, String price, IconData icon, VoidCallback onTap) {
//     return ListTile(
//       leading: Icon(icon, color: AppColors.primary),
//       title: Text(title),
//       trailing: Text("$price افغانی", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
//       onTap: onTap,
//     );
//   }

//   void _showPaymentInstructions() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (_) => Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text("راهنمای فعال‌سازی", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 15),
//             const Text("مبلغ را به حساب عزیزی بانک ۶۵۹۲۸۵۳۲۹۵۳۸ واریز کرده و تصویر فیش را در تلگرام ارسال کنید.", textAlign: TextAlign.center, style: TextStyle(height: 1.5)),
//             const SizedBox(height: 20),
//             ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("متوجه شدم")),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:med_exam_app/models/student_class.dart';
import 'package:med_exam_app/utils/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PlanScreen extends StatefulWidget {
  final List<StudentClass> availablePlans;
  const PlanScreen({super.key, required this.availablePlans});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  String _userName = "";
  String _adminTelegram = "Ramin0121"; // مقدار پیش‌فرض اگر آفلاین بود و دیتایی نداشت

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    var settingsBox = await Hive.openBox('settings');
    
    setState(() {
      _userName = prefs.getString('userName') ?? "کاربر";
      // دریافت آیدی تلگرام از حافظه آفلاین که در HomeScreen ذخیره شده بود
      _adminTelegram = settingsBox.get('admin_telegram', defaultValue: "Ramin0121");
    });
  }

  void _sendOrderToTelegram(StudentClass plan, String duration, String price) async {
    final String message = """
*📣 سفارش جدید اشتراک*
👤 *کاربر:* $_userName
📦 *بسته:* ${plan.name}
⏳ *مدت:* $duration
💵 *قیمت:* $price افغانی
--------------------------
لطفاً پس از واریز، تصویر فیش را ارسال کنید.
""";

    final url = Uri.parse("https://t.me/$_adminTelegram?text=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تلگرام نصب نیست یا آیدی ادمین نامعتبر است."))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('خرید اشتراک و پلن‌ها')),
        body: widget.availablePlans.isEmpty
            ? const Center(child: Text("در حال حاضر پلنی برای نمایش وجود ندارد."))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.availablePlans.length,
                itemBuilder: (context, index) => _buildPlanCard(widget.availablePlans[index]),
              ),
      ),
    );
  }

  Widget _buildPlanCard(StudentClass plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Text(
              plan.name,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          _buildOptionTile(
            title: "اشتراک ماهوار (۳۰ روزه)",
            price: plan.monthlyPrice,
            icon: Icons.calendar_month,
            onTap: () => _sendOrderToTelegram(plan, "یک‌ماهه", plan.monthlyPrice),
          ),
          const Divider(height: 1),
          _buildOptionTile(
            title: "اشتراک مکمل سمستر",
            price: plan.semesterPrice,
            icon: Icons.school,
            onTap: () => _sendOrderToTelegram(plan, "سمستروار", plan.semesterPrice),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: ElevatedButton.icon(
              onPressed: _showPaymentGuide,
              icon: const Icon(Icons.help_outline),
              label: const Text("راهنمای پرداخت و فعال‌سازی"),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOptionTile(
      {required String title, required String price, required IconData icon, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Text("$price افغانی", style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
      subtitle: const Text("سفارش از طریق تلگرام"),
      onTap: onTap,
    );
  }

  void _showPaymentGuide() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("راهنمای پرداخت", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const Text(
              " مبلغ را به حساب عزیزی بانک ۶۵۹۲۸۵۳۲۹۵۳۸ واریز کنید.\n روی پلن مورد نظر کلیک کنید تا وارد تلگرام شوید.\n تصویر فیش را ارسال کنید تا دسترسی شما فعال شود.",
              textAlign: TextAlign.right,
              style: TextStyle(height: 1.8),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("متوجه شدم")),
          ],
        ),
      ),
    );
  }
}