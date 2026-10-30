import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/stored_data/stored_data_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/attendance/collapsible_attendance_card.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/sessions/session_group_card.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/stored_data/stored_data_dialogs.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/stored_data/stored_data_utils.dart';

class StoredDataAttendanceTab extends StatelessWidget {
  final List attendanceList;
  final String searchQuery;

  const StoredDataAttendanceTab({
    super.key,
    required this.attendanceList,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final filteredList = searchQuery.isEmpty
        ? attendanceList
        : attendanceList.where((item) {
            final session = StoredDataUtils.getValidSessionName(
              item.sessionName,
            ).toLowerCase();
            return session.contains(searchQuery);
          }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 60.sp,
              color: Colors.grey.withOpacity(0.5),
            ),
            SizedBox(height: 16.h),
            AppText(
              'لا توجد نتائج مطابقة',
              style: font16w500.copyWith(color: Colors.grey),
              alignment: AlignmentDirectional.center,
            ),
          ],
        ),
      );
    }
    // Group by session name
    final grouped = <String, List<dynamic>>{};
    for (var item in filteredList) {
      final session = StoredDataUtils.getValidSessionName(item.sessionName);
      if (!grouped.containsKey(session)) {
        grouped[session] = [];
      }
      grouped[session]!.add(item);
    }
    final sessionNames = grouped.keys.toList();

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: sessionNames.length,
      itemBuilder: (context, index) {
        final session = sessionNames[index];
        final items = grouped[session]!;

        return SessionGroupCard(
          sessionName: session,
          type: 'attendance',
          items: items,
          itemBuilder: (context, item) {
            return CollapsibleAttendanceCard(
              item: item,
              sessionName: StoredDataUtils.getValidSessionName(
                item.sessionName,
              ),
              statusBadge: StoredDataUtils.buildStatusBadge(item.syncStatus),
              onRetry:
                  item.syncStatus == 'failed' || item.syncStatus == 'pending'
                  ? () => context.read<StoredDataCubit>().retryAttendance(
                      item.pendingKey,
                    )
                  : null,
              onDelete: () => StoredDataDialogs.showDeleteBottomSheet(
                context,
                'حذف سجل الحضور',
                'هل أنت متأكد أنك تريد حذف هذا السجل؟',
                () => context.read<StoredDataCubit>().deleteAttendance(
                  item.pendingKey,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
