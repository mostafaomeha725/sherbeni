import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/utils/easy_loading.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/show_sessions/show_sessions_cubit.dart';
import 'package:qrattendance/core/widgets/empty_state_widget.dart';
import 'package:qrattendance/core/widgets/offline_empty_state_widget.dart';
import 'package:qrattendance/features/atendance/domain/entities/academic_class_entity.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/attendance_header.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/show_sessions_error_widget.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/show_sessions_list_widget.dart';

class AttendanceScreenBody extends StatefulWidget {
  final String token;
  final AcademicClassEntity academicClass;

  const AttendanceScreenBody({
    super.key,
    required this.token,
    required this.academicClass,
  });

  @override
  State<AttendanceScreenBody> createState() => _AttendanceScreenBodyState();
}

class _AttendanceScreenBodyState extends State<AttendanceScreenBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShowSessionsCubit>().fetchSessions(
        widget.token,
        widget.academicClass.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShowSessionsCubit, ShowSessionsState>(
      listener: (context, state) {
        if (state is ShowSessionsLoading) {
          showLoading();
        } else if (state is ShowSessionsOfflineFallback) {
          hideLoading();
        } else {
          hideLoading();
        }
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              const AttendanceHeader(
                title: 'Select Subject',
                subtitle: 'Select a subject for attendance.',
              ),
              SizedBox(height: 24.h),

              if (state is ShowSessionsSuccess)
                if (state.sessions.isEmpty)
                  const Expanded(
                    child: EmptyStateWidget(
                      text: 'لا يوجد مواد متاحة حالياً',
                      icon: Icons.menu_book_outlined,
                    ),
                  )
                else
                  Expanded(
                    child: ShowSessionsListWidget(
                      sessions: state.sessions,
                      classId: widget.academicClass.id,
                    ),
                  )
              else if (state is ShowSessionsFailure)
                Expanded(
                  child: ShowSessionsErrorWidget(
                    message: state.message,
                    onRetry: () {
                      context.read<ShowSessionsCubit>().fetchSessions(
                        widget.token,
                        widget.academicClass.id,
                      );
                    },
                  ),
                )
              else if (state is ShowSessionsOfflineFallback)
                Expanded(
                  child: OfflineEmptyStateWidget(
                    description:
                        'No subjects are available offline for this academic year. Please connect to the internet to load your subjects and try again.',
                    onRetry: () {
                      context.read<ShowSessionsCubit>().fetchSessions(
                        widget.token,
                        widget.academicClass.id,
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
