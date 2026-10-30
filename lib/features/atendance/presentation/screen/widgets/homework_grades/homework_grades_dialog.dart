import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:qrattendance/core/widgets/app_form_field.dart';
import 'package:qrattendance/core/widgets/custom_button.dart';
import 'package:qrattendance/features/atendance/domain/entities/student_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/homework_grades/homework_grades_cubit.dart';

import 'package:qrattendance/features/atendance/presentation/screen/widgets/homework_grades/homework_grades_dialog_header.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/homework_grades/homework_grades_dialog_student_info.dart';

class HomeworkGradesDialog extends StatefulWidget {
  final StudentEntity student;
  final num? currentGrade;
  final num? homeworkMaxGrade;
  final String? homeworkName;

  const HomeworkGradesDialog({
    super.key,
    required this.student,
    this.currentGrade,
    this.homeworkMaxGrade,
    this.homeworkName,
  });

  @override
  State<HomeworkGradesDialog> createState() => _HomeworkGradesDialogState();
}

class _HomeworkGradesDialogState extends State<HomeworkGradesDialog> {
  late final TextEditingController _gradeController;
  late final FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _gradeController = TextEditingController(
      text: widget.currentGrade?.toString() ?? '',
    );
    _focusNode = FocusNode();
    // Request focus automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _gradeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveGrade() {
    if (_gradeController.text.isNotEmpty) {
      final grade = num.tryParse(_gradeController.text);
      if (grade != null) {
        if (widget.homeworkMaxGrade != null && grade > widget.homeworkMaxGrade!) {
          setState(() {
            _errorText = 'الدرجة لا يمكن أن تتخطى ${widget.homeworkMaxGrade}';
          });
          return;
        }
        context.read<HomeworkGradesCubit>().updateGrade(widget.student.id, grade);
      }
    }
    GoRouter.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Gradient
            HomeworkGradesDialogHeader(title: widget.homeworkName),

            // Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                children: [
                  // Student Details
                  HomeworkGradesDialogStudentInfo(student: widget.student),
                  SizedBox(height: 20.h), // Reduced from 24.h
                  // Input Field
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: AppFormField(
                      controller: _gradeController,
                      hintText: widget.homeworkMaxGrade != null
                          ? 'Enter grade (Max ${widget.homeworkMaxGrade})'
                          : 'Enter grade',
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      radius: 12.r, // Reduced from 16.r
                      fillColor: Colors.white,
                      borderColor: const Color(0xFFE2E8F0),
                      focusNode: _focusNode,
                      autofocus: true,
                      onChanged: (_) {
                        if (_errorText != null) {
                          setState(() {
                            _errorText = null;
                          });
                        }
                      },
                      // Rely on default padding which is usually smaller and standard
                      onFieldSubmitted: (_) => _saveGrade(),
                    ),
                  ),
                  if (_errorText != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      _errorText!,
                      style: TextStyle(color: Colors.red, fontSize: 12.sp),
                    ),
                  ],
                  SizedBox(height: 24.h), // Reduced from 32.h
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Cancel',
                          onPressed: () => GoRouter.of(context).pop(),
                          color: const Color(0xFFF1F5F9), // Slate 100
                          textColor: const Color(0xFF64748B), // Slate 500
                          elevation: 0,
                          height: 52.h,
                          textSize: 15.sp,
                          radius: 16.r,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: AppButton(
                          text: 'Save',
                          onPressed: _saveGrade,
                          color: const Color(0xFFF47B20), // Primary Orange
                          textColor: Colors.white,
                          elevation: 2,
                          height: 52.h,
                          textSize: 16.sp,
                          radius: 16.r,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
