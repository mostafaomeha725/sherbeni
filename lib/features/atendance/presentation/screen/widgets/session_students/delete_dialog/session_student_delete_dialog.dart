import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_attendance_entity.dart';
import 'session_student_delete_dialog_actions.dart';
import 'session_student_delete_dialog_header.dart';
import 'session_student_delete_dialog_student_card.dart';

class SessionStudentDeleteDialog extends StatelessWidget {
  final SessionAttendanceEntity student;
  final VoidCallback onConfirm;

  const SessionStudentDeleteDialog({
    super.key,
    required this.student,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required SessionAttendanceEntity student,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          SessionStudentDeleteDialog(student: student, onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        constraints: BoxConstraints(maxWidth: 380.w),
        decoration: BoxDecoration(
          color: AppLightColors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 28.r,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with Primary Icon Badge & Title
                    const SessionStudentDeleteDialogHeader(),
                    SizedBox(height: 16.h),

                    // Highlighted Student Card
                    SessionStudentDeleteDialogStudentCard(student: student),

                    SizedBox(height: 20.h),

                    // Cancel & Confirm Actions
                    SessionStudentDeleteDialogActions(onConfirm: onConfirm),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
