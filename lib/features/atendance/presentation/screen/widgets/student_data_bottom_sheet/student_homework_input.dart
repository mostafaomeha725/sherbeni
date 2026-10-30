import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/widgets/app_form_field.dart';
import 'student_info_row.dart';

class StudentHomeworkInput extends StatelessWidget {
  final String homeworkName;
  final TextEditingController gradeController;
  final bool isLoading;

  const StudentHomeworkInput({
    super.key,
    required this.homeworkName,
    required this.gradeController,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 16.h),
        StudentDataInfoRow(
          icon: Icons.book,
          title: "اسم الواجب",
          value: homeworkName,
          theme: theme,
        ),
        SizedBox(height: 16.h),
        AppFormField(
          controller: gradeController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          hintText: "Enter Homework Grade",
          enabled: !isLoading,
          prefixIcon: const Icon(Icons.score),
        ),
      ],
    );
  }
}
