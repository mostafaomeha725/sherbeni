import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/domain/entities/student_entity.dart';

class QuizGradesDialogStudentInfo extends StatelessWidget {
  final StudentEntity student;

  const QuizGradesDialogStudentInfo({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          AppText(
            student.name,
            style: font14w700.copyWith(
              color: const Color(0xFF334155),
              fontSize: 15.sp,
            ),
            alignment: AlignmentDirectional.center,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_rounded,
                size: 14.sp,
                color: const Color(0xFF94A3B8),
              ),
              SizedBox(width: 4.w),
              AppText(
                student.studentQrCode,
                style: font14w700.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
