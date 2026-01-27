// lib/screens/plan_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:med_exam_app/models/student_class.dart';
import 'package:med_exam_app/utils/app_theme.dart';
import 'package:url_launcher/url_launcher.dart'; // برای باز کردن لینک

// شماره تماس یا آیدی تلگرام ادمین
const String ADMIN_CONTACT = "Ramin0121"; 
const String CONTACT_MESSAGE = "سلام، من می‌خواهم بسته آموزشی [CLASS_NAME] را خریداری کنم.";


class PlanScreen extends StatelessWidget {
  // ما لیست کل صنف‌ها را از دیتابیس می‌خواهیم. 
  // اما چون Home Screen فقط کلاس‌های فعال را می‌گیرد، این صفحه را ساده‌تر می‌سازیم
  // و فقط اطلاعات صنف‌ها را برای نمایش پلن می‌گیریم. 
  
  // فرض می‌کنیم این لیست از یک API جداگانه (مثلاً /all-classes) گرفته شده.
  // برای سادگی، فعلاً از یک لیست ثابت استفاده می‌کنیم تا معماری را بهم نزنیم.
  // در واقعیت باید یک API بسازیم که تمام کلاس‌ها را بدون فیلتر فعال بودن، برگرداند.
  final List<StudentClass> availablePlans; // لیست پلن‌ها (همان کلاس‌ها)

  const PlanScreen({super.key, required this.availablePlans});
  
  // متد باز کردن تلگرام با پیام پیش‌فرض
  void _openTelegram(StudentClass plan) async {
    // پیام نهایی برای ادمین
    final message = CONTACT_MESSAGE.replaceFirst('[CLASS_NAME]', plan.name);
    
    // لینک برای باز کردن تلگرام
    final url = Uri.parse("https://t.me/$ADMIN_CONTACT?text=$message");
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // اگر تلگرام نصب نبود
      print('Could not launch $url');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('انتخاب بسته آموزشی (پلن)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                'برای ثبت‌نام در یکی از صنف‌های زیر، بر روی دکمه "ثبت سفارش" کلیک کنید تا سفارش شما به بخش مالی ارسال شود. فعال‌سازی نهایی توسط ادمین انجام خواهد شد.',
                style: TextStyle(fontSize: 14, color: AppColors.textDark),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ),
            
            // لیست پلن‌ها
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: availablePlans.length,
              itemBuilder: (context, index) {
                final plan = availablePlans[index];
                return _buildPlanCard(context, plan);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ساختار کارت هر پلن
  Widget _buildPlanCard(BuildContext context, StudentClass plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // عنوان پلن
            Text(
              plan.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 10),
            
            // جزئیات
            _buildDetailRow(
              icon: FontAwesomeIcons.book, 
              text: '${plan.subjects.length} مضمون',
            ),
            _buildDetailRow(
              icon: FontAwesomeIcons.clock, 
              text: 'دسترسی تا ${plan.endDate.year}/${plan.endDate.month}/${plan.endDate.day}',
            ),
            
            const Divider(height: 30),
            
            // قیمت و دکمه سفارش
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // قیمت
                Text(
                  '${plan.price} افغانی',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.success,
                  ),
                ),
                
                // دکمه سفارش
                SizedBox(
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () => _openTelegram(plan),
                    icon: const Icon(FontAwesomeIcons.telegram, size: 20),
                    label: const Text('ثبت سفارش از طریق تلگرام'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0088CC), // رنگ تلگرام
                      foregroundColor: AppColors.textLight,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // تابع کمکی برای نمایش جزئیات
  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(text, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Icon(icon, size: 16, color: AppColors.primary),
        ],
      ),
    );
  }
}