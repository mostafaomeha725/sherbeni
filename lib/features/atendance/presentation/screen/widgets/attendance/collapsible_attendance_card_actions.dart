import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/bouncing_widgets.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';

class CollapsibleAttendanceCardActions extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback onDelete;

  const CollapsibleAttendanceCardActions({
    super.key,
    this.onRetry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onRetry != null) ...[
          BounceIt(
            onPressed: onRetry!,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.refresh, color: Colors.blue, size: 16.sp),
                  SizedBox(width: 4.w),
                  AppText(
                    'إعادة المحاولة',
                    style: font12w700.copyWith(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
        ],
        BounceIt(
          onPressed: onDelete,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 16.sp,
                ),
                SizedBox(width: 4.w),
                AppText(
                  'حذف',
                  style: font12w700.copyWith(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
