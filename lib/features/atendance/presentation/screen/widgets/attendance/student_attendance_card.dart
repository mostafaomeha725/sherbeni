import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_attendance_entity.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/session_students/student_call_dialog/student_call_dialog.dart';
import 'student_attendance_card_avatar.dart';
import 'student_attendance_card_content.dart';

class StudentAttendanceCard extends StatelessWidget {
  final SessionAttendanceEntity student;
  final VoidCallback? onDelete;

  const StudentAttendanceCard({
    super.key,
    required this.student,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppLightColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.04),
            blurRadius: 20.r,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => StudentCallDialog.show(context, student),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: student.isLate
                        ? const Color(0xFFE53935)
                        : const Color(0xFF43A047),
                    width: 4.w,
                  ),
                  top: BorderSide(color: Colors.grey.shade200),
                  bottom: BorderSide(color: Colors.grey.shade200),
                  right: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StudentAttendanceCardAvatar(picture: student.picture),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: StudentAttendanceCardContent(
                        student: student,
                        onDelete: onDelete,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
