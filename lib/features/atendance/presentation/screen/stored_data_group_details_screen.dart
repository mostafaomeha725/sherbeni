import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/bouncing_widgets.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/stored_data/stored_data_group_details_screen_body.dart';

class StoredDataGroupDetailsScreen extends StatelessWidget {
  final String sessionName;
  final String type; // 'attendance' or 'quiz'
  final List<dynamic> items;
  final Widget Function(BuildContext, dynamic) itemBuilder;

  const StoredDataGroupDetailsScreen({
    super.key,
    required this.sessionName,
    required this.type,
    required this.items,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppLightColors.defaultBackground,
      appBar: AppBar(
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
        title: Column(
          children: [
            AppText(
              type == 'attendance' ? 'حضور السيشن' : 'درجات الكويز',
              style: font16w700.copyWith(color: const Color(0xFF222222)),
            ),
            AppText(
              sessionName,
              style: font12w500.copyWith(color: const Color(0xFF777777)),
            ),
          ],
        ),
      ),
      body: StoredDataGroupDetailsScreenBody(
        sessionName: sessionName,
        type: type,
        items: items,
        itemBuilder: itemBuilder,
      ),
    );
  }
}
