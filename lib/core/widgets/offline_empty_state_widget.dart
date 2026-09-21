import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';

class OfflineEmptyStateWidget extends StatelessWidget {
  final String description;
  final VoidCallback onRetry;

  const OfflineEmptyStateWidget({
    super.key,
    required this.description,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.grey, size: 64.sp),
          SizedBox(height: 16.h),
          AppText(
            'No Offline Data Available',
            alignment: AlignmentDirectional.center,
            style: TextStyle(
              fontSize: 18.sp,
              color: const Color(0xff333333),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          AppText(
            description,
            alignment: AlignmentDirectional.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xff777777),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
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
                'Retry',
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
