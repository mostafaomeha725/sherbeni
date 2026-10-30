import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/domain/entities/student_entity.dart';
import 'student_data_action_buttons.dart';
import 'student_data_details.dart';
import 'student_data_header.dart';
import 'student_homework_input.dart';

class StudentDataBottomSheetContent extends StatelessWidget {
  final StudentEntity? student;
  final SessionEntity? session;
  final bool showHomework;
  final bool isOffline;
  final String? offlineStudentName;
  final TextEditingController gradeController;
  final bool isLoading;
  final VoidCallback onSubmitGrade;

  const StudentDataBottomSheetContent({
    super.key,
    required this.student,
    required this.session,
    required this.showHomework,
    required this.isOffline,
    required this.offlineStudentName,
    required this.gradeController,
    required this.isLoading,
    required this.onSubmitGrade,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 24.h,
        bottom: bottomPadding > 0 ? bottomPadding + 16.h : safeBottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const StudentDataHeader(),
            StudentDataDetails(
              student: student,
              isOffline: isOffline,
              offlineStudentName: offlineStudentName,
              showStudentName: !(showHomework && isOffline),
            ),
            if (showHomework && session != null)
              StudentHomeworkInput(
                homeworkName: session!.homeworkName ?? 'Home Work',
                gradeController: gradeController,
                isLoading: isLoading,
              ),
            SizedBox(height: 24.h),
            StudentDataActionButtons(
              showHomework: showHomework,
              isLoading: isLoading,
              onSubmitGrade: onSubmitGrade,
            ),
          ],
        ),
      ),
    );
  }
}
