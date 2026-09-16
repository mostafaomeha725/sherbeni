import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/widgets/app_form_field.dart';

class QuizGradesCardBadgeEditing extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int? quizMaxGrade;
  final VoidCallback onSave;

  const QuizGradesCardBadgeEditing({
    super.key,
    required this.controller,
    required this.focusNode,
    this.quizMaxGrade,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90.w, // Fixed total width to prevent overlapping student info
      height: 46.h, // Match normal badge height exactly
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: AppFormField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              hintText: quizMaxGrade != null ? '/$quizMaxGrade' : '0',
              contentPadding: EdgeInsets.zero, // Compact padding
              radius: 12.r,
              fillColor: const Color(0xFFF8FAFC),
              borderColor: const Color(0xFF16A34A).withValues(alpha: 0.5),
              onFieldSubmitted: (_) => onSave(),
            ),
          ),
          SizedBox(width: 4.w),
          InkWell(
            onTap: onSave,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: 36.w, // Compact square-ish button
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.3),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.check_rounded,
                  color: const Color(0xFF16A34A),
                  size: 20.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
