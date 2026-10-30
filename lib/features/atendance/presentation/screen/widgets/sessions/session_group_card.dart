import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/bouncing_widgets.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/stored_data/stored_data_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/stored_data_group_details_screen.dart';

class SessionGroupCard extends StatelessWidget {
  final String sessionName;
  final String type;
  final List<dynamic> items;
  final Widget Function(BuildContext, dynamic) itemBuilder;

  const SessionGroupCard({
    super.key,
    required this.sessionName,
    required this.type,
    required this.items,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status breakdown
    int successCount = 0;
    int failedCount = 0;
    int pendingCount = 0;

    for (var item in items) {
      if (item.syncStatus == 'success' || item.syncStatus == 'synced')
        successCount++;
      else if (item.syncStatus == 'failed')
        failedCount++;
      else
        pendingCount++;
    }

    final isAttendance = type == 'attendance';
    final mainIcon = isAttendance
        ? Icons.meeting_room_outlined
        : Icons.assignment_outlined;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: BounceIt(
        onPressed: () {
          // Navigate to session details screen with current bloc provided
          final cubit = context.read<StoredDataCubit>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: StoredDataGroupDetailsScreen(
                  sessionName: sessionName,
                  type: type,
                  items: items,
                  itemBuilder: itemBuilder,
                ),
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFF3F4F6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppLightColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    mainIcon,
                    color: AppLightColors.primary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 14.w),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        sessionName.isEmpty ? 'غير معروف' : sessionName,
                        style: font14w700.copyWith(
                          color: const Color(0xFF222222),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(
                            Icons.people_alt_outlined,
                            size: 14.sp,
                            color: const Color(0xFF777777),
                          ),
                          SizedBox(width: 4.w),
                          AppText(
                            '${items.length} ${isAttendance ? 'طالب' : 'سجل'}',
                            style: font12w700.copyWith(
                              color: const Color(0xFF555555),
                            ),
                          ),

                          if (successCount > 0) ...[
                            SizedBox(width: 10.w),
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 14.sp,
                              color: const Color(0xFF059669), // Green
                            ),
                            SizedBox(width: 2.w),
                            AppText(
                              '$successCount',
                              style: font12w700.copyWith(color: const Color(0xFF059669)),
                            ),
                          ],
                          if (failedCount > 0) ...[
                            SizedBox(width: 10.w),
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 14.sp,
                              color: Colors.red,
                            ),
                            SizedBox(width: 2.w),
                            AppText(
                              '$failedCount',
                              style: font12w700.copyWith(color: Colors.red),
                            ),
                          ],
                          if (pendingCount > 0) ...[
                            SizedBox(width: 10.w),
                            Icon(
                              Icons.pending_actions_rounded,
                              size: 14.sp,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 2.w),
                            AppText(
                              '$pendingCount',
                              style: font12w700.copyWith(color: Colors.orange),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: const Color(0xFFCCCCCC),
                  size: 16.sp,
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
