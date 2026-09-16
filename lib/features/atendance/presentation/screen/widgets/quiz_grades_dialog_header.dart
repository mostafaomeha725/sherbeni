import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/bouncing_widgets.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';

class QuizGradesDialogHeader extends StatelessWidget {
  const QuizGradesDialogHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24.h,
        bottom: 20.h,
        left: 20.w,
        right: 20.w,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF47B20), Color(0xFFF99D53)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BounceIt(
                child: GestureDetector(
                  onTap: () => GoRouter.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
              Icon(Icons.grading_rounded, color: Colors.white, size: 36.sp),
              SizedBox(width: 32.w), // Balance for the close button
            ],
          ),
          SizedBox(height: 12.h),
          AppText(
            'Grade Student',
            style: font18w700.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
            alignment: AlignmentDirectional.center,
          ),
        ],
      ),
    );
  }
}
