import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/constants/strings.dart';
import 'package:qrattendance/core/theme/light_colors.dart';

class StudentAttendanceCardAvatar extends StatelessWidget {
  final String? picture;

  const StudentAttendanceCardAvatar({super.key, this.picture});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.r,
      width: 48.r,
      decoration: const BoxDecoration(
        color: AppLightColors.primaryLight,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: picture != null && picture!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: picture!.startsWith('http')
                  ? picture!
                  : '${AppStrings.baseUrl}$picture',
              fit: BoxFit.cover,
              placeholder: (context, url) => Icon(
                Icons.person,
                color: AppLightColors.primary,
                size: 24.r,
              ),
              errorWidget: (context, url, error) => Icon(
                Icons.person,
                color: AppLightColors.primary,
                size: 24.r,
              ),
            )
          : Icon(
              Icons.person,
              color: AppLightColors.primary,
              size: 24.r,
            ),
    );
  }
}
