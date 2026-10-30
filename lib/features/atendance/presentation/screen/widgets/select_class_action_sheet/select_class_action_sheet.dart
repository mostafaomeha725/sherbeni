import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:qrattendance/core/routes/route_paths.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';

import 'select_class_action_card.dart';

class SelectClassActionSheet extends StatelessWidget {
  final SessionEntity session;
  const SelectClassActionSheet({super.key, required this.session});

  static void show(BuildContext context, SessionEntity session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SelectClassActionSheet(session: session);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          // Drag Indicator
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 24.h),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED), // Soft orange
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.dashboard_customize_rounded,
                    color: const Color(0xFFF47B20),
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Select Action',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      AppText(
                        'Choose an action for this class',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Divider
          Divider(height: 1, thickness: 1, color: const Color(0xFFF1F5F9)),

          // Actions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
              children: [
                SelectClassActionCard(
                  context: context,
                  title: 'Scan Attendance',
                  subtitle: session.hasQuiz || session.hasHomework
                      ? 'Scan student QR codes'
                      : 'Scan student QR codes',
                  icon: Icons.qr_code_scanner_rounded,
                  iconColor: const Color(0xFF3B82F6), // Blue theme for scanning
                  bgColor: const Color(0xFFEFF6FF),
                  onTap: () {
                    GoRouter.of(context).pop();
                    GoRouter.of(
                      context,
                    ).push(Routes.scanQrScreen, extra: session);
                  },
                ),
                SizedBox(height: 16.h),
                if (session.hasQuiz)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: SelectClassActionCard(
                      context: context,
                      title: session.quizName ?? 'Quiz',
                      subtitle: 'Enter or update student grades',
                      icon: Icons.grading_rounded,
                      iconColor: const Color(0xFF10B981),
                      bgColor: const Color(0xFFECFDF5),
                      onTap: () {
                        GoRouter.of(context).pop();
                        GoRouter.of(
                          context,
                        ).push(Routes.quizGradesScreen, extra: session);
                      },
                    ),
                  ),
                if (session.hasHomework)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: SelectClassActionCard(
                      context: context,
                      title: session.homeworkName ?? 'Home Work',
                      subtitle: 'Enter or update Homework grades',
                      icon: Icons.menu_book_rounded,
                      iconColor: const Color(
                        0xFFF43F5E,
                      ), // Rose theme for homework
                      bgColor: const Color(0xFFFFF1F2),
                      onTap: () {
                        GoRouter.of(context).pop();
                        GoRouter.of(
                          context,
                        ).push(Routes.homeworkGradesScreen, extra: session);
                      },
                    ),
                  ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
