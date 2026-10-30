import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:qrattendance/features/atendance/data/model/attendance_history_model.dart';
import 'collapsible_attendance_card_actions.dart';
import 'collapsible_attendance_error_banner.dart';
import 'collapsible_attendance_info_row.dart';

class CollapsibleAttendanceCardDetails extends StatelessWidget {
  final AttendanceHistoryModel item;
  final String sessionName;
  final VoidCallback? onRetry;
  final VoidCallback onDelete;

  const CollapsibleAttendanceCardDetails({
    super.key,
    required this.item,
    required this.sessionName,
    this.onRetry,
    required this.onDelete,
  });

  static String formatDate(dynamic dateString) {
    try {
      final dt = DateTime.parse(dateString.toString());
      return DateFormat('dd/MM/yyyy hh:mm a').format(dt);
    } catch (e) {
      return dateString.toString().split(".")[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final parts = sessionName.split(' - ');
    final centerName = parts.length > 1 ? parts.last : sessionName;
    final subjectName = parts.length > 1 ? parts.first : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Color(0xFFEEEEEE), height: 1),
        SizedBox(height: 12.h),
        CollapsibleAttendanceInfoRow(
          icon: Icons.business_outlined,
          text: 'السنتر: $centerName',
        ),
        if (subjectName.isNotEmpty)
          CollapsibleAttendanceInfoRow(
            icon: Icons.meeting_room_outlined,
            text: 'السيشن: $subjectName',
          ),
        if (item.phone != null && item.phone!.isNotEmpty)
          CollapsibleAttendanceInfoRow(
            icon: Icons.phone_outlined,
            text: item.phone!,
          ),
        if (item.educationalLevel != null &&
            item.educationalLevel!.isNotEmpty)
          CollapsibleAttendanceInfoRow(
            icon: Icons.school_outlined,
            text: item.educationalLevel!,
          ),
        CollapsibleAttendanceInfoRow(
          icon: Icons.access_time_outlined,
          text: formatDate(item.scanTime),
        ),
        if (item.error != null && item.syncStatus == 'failed') ...[
          SizedBox(height: 12.h),
          CollapsibleAttendanceErrorBanner(error: item.error!),
        ],
        SizedBox(height: 16.h),
        CollapsibleAttendanceCardActions(
          onRetry: onRetry,
          onDelete: onDelete,
        ),
      ],
    );
  }
}
