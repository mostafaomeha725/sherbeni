import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/features/atendance/data/model/attendance_history_model.dart';
import 'collapsible_attendance_card_details.dart';
import 'collapsible_attendance_card_title.dart';

class CollapsibleAttendanceCard extends StatelessWidget {
  final AttendanceHistoryModel item;
  final String sessionName;
  final Widget statusBadge;
  final VoidCallback? onRetry;
  final VoidCallback onDelete;

  const CollapsibleAttendanceCard({
    super.key,
    required this.item,
    required this.sessionName,
    required this.statusBadge,
    this.onRetry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          title: CollapsibleAttendanceCardTitle(
            uid: item.uid,
            statusBadge: statusBadge,
          ),
          children: [
            CollapsibleAttendanceCardDetails(
              item: item,
              sessionName: sessionName,
              onRetry: onRetry,
              onDelete: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
