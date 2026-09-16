import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/widgets/bouncing_widgets.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/select_class_date_section.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/select_class_info_section.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/select_class_actions.dart';
import 'package:intl/intl.dart';

class SelectClassCard extends StatelessWidget {
  final SessionEntity session;
  final VoidCallback onTap;

  const SelectClassCard({
    super.key,
    required this.session,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic data from session
    final String centerName = session.title.isNotEmpty
        ? session.title
        : "المركز الرئيسي";
    final String sessionName = session.courseTitle.isNotEmpty
        ? session.courseTitle
        : 'اسم الحصة';

    String sessionDate = session.startTime;
    String dayName = "-";
    String dayNumber = "-";
    String monthName = "-";

    try {
      if (session.startTime.isNotEmpty) {
        final date = DateTime.parse(session.startTime).toLocal();
        dayName = DateFormat('E').format(date); // e.g., Mon
        dayNumber = DateFormat('d').format(date); // e.g., 24
        monthName = DateFormat('MMM').format(date); // e.g., Aug

        String formattedStart = DateFormat(
          'hh:mm a',
        ).format(date); // e.g., 08:30 PM

        // If there's an end time, format it too
        if (session.endTime.isNotEmpty) {
          try {
            final endDate = DateTime.parse(session.endTime).toLocal();
            String formattedEnd = DateFormat('hh:mm a').format(endDate);
            sessionDate = "$formattedStart - $formattedEnd";
          } catch (_) {
            sessionDate = formattedStart;
          }
        } else {
          sessionDate = formattedStart;
        }
      }
    } catch (e) {
      // fallback if parsing fails
    }

    return BounceIt(
      onPressed: onTap,
      child: Container(
        padding: EdgeInsets.only(
          right: 16.w,
          top: 18.h,
          bottom: 18.h,
          left: 12.w,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SelectClassDateSection(
              dayName: dayName,
              dayNumber: dayNumber,
              monthName: monthName,
            ),
            SizedBox(width: 16.w),
            SelectClassInfoSection(
              centerName: centerName,
              sessionName: sessionName,
              sessionDate: sessionDate,
            ),
            SizedBox(width: 8.w),
            SelectClassActions(session: session),
          ],
        ),
      ),
    );
  }
}
