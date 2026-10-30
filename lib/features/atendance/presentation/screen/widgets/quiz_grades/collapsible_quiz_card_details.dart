import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intl/intl.dart' show DateFormat;

import 'package:qrattendance/core/theme/styles.dart';

import 'package:qrattendance/core/widgets/custom_text.dart';

import 'package:qrattendance/features/atendance/data/model/quiz_grade_history_model.dart';

class CollapsibleQuizCardDetails extends StatelessWidget {
  final QuizGradeHistoryModel item;
  final String sessionName;
  final String quizName;

  const CollapsibleQuizCardDetails({
    super.key,
    required this.item,
    required this.sessionName,
    required this.quizName,
  });

  String _formatDate(dynamic dateString) {
    try {
      final dt = DateTime.parse(dateString.toString());
      return DateFormat('dd/MM/yyyy hh:mm a').format(dt);
    } catch (e) {
      return dateString.toString().split(".")[0];
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Icon(icon, size: 16.sp, color: const Color(0xFF777777)),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: AppText(
                text,
                style: font14w500.copyWith(color: const Color(0xFF555555)),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parts = sessionName.split(' - ');
    final centerName = parts.length > 1 ? parts.last : sessionName;
    final subjectName = parts.length > 1 ? parts.first : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(Icons.business_outlined, 'السنتر: $centerName'),
        if (subjectName.isNotEmpty)
          _buildInfoRow(Icons.meeting_room_outlined, 'السيشن: $subjectName'),
        _buildInfoRow(Icons.assignment_outlined, 'كويز: $quizName'),
        _buildInfoRow(
          Icons.score_outlined,
          'الدرجة: ${item.grade} / ${item.maxScore ?? "-"}',
        ),
        _buildInfoRow(Icons.access_time_outlined, _formatDate(item.createdAt)),
        if (item.error != null && item.syncStatus == 'failed') ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: const Color(0xFFEF4444),
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: AppText(
                      item.error!,
                      style: font12w500.copyWith(
                        color: const Color(0xFFB91C1C),
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
