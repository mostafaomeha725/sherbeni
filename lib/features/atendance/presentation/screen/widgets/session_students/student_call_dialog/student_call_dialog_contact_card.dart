import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'student_call_dialog_phone_tile.dart';

class StudentCallDialogContactCard extends StatelessWidget {
  final String? parentPhoneNumber;
  final String? studentPhoneNumber;

  const StudentCallDialogContactCard({
    super.key,
    required this.parentPhoneNumber,
    this.studentPhoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    final hasStudentPhone =
        studentPhoneNumber != null && studentPhoneNumber!.trim().isNotEmpty;

    return Column(
      children: [
        StudentCallDialogPhoneTile(
          icon: Icons.phone_in_talk_rounded,
          title: 'رقم ولي الأمر',
          phoneNumber: parentPhoneNumber,
        ),
        if (hasStudentPhone) ...[
          SizedBox(height: 10.h),
          StudentCallDialogPhoneTile(
            icon: Icons.phone_android_rounded,
            title: 'هاتف الطالب',
            phoneNumber: studentPhoneNumber,
          ),
        ],
      ],
    );
  }
}
