import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_attendance_entity.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/attendance/student_attendance_card_badge.dart';

class SessionStudentDeleteDialogStudentCard extends StatelessWidget {
  final SessionAttendanceEntity student;

  const SessionStudentDeleteDialogStudentCard({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with primary theme styling
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: AppLightColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppLightColors.primary.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: AppLightColors.primary,
                    size: 22.sp,
                  ),
                ),
              ),
              SizedBox(width: 10.w),

              // Student Name
              Expanded(
                child: AppText(
                  student.name,
                  style: font14w700.copyWith(color: const Color(0xFF1E293B)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),

              // Status Badge
              StudentAttendanceCardBadge(isLate: student.isLate),
            ],
          ),
          // SizedBox(height: 8.h),

          // // Scan Time Row
          // Row(
          //   children: [
          //     Icon(
          //       Icons.access_time_rounded,
          //       size: 14.sp,
          //       color: const Color(0xFF64748B),
          //     ),
          //     SizedBox(width: 6.w),
          //     AppText(
          //       'وقت التسجيل: ${student.date} • ${student.time}',
          //       style: font12w500.copyWith(color: const Color(0xFF64748B)),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
