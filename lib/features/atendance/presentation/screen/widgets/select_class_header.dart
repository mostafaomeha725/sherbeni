import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';

class SelectClassHeader extends StatelessWidget {
  const SelectClassHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppLightColors.primary,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(Icons.class_outlined, color: Colors.white, size: 28.sp),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Select Class',
                style: font16w700.copyWith(color: const Color(0xFF222222)),
              ),
              SizedBox(height: 4.h),
              AppText(
                'Select a class for attendance.',
                style: font10w400.copyWith(color: const Color(0xFF777777)),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
