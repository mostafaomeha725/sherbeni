import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/utils/url_launcher_util.dart';

class StudentDataPhoneRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String phone;
  final ThemeData theme;

  const StudentDataPhoneRow({
    super.key,
    required this.icon,
    required this.title,
    required this.phone,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhone = phone.isNotEmpty && phone != 'null';

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppLightColors.primaryLight,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppLightColors.primary, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    hasPhone ? phone : "غير متوفر",
                    textDirection: TextDirection.ltr,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: hasPhone ? Colors.black87 : Colors.grey[400],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (hasPhone) ...[
            SizedBox(width: 16.w),
            InkWell(
              onTap: () async {
                try {
                  await UrlLauncherUtil.launchPhone(phone);
                } catch (e) {
                  debugPrint('Could not launch phone: $e');
                }
              },
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.call, color: Colors.green, size: 20.sp),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
