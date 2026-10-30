import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StudentDataHeader extends StatelessWidget {
  const StudentDataHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        SizedBox(height: 16.h),
        CircleAvatar(
          radius: 30.r,
          backgroundColor: Colors.green,
          child: Icon(Icons.check, color: Colors.white, size: 40.sp),
        ),
        SizedBox(height: 16.h),
        Text(
          "تم تسجيل الحضور بنجاح",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
