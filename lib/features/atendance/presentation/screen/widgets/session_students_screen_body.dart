import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/session_students/session_students_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/session_students_header.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/session_students_states_widgets.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/student_attendance_card.dart';

class SessionStudentsScreenBody extends StatefulWidget {
  final SessionEntity session;

  const SessionStudentsScreenBody({super.key, required this.session});

  @override
  State<SessionStudentsScreenBody> createState() =>
      _SessionStudentsScreenBodyState();
}

class _SessionStudentsScreenBodyState extends State<SessionStudentsScreenBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.7) {
      context.read<SessionStudentsCubit>().fetchNextPage(
        widget.session.id.toString(),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Info & Export Button
        SessionStudentsHeader(session: widget.session),

        // Main List
        Expanded(
          child: BlocBuilder<SessionStudentsCubit, SessionStudentsState>(
            builder: (context, state) {
              if (state is SessionStudentsLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppLightColors.primary,
                  ),
                );
              } else if (state is SessionStudentsFailure) {
                return SessionStudentsErrorWidget(
                  message: state.message,
                  onRetry: () =>
                      context.read<SessionStudentsCubit>().fetchStudents(
                        widget.session.id.toString(),
                        isRefresh: true,
                      ),
                );
              } else if (state is SessionStudentsLoaded) {
                if (state.isOffline) {
                  return SessionStudentsOfflineCard(
                    count: state.attendances.length,
                  );
                }

                if (state.attendances.isEmpty) {
                  return const SessionStudentsEmptyCard();
                }

                return RefreshIndicator(
                  color: AppLightColors.primary,
                  onRefresh: () =>
                      context.read<SessionStudentsCubit>().fetchStudents(
                        widget.session.id.toString(),
                        isRefresh: true,
                      ),
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      bottom: 24.h,
                      left: 16.w,
                      right: 16.w,
                      top: 16.h,
                    ),
                    itemCount:
                        state.attendances.length +
                        (state.isFetchingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.attendances.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              color: AppLightColors.primary,
                            ),
                          ),
                        );
                      }

                      final student = state.attendances[index];
                      return StudentAttendanceCard(student: student);
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
