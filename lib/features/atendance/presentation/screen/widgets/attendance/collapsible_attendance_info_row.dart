import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';

class CollapsibleAttendanceInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const CollapsibleAttendanceInfoRow({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Icon(icon, size: 16.sp, color: const Color(0xFF777777)),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: AppText(
                text,
                style: font14w500.copyWith(color: const Color(0xFF555555)),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
