import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:med_exam_app/utils/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  
  int _step = 1; // 1: Email, 2: Code, 3: New Password
  bool _isLoading = false;
  final String API_URL = "https://medexam.saberyinstitute.com/api";

  void _showMsg(String text, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text, textAlign: TextAlign.right), backgroundColor: error ? Colors.red : Colors.green));
  }

  // مرحله ۱: ارسال کد به ایمیل
  Future<void> _sendCode() async {
    setState(() => _isLoading = true);
    try {
      await Dio().post('$API_URL/send-reset-code', data: {'email': _emailController.text.trim()},
        options: Options(headers: {'Accept': 'application/json'}),
      );
      setState(() => _step = 2);
      _showMsg("کد تایید ارسال شد", error: false);
    } on DioException catch (e) {
  String errorMsg = "خطا در ارتباط با سرور";
  
  if (e.response?.data != null) {
    // چک می‌کنیم اگر دیتا به صورت Map بود از فیلد message استفاده کن
    if (e.response?.data is Map) {
      errorMsg = e.response?.data['message'] ?? errorMsg;
    } 
    // اگر سرور فقط یک رشته برگردانده بود (مثلا متن خطا)
    else if (e.response?.data is String) {
      errorMsg = e.response?.data;
    }
  }
  
  _showMsg(errorMsg);
} finally { setState(() => _isLoading = false); }
  }

  // مرحله ۲: تایید و تغییر رمز
  Future<void> _resetPass() async {
    if(_passController.text != _confirmPassController.text) { _showMsg("تکرار رمز درست نیست"); return; }
    setState(() => _isLoading = true);
    try {
      await Dio().post('$API_URL/reset-password', data: {
        'email': _emailController.text.trim(),
        'code': _codeController.text.trim(),
        'password': _passController.text,
        'password_confirmation': _confirmPassController.text,
      });
      _showMsg("رمز با موفقیت تغییر کرد. وارد شوید", error: false);
      Navigator.pop(context);
    } on DioException catch (e) {
      _showMsg(e.response?.data['message'] ?? "خطا در عملیات");
    } finally { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('بازیابی رمز عبور')),
        body: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              if (_step == 1) ...[
                const Text("ایمیل خود را برای دریافت کد تایید وارد کنید:"),
                const SizedBox(height: 20),
                TextField(controller: _emailController, decoration: const InputDecoration(labelText: "ایمیل")),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _isLoading ? null : _sendCode, child: _isLoading ? const CircularProgressIndicator() : const Text("ارسال کد")),
              ],
              if (_step == 2) ...[
                Text("کد ارسال شده به ${_emailController.text} را وارد کنید:"),
                const SizedBox(height: 15),
                TextField(controller: _codeController, decoration: const InputDecoration(labelText: "کد ۶ رقمی"), keyboardType: TextInputType.number),
                const SizedBox(height: 15),
                TextField(controller: _passController, decoration: const InputDecoration(labelText: "رمز جدید"), obscureText: true),
                const SizedBox(height: 15),
                TextField(controller: _confirmPassController, decoration: const InputDecoration(labelText: "تکرار رمز جدید"), obscureText: true),
                const SizedBox(height: 25),
                ElevatedButton(onPressed: _isLoading ? null : _resetPass, child: _isLoading ? const CircularProgressIndicator() : const Text("ثبت رمز جدید")),
              ]
            ],
          ),
        ),
      ),
    );
  }
}