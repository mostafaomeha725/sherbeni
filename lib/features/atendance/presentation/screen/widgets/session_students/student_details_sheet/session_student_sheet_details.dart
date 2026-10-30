import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/utils/url_launcher_util.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_attendance_entity.dart';
import 'session_student_info_row.dart';

class SessionStudentSheetDetails extends StatelessWidget {
  final SessionAttendanceEntity student;

  const SessionStudentSheetDetails({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final hasStudentPhone =
        student.phoneNumber != null && student.phoneNumber!.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          SessionStudentInfoRow(
            icon: Icons.qr_code_scanner_rounded,
            title: "تاريخ ووقت المسح",
            value: "${student.date} • ${student.time}",
          ),
          if (student.sessionTime != null && student.sessionTime!.isNotEmpty) ...[
            Divider(height: 16.h, color: const Color(0xFFE2E8F0)),
            SessionStudentInfoRow(
              icon: Icons.event_note_rounded,
              title: "موعد الحصة",
              value: "${student.sessionDate ?? student.date} • ${student.sessionTime}",
            ),
          ],
          if (hasStudentPhone) ...[
            Divider(height: 16.h, color: const Color(0xFFE2E8F0)),
            SessionStudentInfoRow(
              icon: Icons.phone_android_rounded,
              iconColor: const Color(0xFF2563EB),
              title: "هاتف الطالب (اضغط للاتصال)",
              value: student.phoneNumber!,
              onTap: () => UrlLauncherUtil.launchPhone(student.phoneNumber!),
            ),
          ],
        ],
      ),
    );
  }
}
