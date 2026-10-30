import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:qrattendance/core/widgets/custom_button.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_attendance_entity.dart';
import 'session_student_sheet_details.dart';
import 'session_student_sheet_header.dart';
import 'session_student_sheet_parent_call.dart';

class SessionStudentDetailsSheet extends StatelessWidget {
  final SessionAttendanceEntity student;

  const SessionStudentDetailsSheet({super.key, required this.student});

  static Future<void> show(
    BuildContext context,
    SessionAttendanceEntity student,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SessionStudentDetailsSheet(student: student),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 12.h,
        bottom: bottomPadding > 0 ? bottomPadding + 16.h : safeBottom + 20.h,
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
            // Drag handle
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 16.h),

            // Header (Avatar, Name, Status)
            SessionStudentSheetHeader(student: student),
            SizedBox(height: 20.h),

            // Parent Phone Call Card
            SessionStudentSheetParentCall(student: student),
            SizedBox(height: 16.h),

            // Scan & Session Details
            SessionStudentSheetDetails(student: student),
            SizedBox(height: 20.h),

            // Close Button
            AppButton(
              text: "إغلاق",
              color: const Color(0xFFF1F5F9),
              textColor: const Color(0xFF334155),
              radius: 12.r,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
