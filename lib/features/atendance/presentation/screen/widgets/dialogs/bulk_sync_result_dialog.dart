import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/bouncing_widgets.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/stored_data/stored_data_state.dart';

void showBulkSyncResultDialog(
  BuildContext context,
  StoredDataBulkSyncResult state,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.sync_rounded,
              color: AppLightColors.primary,
              size: 28.sp,
            ),
            SizedBox(width: 8.w),
            AppText(
              'نتيجة المزامنة',
              style: font16w700.copyWith(color: const Color(0xFF222222)),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 32.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      AppText(
                        'ناجح',
                        style: font14w500.copyWith(color: Colors.green),
                      ),
                      AppText(
                        '${state.validCount}',
                        style: font20w700.copyWith(color: Colors.green),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 32.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      AppText(
                        'فشل',
                        style: font14w500.copyWith(color: Colors.red),
                      ),
                      AppText(
                        '${state.invalidCount}',
                        style: font20w700.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
              if (state.invalidRecords.isNotEmpty) ...[
                SizedBox(height: 16.h),
                const Divider(color: Color(0xFFEEEEEE), height: 1),
                SizedBox(height: 16.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppText(
                    'تفاصيل السجلات الفاشلة:',
                    style: font14w700.copyWith(
                      color: const Color(0xFF222222),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.invalidRecords.length,
                    itemBuilder: (context, index) {
                      final record = state.invalidRecords[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              record['name'],
                              style: font12w700.copyWith(
                                color: const Color(0xFF222222),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            AppText(
                              record['reason'],
                              style: font11w500.copyWith(color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          BounceIt(
            onPressed: () => Navigator.of(context).pop(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppLightColors.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: AppText(
                'إغلاق',
                style: font14w700.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      );
    },
  );
}
