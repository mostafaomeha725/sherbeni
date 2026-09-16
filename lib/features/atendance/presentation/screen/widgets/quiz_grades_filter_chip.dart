import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/quiz_grades/quiz_grades_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/quiz_grades/quiz_grades_state.dart';

class QuizGradesFilterChip extends StatelessWidget {
  final String title;
  final QuizGradeFilter filter;
  final QuizGradeFilter currentFilter;

  const QuizGradesFilterChip({
    super.key,
    required this.title,
    required this.filter,
    required this.currentFilter,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = filter == currentFilter;
    return GestureDetector(
      onTap: () {
        context.read<QuizGradesCubit>().setFilter(filter);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF47B20) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFF47B20)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: AppText(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
