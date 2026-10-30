import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/bouncing_widgets.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/core/theme/light_colors.dart';

class StoredDataAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StoredDataAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 40.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0.0,
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: EdgeInsets.only(left: 16.w, top: 8.h, bottom: 8.h),
        child: BounceIt(
          onPressed: () => Navigator.of(context).pop(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF0F0F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back,
              size: 20.sp,
              color: const Color(0xFF222222),
            ),
          ),
        ),
      ),
      title: AppText(
        'السجلات المخزنة',
        style: font18w700.copyWith(color: const Color(0xFF222222)),
      ),
      bottom: TabBar(
        indicatorColor: AppLightColors.primary,
        labelColor: AppLightColors.primary,
        unselectedLabelColor: const Color(0xFF888888),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'الحضور'),
          Tab(text: 'درجات الكويز'),
        ],
        labelStyle: font14w700.copyWith(fontFamily: 'Cairo'),
        unselectedLabelStyle: font14w500.copyWith(fontFamily: 'Cairo'),
      ),
    );
  }
}
