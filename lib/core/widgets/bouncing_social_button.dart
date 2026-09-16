import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/app_svg.dart';
import 'package:qrattendance/core/widgets/bouncing_widgets.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BouncingSocialButton extends StatelessWidget {
  const BouncingSocialButton({
    super.key,
    required this.text,
    this.onTap,
    this.assetName,
    this.icon,
    this.borderColor,
    this.textColor,
    this.textSize,
    this.color,
    this.gradient,
    this.leading,
    this.height,
  });

  final String text;
  final VoidCallback? onTap;

  final String? assetName;
  final IconData? icon;
  final Widget? leading;

  final Color? borderColor;
  final Color? textColor;
  final double? textSize;
  final Color? color;
  final Gradient? gradient;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return BounceIt(
      onPressed: onTap,
      child: Container(
        height: height ?? 48.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: gradient == null ? color : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor ?? const Color(0xFFDADADA)),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 👈 child مخصص
              if (leading != null) ...[
                leading!,
                SizedBox(width: 16.w),
              ]
              /// SVG
              else if (assetName != null) ...[
                AppSVG(
                  assetName: assetName!,
                  width: 20.w,
                  height: 20.h,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 10.w),
              ]
              /// Icon
              else if (icon != null) ...[
                Icon(icon, size: 20.sp, color: textColor ?? Colors.white),
                SizedBox(width: 10.w),
              ],

              AppText(
                text,
                maxLines: 1,
                alignment: AlignmentDirectional.center,
                style: font16w600.copyWith(
                  color: textColor ?? Colors.white,
                  fontSize: textSize ?? 16.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
