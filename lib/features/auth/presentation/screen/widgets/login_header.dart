import 'package:flutter/material.dart';
import 'package:qrattendance/core/constants/app_assets.dart';
import 'package:qrattendance/core/widgets/app_asset.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 70.h),
          AppAsset(assetName: Assets.logo, height: 160.h),
        ],
      ),
    );
  }
}
