import 'package:qrattendance/core/theme/dark_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/dimensions.dart';
import '../theme/light_colors.dart';
import '../theme/styles.dart';

class AppFormField extends StatefulWidget {
  const AppFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.suffixIcon,
    this.textInputAction,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.onSaved,
    this.validator,
    this.borderColor,
    this.validatedText,
    this.onFieldSubmitted,
    this.onChanged,
    this.onTap,
    this.maxLength,
    this.minLines,
    this.maxLines,
    this.fillColor,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.radius = 12,
    this.borderWidth,
    this.obsecureText = false,
    this.readOnly = false,
    this.autofillHints,
    this.contentPadding,
    this.focusNode,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hintText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final bool? enabled;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final String? validatedText;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final AutovalidateMode autovalidateMode;
  final double? radius;
  final double? borderWidth;
  final bool obsecureText;
  final bool readOnly;
  final Iterable<String>? autofillHints;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final Color? borderColor;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<AppFormField> createState() => _AppFormFieldState();
}

class _AppFormFieldState extends State<AppFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: widget.readOnly,
      autofillHints: widget.autofillHints,
      obscureText: widget.obsecureText,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onChanged: (value) {
        setState(() {});
        widget.onChanged?.call(value);
      },
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      validator: widget.validator ?? (value) => null,
      onSaved: widget.onSaved,
      onFieldSubmitted: widget.onFieldSubmitted,
      onTap: widget.onTap,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      inputFormatters: widget.inputFormatters,
      textAlign: widget.textAlign,
      autovalidateMode: widget.autovalidateMode,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: widget.hintText,
        hintStyle: font14w500.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppDarkColors.offwhite
              : Colors.grey,
        ),
        filled: true,
        fillColor: widget.fillColor ?? Colors.white,
        contentPadding: widget.contentPadding ?? EdgeInsets.all(15.h),
        prefixIcon: widget.prefixIcon,
        prefixIconConstraints: BoxConstraints(minWidth: 40.w, minHeight: 24.h),
        suffixIcon: widget.suffixIcon,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color:
                widget.borderColor ??
                (Theme.of(context).brightness == Brightness.dark
                    ? AppDarkColors.formFieldBorder
                    : AppLightColors.formFieldBorder),
            width: widget.borderWidth ?? 2.0
              ..w,
          ),
          borderRadius: BorderRadius.circular(
            widget.radius ?? AppDimensions.defaultRadius,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color:
                widget.borderColor ??
                (Theme.of(context).brightness == Brightness.dark
                    ? AppDarkColors.formFieldBorder
                    : AppLightColors.formFieldBorder),
            width: widget.borderWidth ?? 1.2
              ..w,
          ),
          borderRadius: BorderRadius.circular(
            widget.radius ?? AppDimensions.defaultRadius,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color:
                widget.borderColor ??
                (Theme.of(context).brightness == Brightness.dark
                    ? AppDarkColors.formFieldBorder
                    : AppLightColors.formFieldBorder),
            width: widget.borderWidth ?? 2.0
              ..w,
          ),
          borderRadius: BorderRadius.circular(
            widget.radius ?? AppDimensions.defaultRadius,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppLightColors.formfiledErrorColor,
            width: widget.borderWidth ?? 2.0
              ..w,
          ),
          borderRadius: BorderRadius.circular(
            widget.radius ?? AppDimensions.defaultRadius,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppLightColors.formfiledErrorColor,
            width: widget.borderWidth ?? 2.0
              ..w,
          ),
          borderRadius: BorderRadius.circular(
            widget.radius ?? AppDimensions.defaultRadius,
          ),
        ),
      ),
    );
  }
}
