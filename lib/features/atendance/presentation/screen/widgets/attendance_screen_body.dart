import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:qrattendance/core/routes/route_paths.dart';
import 'package:qrattendance/core/utils/easy_loading.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/show_sessions/show_sessions_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/attendance_header.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/session_card.dart';
import 'package:qrattendance/core/widgets/empty_state_widget.dart';

class AttendanceScreenBody extends StatefulWidget {
  final String token;

  const AttendanceScreenBody({super.key, required this.token});

  @override
  State<AttendanceScreenBody> createState() => _AttendanceScreenBodyState();
}

class _AttendanceScreenBodyState extends State<AttendanceScreenBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShowSessionsCubit>().fetchSessions(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShowSessionsCubit, ShowSessionsState>(
      listener: (context, state) {
        if (state is ShowSessionsLoading) {
          showLoading();
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
              const AttendanceHeader(),
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
                    child: ListView.separated(
                      itemCount: state.sessions.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16.h),
                      itemBuilder: (context, index) {
                        final session = state.sessions[index];
                        return SessionCard(
                          session: session,
                          onTap: () {
                            GoRouter.of(
                              context,
                            ).push(Routes.selectClassScreen, extra: session);
                          },
                        );
                      },
                    ),
                  )
              else if (state is ShowSessionsFailure)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Colors.redAccent,
                          size: 64.sp,
                        ),
                        SizedBox(height: 16.h),
                        AppText(
                          state.message,
                          alignment: AlignmentDirectional.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0xff333333),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        SizedBox(
                          width: double.infinity,
                          height: 48.h,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF47B20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            onPressed: () {
                              context.read<ShowSessionsCubit>().fetchSessions(
                                widget.token,
                              );
                            },
                            child: AppText(
                              'إعادة المحاولة',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              alignment: AlignmentDirectional.center,
                            ),
                          ),
                        ),
                      ],
                    ),
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
