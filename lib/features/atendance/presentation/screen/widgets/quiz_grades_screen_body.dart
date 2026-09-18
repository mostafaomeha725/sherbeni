import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/utils/easy_loading.dart';
import 'package:qrattendance/core/widgets/empty_state_widget.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/quiz_grades/quiz_grades_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/quiz_grades/quiz_grades_state.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/quiz_grades_card.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/quiz_grades_filter_chip.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/quiz_grades_search_bar.dart';

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
    return BlocConsumer<QuizGradesCubit, QuizGradesState>(
      listener: (context, state) {
        if (state is QuizGradesLoaded && state.actionMessage != null) {
          if (state.isActionSuccess == true) {
            showSuccess(state.actionMessage!);
          } else {
            showError(state.actionMessage!);
          }
        }
      },
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
                        filter: 'all',
                        currentFilter: state.currentFilter,
                      ),
                      SizedBox(width: 8.w),
                      QuizGradesFilterChip(
                        title: 'Graded',
                        filter: 'graded',
                        currentFilter: state.currentFilter,
                      ),
                      SizedBox(width: 8.w),
                      QuizGradesFilterChip(
                        title: 'Not Graded',
                        filter: 'not_graded',
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
                Expanded(
                  child: EmptyStateWidget(
                    text: 'خطأ في جلب البيانات',
                    subtitle: state.message,
                    icon: Icons.wifi_off_rounded,
                  ),
                )
              else if (state is QuizGradesLoaded)
                Expanded(
                  child: state.students.isEmpty
                      ? const EmptyStateWidget(
                          text: 'No students found matching the search',
                          icon: Icons.person_off_outlined,
                        )
                      : ListView.separated(
                          padding: EdgeInsets.only(bottom: 24.h),
                          itemCount: state.students.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            final student = state.students[index];
                            final currentGrade = student.grade;

                            return QuizGradesCard(
                              student: student,
                              currentGrade: currentGrade,
                              quizMaxGrade: student.maxScore,
                              onGradeEntered: (grade) {
                                context.read<QuizGradesCubit>().updateGrade(
                                  student.studentId,
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
