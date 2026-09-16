import 'package:qrattendance/core/widgets/app_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSearch extends StatelessWidget {
  const CustomSearch({
    super.key,
    required this.controller,
    this.hintText = "Search...",
    this.onChanged,
    this.onSubmitted,
    this.borderColor,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return AppFormField(
      controller: controller,
      hintText: hintText,
      fillColor: Colors.white,
      radius: 16.r,
      borderColor: borderColor ?? Colors.transparent,
      prefixIcon: Padding(
        padding: EdgeInsets.only(left: 8.w),
        child: Icon(Icons.search, color: const Color(0xFF94A3B8), size: 24.sp),
      ),
      maxLines: 1,
      contentPadding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
    );
  }
}
