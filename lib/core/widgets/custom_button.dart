import 'package:qrattendance/core/theme/dark_colors.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/core/theme/dimensions.dart';
import '/core/widgets/custom_text.dart';
import '../extensions/ext.dart';
import '../theme/light_colors.dart';
import 'bouncing_widgets.dart';

class AppButton extends StatelessWidget implements Equatable {
  final String text;
  final VoidCallback? onPressed;
  final double? radius;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient; // ✅ الجديد
  final Color? borderColor;
  final Color? textColor;
  final Color? hoveColor;
  final FontWeight? textWeight;
  final double? textSize;
  final double? elevation;
  final double? gapLeadingText;
  final Widget? child;
  final double? height;
  final double? letterSpacing;
  final BorderSide? side;
  final double textHeight;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.radius,
    this.contentPadding,
    this.color = AppLightColors.primary,
    this.gradient, // ✅
    this.textColor,
    this.hoveColor,
    this.textSize,
    this.textWeight,
    this.elevation,
    this.letterSpacing,
    this.height,
    this.textHeight = 1.5,
    this.side,
    this.margin,
    this.borderColor = Colors.transparent,
  }) : child = null,
       gapLeadingText = null;

  const AppButton.icon({
    super.key,
    required this.text,
    required this.onPressed,
    required this.child,
    this.gapLeadingText = 10,
    this.radius,
    this.contentPadding,
    this.color,
    this.gradient, // ✅
    this.borderColor,
    this.textColor,
    this.hoveColor,
    this.textSize,
    this.textWeight,
    this.elevation,
    this.letterSpacing,
    this.textHeight = 1.5,
    this.height,
    this.side,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return BounceIt(
      child: Container(
        height: height ?? 47.h,
        margin: margin,
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? color : null,
          borderRadius: BorderRadius.circular(radius ?? 12.r),
          border: Border.all(
            color:
                borderColor ??
                (Theme.of(context).brightness == Brightness.dark
                    ? AppDarkColors.formFieldBorder
                    : AppLightColors.formFieldBorder),
          ),
        ),
        child: TextButton(
          onPressed: onPressed,
          clipBehavior: Clip.antiAlias,
          style: TextButton.styleFrom(
            side: side,
            backgroundColor: gradient == null ? color : Colors.transparent,
            foregroundColor:
                textColor ??
                (Theme.of(context).brightness == Brightness.dark
                    ? AppDarkColors.black
                    : AppLightColors.white),
            padding: contentPadding ?? const EdgeInsets.all(8).r,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                radius ?? AppDimensions.defaultRadius,
              ),
              side: side ?? BorderSide.none,
            ),
            elevation: elevation,
            fixedSize: Size(double.infinity, height ?? 56.h),
          ),
          child: child == null
              ? AppText(
                  text,
                  alignment: AlignmentDirectional.center,
                  maxLines: 1,
                  textHeight: textHeight.r,
                  style: TextStyle(
                    fontWeight: textWeight ?? FontWeight.w600,
                    fontSize: textSize ?? 18.sp,
                    letterSpacing: letterSpacing,
                    color:
                        textColor ??
                        (Theme.of(context).brightness == Brightness.dark
                            ? AppDarkColors.white
                            : AppLightColors.white),
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    30.wSpace,
                    Expanded(
                      child: AppText(
                        text,
                        alignment: AlignmentDirectional.center,
                        maxLines: 1,
                        textHeight: textHeight.r,
                        style: TextStyle(
                          fontWeight: textWeight ?? FontWeight.w700,
                          fontSize: textSize ?? 14.sp,
                          letterSpacing: letterSpacing,
                          color:
                              textColor ??
                              (Theme.of(context).brightness == Brightness.dark
                                  ? AppDarkColors.white
                                  : AppLightColors.white),
                        ),
                      ),
                    ),
                    child!,
                  ],
                ),
        ),
      ),
    );
  }

  @override
  List<Object?> get props => [
    text,
    onPressed,
    radius,
    contentPadding,
    color,
    gradient, // ✅
    textColor,
    hoveColor,
    textSize,
    textWeight,
    elevation,
    letterSpacing,
    height,
    child,
    side,
    gapLeadingText,
  ];

  @override
  bool? get stringify => false;
}
