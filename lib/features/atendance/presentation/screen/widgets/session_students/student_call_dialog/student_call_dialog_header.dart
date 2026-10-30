import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/constants/strings.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';

class StudentCallDialogHeader extends StatelessWidget {
  final String name;
  final String? picture;
  final String statusText;
  final Color statusColor;
  final Color statusBgColor;
  final IconData statusIcon;

  const StudentCallDialogHeader({
    super.key,
    required this.name,
    this.picture,
    required this.statusText,
    required this.statusColor,
    required this.statusBgColor,
    required this.statusIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.topEnd,
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 18.sp,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ),
        Container(
          width: 72.r,
          height: 72.r,
          decoration: BoxDecoration(
            color: AppLightColors.primaryLight,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppLightColors.primary.withValues(alpha: 0.25),
              width: 2.w,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: picture != null && picture!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: picture!.startsWith('http')
                      ? picture!
                      : '${AppStrings.baseUrl}$picture',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Icon(
                    Icons.person_rounded,
                    color: AppLightColors.primary,
                    size: 36.r,
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.person_rounded,
                    color: AppLightColors.primary,
                    size: 36.r,
                  ),
                )
              : Icon(
                  Icons.person_rounded,
                  color: AppLightColors.primary,
                  size: 36.r,
                ),
        ),
        SizedBox(height: 14.h),
        AppText(
          name,
          style: font18w700.copyWith(color: const Color(0xFF1E293B)),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          alignment: AlignmentDirectional.center,
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: statusBgColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                statusIcon,
                size: 14.sp,
                color: statusColor,
              ),
              SizedBox(width: 5.w),
              AppText(
                statusText,
                style: font12w700.copyWith(
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
