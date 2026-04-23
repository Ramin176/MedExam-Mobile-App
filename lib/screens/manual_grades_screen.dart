import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:med_exam_app/models/manual_grade.dart';
import 'package:med_exam_app/utils/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ManualGradesScreen extends StatefulWidget {
  const ManualGradesScreen({super.key});

  @override
  State<ManualGradesScreen> createState() => _ManualGradesScreenState();
}

class _ManualGradesScreenState extends State<ManualGradesScreen> {
  Future<List<ManualGrade>>? _gradesFuture;

  @override
  void initState() {
    super.initState();
    _gradesFuture = _fetchManualGrades();
  }

  Future<List<ManualGrade>> _fetchManualGrades() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    
    final response = await Dio().get(
      "https://medexam.saberyinstitute.com/api/my-manual-grades",
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return (response.data['data'] as List).map((j) => ManualGrade.fromJson(j)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F7),
        appBar: AppBar(title: const Text('نتایج امتحانات فیزیکی ')),
        body: FutureBuilder<List<ManualGrade>>(
          future: _gradesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return const Center(child: Text("خطا در دریافت اطلاعات"));
            if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("هنوز نمره‌ای منتشر نشده است."));

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) => _buildGradeCard(snapshot.data![index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGradeCard(ManualGrade grade) {
    bool isPassed = grade.total >= 55;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          // هدر کارت (نام مضمون)
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isPassed ? AppColors.primary : AppColors.error,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(grade.subjectName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                  child: Text(grade.result, style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ),
          // بدنه کارت (جدول نمرات)
          Padding(
            padding: const EdgeInsets.all(15),
            child: Table(
              border: TableBorder.all(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
              children: [
                _buildTableRow("فعالیت صفی", grade.activity.toString()),
                _buildTableRow("امتحان وسط سمستر (20%)", grade.midterm.toString()),
                _buildTableRow("امتحان نهایی (چانس ۱)", grade.chance1?.toString() ?? "-"),
                if(grade.chance2 != null) _buildTableRow("چانس ۲", grade.chance2.toString()),
                if(grade.chance3 != null) _buildTableRow("چانس ۳", grade.chance3.toString()),
                _buildTableRow("مجموع نمرات", grade.total.toString(), isBold: true),
                _buildTableRow("فیصدی عمومی", "${grade.percentage}%", isBold: true),
              ],
            ),
          ),
          // فوتر کارت (درجه)
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Text("درجه در صنف: ${grade.rank ?? '-'}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
          )
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, String value, {bool isBold = false}) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8), child: Text(label, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal))),
        Padding(padding: const EdgeInsets.all(8), child: Center(child: Text(value, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)))),
      ],
    );
  }
}