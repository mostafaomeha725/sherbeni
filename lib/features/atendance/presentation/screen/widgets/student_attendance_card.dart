import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:qrattendance/core/constants/strings.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_attendance_entity.dart';

class StudentAttendanceCard extends StatelessWidget {
  final SessionAttendanceEntity student;

  const StudentAttendanceCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppLightColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.04),
            blurRadius: 20.r,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: student.isLate
                    ? const Color(0xFFE53935)
                    : const Color(0xFF43A047),
                width: 4.w,
              ),
              top: BorderSide(color: Colors.grey.shade200),
              bottom: BorderSide(color: Colors.grey.shade200),
              right: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  height: 48.r,
                  width: 48.r,
                  decoration: const BoxDecoration(
                    color: AppLightColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: student.picture != null && student.picture!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: student.picture!.startsWith('http')
                              ? student.picture!
                              : '${AppStrings.baseUrl}${student.picture}',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Icon(
                            Icons.person,
                            color: AppLightColors.primary,
                            size: 24.r,
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            color: AppLightColors.primary,
                            size: 24.r,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: AppLightColors.primary,
                          size: 24.r,
                        ),
                ),
                SizedBox(width: 16.w),

                // Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Name and Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppText(
                              student.name,
                              style: font16w700.copyWith(
                                color: const Color(0xFF1E293B),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Status Badge with Icon
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: student.isLate
                                  ? const Color(0xFFFEF2F2)
                                  : const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(24.r),
                              border: Border.all(
                                color: student.isLate
                                    ? const Color(0xFFFECACA)
                                    : const Color(0xFFBBF7D0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  student.isLate
                                      ? Icons.timer_off_outlined
                                      : Icons.check_circle_outline_rounded,
                                  size: 14.sp,
                                  color: student.isLate
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF16A34A),
                                ),
                                SizedBox(width: 4.w),
                                AppText(
                                  student.isLate ? 'Late' : 'On Time',
                                  style: font12w700.copyWith(
                                    color: student.isLate
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Details
                      if (student.phoneNumber != null &&
                          student.phoneNumber!.isNotEmpty) ...[
                        _buildDetailRow(
                          icon: Icons.phone_android_rounded,
                          text: student.phoneNumber!,
                        ),
                        SizedBox(height: 8.h),
                      ],
                      _buildDetailRow(
                        icon: Icons.qr_code_scanner_rounded,
                        text: 'Scan: ${student.date} • ${student.time}',
                      ),
                      if (student.sessionTime != null) ...[
                        SizedBox(height: 8.h),
                        _buildDetailRow(
                          icon: Icons.event_note_rounded,
                          text:
                              'Session: ${student.sessionDate ?? ""} • ${student.sessionTime}',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Icon(icon, size: 14.sp, color: const Color(0xFF64748B)),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: AppText(
            text,
            style: font12w500.copyWith(color: const Color(0xFF475569)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
