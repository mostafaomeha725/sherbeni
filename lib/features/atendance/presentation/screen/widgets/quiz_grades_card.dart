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
                color: const Color(
                  0xFF15803D,
                ), // Always Present (Green) in Quiz Grades
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
                              color: const Color(
                                0xFFDCFCE7,
                              ), // Always Light Green
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: AppText(
                              'Present', // Always Present
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF15803D), // Always Green
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
