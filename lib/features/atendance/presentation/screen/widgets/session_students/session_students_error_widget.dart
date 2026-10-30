import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_button.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';

class SessionStudentsErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const SessionStudentsErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.r, color: Colors.red.shade400),
          SizedBox(height: 16.h),
          AppText(
            message,
            style: font14w500.copyWith(color: AppLightColors.black),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: 120.w,
            child: AppButton(
              text: 'إعادة المحاولة',
              onPressed: onRetry,
              height: 40.h,
              radius: 8.r,
              textSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
