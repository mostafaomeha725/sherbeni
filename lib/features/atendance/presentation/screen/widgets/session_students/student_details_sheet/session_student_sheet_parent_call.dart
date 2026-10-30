import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/utils/url_launcher_util.dart';
import 'package:qrattendance/core/widgets/custom_button.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_attendance_entity.dart';

class SessionStudentSheetParentCall extends StatelessWidget {
  final SessionAttendanceEntity student;

  const SessionStudentSheetParentCall({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final parentPhone = student.parentPhoneNumber?.trim();
    final hasParentPhone = parentPhone != null && parentPhone.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: hasParentPhone
            ? const Color(0xFFF0FDF4)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: hasParentPhone
              ? const Color(0xFF86EFAC)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: hasParentPhone
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.contact_phone_rounded,
                  size: 20.sp,
                  color: hasParentPhone
                      ? const Color(0xFF15803D)
                      : const Color(0xFF64748B),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "ولي الأمر (Parent)",
                      style: font12w500.copyWith(color: const Color(0xFF64748B)),
                    ),
                    SizedBox(height: 2.h),
                    AppText(
                      hasParentPhone ? parentPhone : "غير متوفر",
                      style: font16w700.copyWith(
                        color: hasParentPhone
                            ? const Color(0xFF15803D)
                            : const Color(0xFF94A3B8),
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasParentPhone) ...[
            SizedBox(height: 14.h),
            AppButton.icon(
              text: "اتصال بولي الأمر ($parentPhone)",
              color: const Color(0xFF16A34A),
              textColor: Colors.white,
              radius: 12.r,
              onPressed: () => UrlLauncherUtil.launchPhone(parentPhone),
              child: Icon(Icons.call, color: Colors.white, size: 18.sp),
            ),
          ],
        ],
      ),
    );
  }
}
