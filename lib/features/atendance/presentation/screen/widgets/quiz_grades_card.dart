import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/widgets/bouncing_widgets.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/domain/entities/quiz_student_entity.dart';
import 'package:qrattendance/core/theme/light_colors.dart';

import 'quiz_grades_card_avatar.dart';
import 'quiz_grades_card_details.dart';
import 'quiz_grades_card_badge.dart';

class QuizGradesCard extends StatelessWidget {
  final QuizStudentEntity student;
  final num? currentGrade;
  final num? quizMaxGrade;
  final void Function(num) onGradeEntered;

  const QuizGradesCard({
    super.key,
    required this.student,
    this.currentGrade,
    this.quizMaxGrade,
    required this.onGradeEntered,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGraded = currentGrade != null;

    return BounceIt(
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isGraded
                ? const Color(0xFF16A34A).withOpacity(0.3)
                : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  (isGraded ? const Color(0xFF16A34A) : AppLightColors.primary)
                      .withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Status Indicator Line
              Container(
                width: 5.w,
                color: student.offlineStatus == 'unknown'
                    ? AppLightColors.primary
                    : student.offlineStatus == 'present'
                    ? const Color(0xFF15803D) // Present (Green)
                    : const Color(0xFFB91C1C), // Absent (Red)
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Row(
                    children: [
                      QuizGradesCardAvatar(
                        studentName: student.name,
                        isGraded: isGraded,
                        pictureUrl: student.picture,
                      ),
                      SizedBox(width: 16.w),
                      Expanded(child: QuizGradesCardDetails(student: student)),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: student.offlineStatus == 'unknown'
                                  ? const Color(0xFFF1F5F9) // Light Gray
                                  : student.offlineStatus == 'present'
                                  ? const Color(0xFFDCFCE7) // Light Green
                                  : const Color(0xFFFEE2E2), // Light Red
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: AppText(
                              student.offlineStatus == 'unknown'
                                  ? 'غير متوفر'
                                  : student.offlineStatus == 'present'
                                  ? 'حاضر'
                                  : 'غائب',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: student.offlineStatus == 'unknown'
                                    ? const Color(0xFF64748B) // Slate 500
                                    : student.offlineStatus == 'present'
                                    ? const Color(0xFF15803D)
                                    : const Color(0xFFB91C1C),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          QuizGradesCardBadge(
                            currentGrade: currentGrade,
                            quizMaxGrade: quizMaxGrade,
                            onGradeEntered: onGradeEntered,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
