import 'package:flutter/material.dart';
import 'package:qrattendance/features/atendance/domain/entities/student_entity.dart';
import 'student_info_row.dart';
import 'student_phone_row.dart';

class StudentDataDetails extends StatelessWidget {
  final StudentEntity? student;
  final bool isOffline;
  final String? offlineStudentName;
  final bool showStudentName;

  const StudentDataDetails({
    super.key,
    required this.student,
    required this.isOffline,
    required this.offlineStudentName,
    this.showStudentName = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showStudentName)
          StudentDataInfoRow(
            icon: Icons.person,
            title: "اسم الطالب",
            value: student?.name ?? offlineStudentName ?? 'Offline Student',
            theme: theme,
          ),
        StudentDataInfoRow(
          icon: Icons.qr_code,
          title: "كود الطالب",
          value: student != null && student!.studentQrCode.isNotEmpty
              ? student!.studentQrCode
              : (student?.id ?? offlineStudentName ?? ''),
          theme: theme,
        ),
        if (student != null &&
            student!.group?.name != null &&
            student!.group!.name.isNotEmpty)
          StudentDataInfoRow(
            icon: Icons.school,
            title: "المرحلة الدراسية",
            value: student!.group!.name,
            theme: theme,
          ),
        if (!isOffline && student != null) ...[
          StudentDataPhoneRow(
            icon: Icons.phone_android_rounded,
            title: "رقم تليفون الطالب",
            phone: student!.studentPhone,
            theme: theme,
          ),
          StudentDataPhoneRow(
            icon: Icons.phone_rounded,
            title: "رقم تليفون ولي الأمر",
            phone: student!.parentPhone,
            theme: theme,
          ),
        ],
      ],
    );
  }
}
