import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/core/widgets/empty_state_widget.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/quiz_grades/quiz_grades_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/quiz_grades/quiz_grades_state.dart';

import 'quiz_grades_search_bar.dart';
import 'quiz_grades_card.dart';
import 'quiz_grades_filter_chip.dart';

class QuizGradesScreenBody extends StatefulWidget {
  final SessionEntity session;
  const QuizGradesScreenBody({super.key, required this.session});

  @override
  State<QuizGradesScreenBody> createState() => _QuizGradesScreenBodyState();
}

class _QuizGradesScreenBodyState extends State<QuizGradesScreenBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizGradesCubit, QuizGradesState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 16.h),

              // Search bar always visible (Senior UX)
              QuizGradesSearchBar(controller: _searchController),
              SizedBox(height: 12.h),

              // Filters Row
              if (state is QuizGradesLoaded)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      QuizGradesFilterChip(
                        title: 'All',
                        filter: QuizGradeFilter.all,
                        currentFilter: state.currentFilter,
                      ),
                      SizedBox(width: 8.w),
                      QuizGradesFilterChip(
                        title: 'Graded',
                        filter: QuizGradeFilter.graded,
                        currentFilter: state.currentFilter,
                      ),
                      SizedBox(width: 8.w),
                      QuizGradesFilterChip(
                        title: 'Not Graded',
                        filter: QuizGradeFilter.notGraded,
                        currentFilter: state.currentFilter,
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 16.h),

              if (state is QuizGradesLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFF47B20)),
                  ),
                )
              else if (state is QuizGradesError)
                Expanded(child: Center(child: AppText(state.message)))
              else if (state is QuizGradesLoaded)
                Expanded(
                  child: state.filteredStudents.isEmpty
                      ? const EmptyStateWidget(
                          text: 'No students found matching the search',
                          icon: Icons.person_off_outlined,
                        )
                      : ListView.separated(
                          padding: EdgeInsets.only(bottom: 24.h),
                          itemCount: state.filteredStudents.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            final student = state.filteredStudents[index];
                            final currentGrade = state.quizGrades[student.id];

                            return QuizGradesCard(
                              student: student,
                              currentGrade: currentGrade,
                              quizMaxGrade:
                                  widget.session.effectiveQuizMaxGrade,
                              onGradeEntered: (grade) {
                                context.read<QuizGradesCubit>().updateGrade(
                                  student.id,
                                  grade,
                                );
                              },
                            );
                          },
                        ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }
}
