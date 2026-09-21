import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';

class ShowSessionsErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ShowSessionsErrorWidget({
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
          Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 64.sp,
          ),
          SizedBox(height: 16.h),
          AppText(
            message,
            alignment: AlignmentDirectional.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xff333333),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF47B20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: onRetry,
              child: AppText(
                'إعادة المحاولة',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                alignment: AlignmentDirectional.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
