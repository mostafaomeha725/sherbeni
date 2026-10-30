import 'package:flutter/material.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/features/atendance/domain/entities/manual_search_student_entity.dart';
import 'manual_attendance_section_detail_row.dart';
import 'manual_attendance_section_status_badge.dart';

class ManualAttendanceSectionStudentCard extends StatelessWidget {
  final ManualSearchStudentEntity student;
  final VoidCallback? onTap;
  final bool isSubmitting;
  final bool showSuccess;

  const ManualAttendanceSectionStudentCard({
    super.key,
    required this.student,
    required this.onTap,
    required this.isSubmitting,
    this.showSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSubmitting ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: showSuccess
                    ? Colors.green[300]!
                    : AppLightColors.primary.withValues(alpha: 0.3),
                width: 1.2,
              ),
              gradient: LinearGradient(
                colors: showSuccess
                    ? [Colors.green[50]!, Colors.green[50]!]
                    : [AppLightColors.primaryLight, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: showSuccess
                            ? Colors.green[100]
                            : AppLightColors.primaryLight,
                        child: Icon(
                          showSuccess
                              ? Icons.check_circle_rounded
                              : Icons.person_rounded,
                          color: showSuccess
                              ? Colors.green[700]
                              : AppLightColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.studentName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              student.studentCode,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSubmitting)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppLightColors.primary,
                          ),
                        )
                      else if (showSuccess)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 22,
                        )
                      else
                        Icon(
                          Icons.touch_app_rounded,
                          color: AppLightColors.primary.withValues(alpha: 0.7),
                          size: 20,
                        ),
                    ],
                  ),
                  const Divider(height: 16, thickness: 0.5),
                  ManualAttendanceSectionDetailRow(
                    icon: Icons.phone_rounded,
                    value: student.phone.isNotEmpty ? student.phone : '—',
                  ),
                  const SizedBox(height: 4),
                  ManualAttendanceSectionDetailRow(
                    icon: Icons.email_rounded,
                    value: student.email.isNotEmpty ? student.email : '—',
                  ),
                  if (student.educationalLevel.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ManualAttendanceSectionDetailRow(
                      icon: Icons.school_rounded,
                      value: student.educationalLevel,
                    ),
                  ],
                  if (student.status.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    ManualAttendanceSectionStatusBadge(status: student.status),
                  ],
                  if (!isSubmitting && !showSuccess) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: AppLightColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Tap to record attendance',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppLightColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
