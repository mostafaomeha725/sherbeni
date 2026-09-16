import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/core/widgets/custom_button.dart';

class SessionStudentsEmptyCard extends StatelessWidget {
  const SessionStudentsEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_alt_outlined,
            size: 64.r,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          AppText(
            'لا يوجد حضور لهذه الجلسة',
            style: font16w500.copyWith(color: Colors.grey.shade600),
            alignment: AlignmentDirectional.center,
          ),
        ],
      ),
    );
  }
}

class SessionStudentsOfflineCard extends StatelessWidget {
  final int count;

  const SessionStudentsOfflineCard({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24.w),
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        decoration: BoxDecoration(
          color: AppLightColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15.r,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64.r,
              color: AppLightColors.primary,
            ),
            SizedBox(height: 16.h),
            AppText(
              'وضع عدم الاتصال',
              style: font16w700.copyWith(color: AppLightColors.black),
              alignment: AlignmentDirectional.center,
            ),
            SizedBox(height: 8.h),
            AppText(
              'تم تسجيل حضور $count طالب(ة) في هذه الحصة محلياً. سيتم مزامنة البيانات عند توفر الإنترنت.',
              style: font14w500.copyWith(color: Colors.grey.shade600),
              alignment: AlignmentDirectional.center,
              maxLines: 3,
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppLightColors.primaryLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_alt_rounded,
                    color: AppLightColors.primary,
                    size: 24.r,
                  ),
                  SizedBox(width: 8.w),
                  AppText(
                    '$count',
                    style: font24w700.copyWith(color: AppLightColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
