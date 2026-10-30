import 'package:flutter/material.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/features/atendance/domain/entities/manual_search_student_entity.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/manual_attendance/manual_attendance_divider.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/manual_attendance/manual_attendance_info_row.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/manual_attendance/manual_attendance_phone_row.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/manual_attendance/manual_attendance_record_button.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/manual_attendance/manual_attendance_status_badge.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/manual_attendance/manual_attendance_success_banner.dart';

class ManualAttendanceStudentCard extends StatelessWidget {
  final ManualSearchStudentEntity student;
  final bool isSubmitting;
  final bool isSuccess;
  final Function(String) onMakeCall;
  final Function(String, {bool isError}) onShowTopMessage;
  final VoidCallback onSubmitAttendance;

  const ManualAttendanceStudentCard({
    super.key,
    required this.student,
    required this.isSubmitting,
    required this.isSuccess,
    required this.onMakeCall,
    required this.onShowTopMessage,
    required this.onSubmitAttendance,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Student Header Profile
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppLightColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppLightColors.primary.withOpacity(0.2), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        student.studentName.isNotEmpty ? student.studentName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppLightColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.studentName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (student.educationalLevel.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              student.educationalLevel,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                            ),
                          ),
                      ],
                    ),
                  ),
                  ManualAttendanceStatusBadge(status: student.status),
                ],
              ),
            ),
            
            // Details List
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ManualAttendanceInfoRow(
                    icon: Icons.tag_rounded,
                    label: 'Student Code',
                    value: student.studentCode,
                    canCopy: true,
                    onCopy: (msg) => onShowTopMessage(msg),
                  ),
                  const ManualAttendanceDivider(),
                  ManualAttendanceInfoRow(
                    icon: Icons.qr_code_rounded,
                    label: 'Student ID',
                    value: student.studentId,
                    canCopy: true,
                    onCopy: (msg) => onShowTopMessage(msg),
                  ),
                  const ManualAttendanceDivider(),
                  ManualAttendanceInfoRow(
                    icon: Icons.email_rounded,
                    label: 'Email',
                    value: student.email,
                    canCopy: true,
                    onCopy: (msg) => onShowTopMessage(msg),
                  ),
                  const ManualAttendanceDivider(),
                  ManualAttendancePhoneRow(
                    label: 'Student Phone',
                    phone: student.phone,
                    onCall: onMakeCall,
                  ),
                  const ManualAttendanceDivider(),
                  ManualAttendancePhoneRow(
                    label: 'Parent Phone',
                    phone: student.parentPhone,
                    onCall: onMakeCall,
                  ),
                ],
              ),
            ),

            // Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: isSuccess
                  ? const ManualAttendanceSuccessBanner()
                  : ManualAttendanceRecordButton(
                      isSubmitting: isSubmitting,
                      onPressed: onSubmitAttendance,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
