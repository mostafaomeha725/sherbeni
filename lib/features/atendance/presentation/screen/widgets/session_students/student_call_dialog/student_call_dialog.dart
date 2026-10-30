import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/features/atendance/domain/entities/quiz_student_entity.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_attendance_entity.dart';
import 'student_call_dialog_action_button.dart';
import 'student_call_dialog_contact_card.dart';
import 'student_call_dialog_header.dart';

class StudentCallDialog extends StatelessWidget {
  final String name;
  final String? picture;
  final String? parentPhoneNumber;
  final String? studentPhoneNumber;
  final String statusText;
  final Color statusColor;
  final Color statusBgColor;
  final IconData statusIcon;

  const StudentCallDialog({
    super.key,
    required this.name,
    this.picture,
    this.parentPhoneNumber,
    this.studentPhoneNumber,
    required this.statusText,
    required this.statusColor,
    required this.statusBgColor,
    required this.statusIcon,
  });

  static Future<void> show(
    BuildContext context,
    SessionAttendanceEntity student,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StudentCallDialog(
        name: student.name,
        picture: student.picture,
        parentPhoneNumber: student.parentPhoneNumber,
        studentPhoneNumber: student.phoneNumber,
        statusText: student.isLate ? 'Late' : 'On Time',
        statusColor: student.isLate
            ? const Color(0xFFE53935)
            : const Color(0xFF43A047),
        statusBgColor: student.isLate
            ? const Color(0xFFFFF2F2)
            : const Color(0xFFF2FFF5),
        statusIcon: student.isLate
            ? Icons.timer_off_outlined
            : Icons.check_circle_outline_rounded,
      ),
    );
  }

  static Future<void> showForQuiz(
    BuildContext context,
    QuizStudentEntity student,
  ) {
    final bool isGraded = student.grade != null;
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StudentCallDialog(
        name: student.name,
        picture: student.picture,
        parentPhoneNumber: student.parentPhoneNumber,
        studentPhoneNumber: student.phoneNumber,
        statusText: isGraded ? 'Graded (${student.grade})' : 'Not Graded',
        statusColor: isGraded
            ? const Color(0xFF16A34A)
            : const Color(0xFFF59E0B),
        statusBgColor: isGraded
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEF3C7),
        statusIcon: isGraded
            ? Icons.check_circle_outline_rounded
            : Icons.pending_outlined,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Container(
        constraints: BoxConstraints(maxWidth: 360.w),
        decoration: BoxDecoration(
          color: AppLightColors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StudentCallDialogHeader(
                  name: name,
                  picture: picture,
                  statusText: statusText,
                  statusColor: statusColor,
                  statusBgColor: statusBgColor,
                  statusIcon: statusIcon,
                ),
                SizedBox(height: 18.h),
                StudentCallDialogContactCard(
                  parentPhoneNumber: parentPhoneNumber,
                  studentPhoneNumber: studentPhoneNumber,
                ),
                SizedBox(height: 18.h),
                const StudentCallDialogActionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
