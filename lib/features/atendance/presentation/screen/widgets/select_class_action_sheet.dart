import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:qrattendance/core/routes/route_paths.dart';
import 'package:qrattendance/core/widgets/bouncing_widgets.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';

class SelectClassActionSheet extends StatelessWidget {
  final SessionEntity session;
  final List<dynamic> quizzes;

  const SelectClassActionSheet({
    super.key,
    required this.session,
    required this.quizzes,
  });

  static void show(
    BuildContext context,
    SessionEntity session,
    List<dynamic> quizzes,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SelectClassActionSheet(session: session, quizzes: quizzes);
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
                _buildActionCard(
                  context: context,
                  title: 'Scan Attendance',
                  subtitle: 'Scan student QR codes',
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
                ...quizzes.map((quiz) {
                  final quizName = quiz['name'] ?? 'Quiz';
                  final quizTemplateId =
                      quiz['quiz_template_id']?.toString() ?? '';
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: _buildActionCard(
                      context: context,
                      title: 'Quiz: $quizName',
                      subtitle: 'Enter or update student grades',
                      icon: Icons.grading_rounded,
                      iconColor: const Color(
                        0xFF10B981,
                      ), // Green theme for grades
                      bgColor: const Color(0xFFECFDF5),
                      onTap: () {
                        GoRouter.of(context).pop();
                        GoRouter.of(context).push(
                          Routes.quizGradesScreen,
                          extra: {
                            'session': session,
                            'quizTemplateId': quizTemplateId,
                          },
                        );
                      },
                    ),
                  );
                }),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return BounceIt(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF8FAFC),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: iconColor, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    AppText(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFFCBD5E1),
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
