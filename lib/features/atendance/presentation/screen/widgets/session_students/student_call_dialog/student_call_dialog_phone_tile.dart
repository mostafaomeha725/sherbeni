import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/utils/url_launcher_util.dart';
import 'package:qrattendance/core/widgets/bouncing_widgets.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';

class StudentCallDialogPhoneTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? phoneNumber;

  const StudentCallDialogPhoneTile({
    super.key,
    required this.icon,
    required this.title,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    final hasNumber = phoneNumber != null && phoneNumber!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppLightColors.primaryLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppLightColors.primary.withValues(alpha: 0.2),
          width: 1.2.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppLightColors.primaryLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppLightColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(icon, size: 18.sp, color: AppLightColors.primary),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  style: font12w500.copyWith(color: const Color(0xFF64748B)),
                ),
                SizedBox(height: 2.h),
                AppText(
                  hasNumber ? phoneNumber! : 'غير متوفر',
                  style: font14w700.copyWith(
                    color: hasNumber
                        ? AppLightColors.primary
                        : const Color(0xFF94A3B8),
                    letterSpacing: hasNumber ? 0.6 : 0,
                  ),
                ),
              ],
            ),
          ),
          if (hasNumber)
            BounceIt(
              child: InkWell(
                borderRadius: BorderRadius.circular(10.r),
                onTap: () {
                  Navigator.of(context).pop();
                  UrlLauncherUtil.launchPhone(phoneNumber!);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppLightColors.primary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.call_rounded,
                        size: 14.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      AppText(
                        'اتصال',
                        style: font12w700.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
