import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/student_count_icon.dart';

class SelectClassActions extends StatelessWidget {
  final SessionEntity session;

  const SelectClassActions({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StudentCountIcon(session: session),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: const BoxDecoration(
            color: AppLightColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16.sp,
            color: AppLightColors.primary,
          ),
        ),
      ],
    );
  }
}
