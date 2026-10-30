import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/utils/easy_loading.dart';
import 'package:qrattendance/core/widgets/empty_state_widget.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/homework_grades/homework_grades_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/homework_grades/homework_grades_state.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/homework_grades/homework_grades_card.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/homework_grades/homework_grades_filter_chip.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/homework_grades/homework_grades_search_bar.dart';

class HomeworkGradesScreenBody extends StatefulWidget {
  final SessionEntity session;

  const HomeworkGradesScreenBody({super.key, required this.session});

  @override
  State<HomeworkGradesScreenBody> createState() => _HomeworkGradesScreenBodyState();
}

class _HomeworkGradesScreenBodyState extends State<HomeworkGradesScreenBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeworkGradesCubit, HomeworkGradesState>(
      listener: (context, state) {
        if (state is HomeworkGradesLoaded && state.actionMessage != null) {
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
              HomeworkGradesSearchBar(controller: _searchController),
              SizedBox(height: 12.h),

              // Filters Row
              if (state is HomeworkGradesLoaded)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      HomeworkGradesFilterChip(
                        title: 'All',
                        filter: 'all',
                        currentFilter: state.currentFilter,
                      ),
                      SizedBox(width: 8.w),
                      HomeworkGradesFilterChip(
                        title: 'Graded',
                        filter: 'graded',
                        currentFilter: state.currentFilter,
                      ),
                      SizedBox(width: 8.w),
                      HomeworkGradesFilterChip(
                        title: 'Not Graded',
                        filter: 'not_graded',
                        currentFilter: state.currentFilter,
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 16.h),

              if (state is HomeworkGradesLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFF47B20)),
                  ),
                )
              else if (state is HomeworkGradesError)
                Expanded(
                  child: EmptyStateWidget(
                    text: 'خطأ في جلب البيانات',
                    subtitle: state.message,
                    icon: Icons.wifi_off_rounded,
                  ),
                )
              else if (state is HomeworkGradesLoaded)
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

                            return HomeworkGradesCard(
                              student: student,
                              currentGrade: currentGrade,
                              homeworkMaxGrade: student.maxScore ?? state.maxScore,
                              onGradeEntered: (grade) {
                                context.read<HomeworkGradesCubit>().updateGrade(
                                  student.studentId,
                                  grade,
                                  sessionName:
                                      "${widget.session.courseTitle} - ${widget.session.title}",
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
