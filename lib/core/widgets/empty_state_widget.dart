import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';

class EmptyStateWidget extends StatelessWidget {
  final String text;
  final String subtitle;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.text,
    this.subtitle = 'No data available to display at the moment.',
    this.icon = Icons.folder_open_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(32.w),
                decoration: const BoxDecoration(
                  color: AppLightColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 80.sp, color: AppLightColors.primary),
              ),
              SizedBox(height: 24.h),
              AppText(
                text,
                alignment: AlignmentDirectional.center,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  color: const Color(0xff333333),
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
              ),
              SizedBox(height: 8.h),
              AppText(
                subtitle,
                alignment: AlignmentDirectional.center,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF777777),
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
