import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';

class SelectClassDateSection extends StatelessWidget {
  final String dayName;
  final String dayNumber;
  final String monthName;

  const SelectClassDateSection({
    super.key,
    required this.dayName,
    required this.dayNumber,
    required this.monthName,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  dayName,
                  style: font12w500.copyWith(color: AppLightColors.primary),
                  alignment: AlignmentDirectional.center,
                ),
                SizedBox(height: 2.h),
                AppText(
                  dayNumber,
                  style: font24w700.copyWith(color: const Color(0xFF222222)),
                  alignment: AlignmentDirectional.center,
                ),
                SizedBox(height: 2.h),
                AppText(
                  monthName,
                  style: font12w500.copyWith(color: const Color(0xFF888888)),
                  alignment: AlignmentDirectional.center,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(width: 1.w, color: const Color(0xFFE5E5EA)),
        ],
      ),
    );
  }
}
