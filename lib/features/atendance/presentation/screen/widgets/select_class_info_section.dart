import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';

class SelectClassInfoSection extends StatelessWidget {
  final String centerName;
  final String sessionName;
  final String sessionDate;

  const SelectClassInfoSection({
    super.key,
    required this.centerName,
    required this.sessionName,
    required this.sessionDate,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            centerName,
            style: font16w700.copyWith(color: const Color(0xFF222222)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.collections_bookmark_outlined,
                size: 16.sp,
                color: AppLightColors.primary,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: AppText(
                  sessionName,
                  style: font12w500.copyWith(color: const Color(0xFF555555)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16.sp,
                color: AppLightColors.primary,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: AppText(
                  sessionDate,
                  style: font11w500.copyWith(color: const Color(0xFF555555)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
