import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_attendance_entity.dart';
import 'student_attendance_card_badge.dart';
import 'student_attendance_card_delete_button.dart';
import 'student_attendance_date_time_row.dart';
import 'student_attendance_detail_row.dart';

class StudentAttendanceCardContent extends StatelessWidget {
  final SessionAttendanceEntity student;
  final VoidCallback? onDelete;

  const StudentAttendanceCardContent({
    super.key,
    required this.student,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Student Name & Detailed Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                student.name,
                style: font16w700.copyWith(
                  color: const Color(0xFF1E293B),
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 10.h),
              if (student.phoneNumber != null &&
                  student.phoneNumber!.isNotEmpty) ...[
                StudentAttendanceDetailRow(
                  icon: Icons.phone_android_rounded,
                  text: student.phoneNumber!,
                ),
                SizedBox(height: 6.h),
              ],
              // Scan: Date on line 1, Time under it on line 2
              StudentAttendanceDateTimeRow(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Scan',
                date: student.date,
                time: student.time,
              ),
              if (student.sessionDate != null ||
                  student.sessionTime != null) ...[
                SizedBox(height: 6.h),
                // Session: Date on line 1, Time under it on line 2
                StudentAttendanceDateTimeRow(
                  icon: Icons.event_note_rounded,
                  label: 'Session',
                  date: student.sessionDate ?? '',
                  time: student.sessionTime,
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 8.w),

        // Right Column: Badge on Top, and Delete Button directly UNDER it
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            StudentAttendanceCardBadge(isLate: student.isLate),
            if (onDelete != null) ...[
              SizedBox(height: 10.h),
              StudentAttendanceCardDeleteButton(onDelete: onDelete!),
            ],
          ],
        ),
      ],
    );
  }
}
