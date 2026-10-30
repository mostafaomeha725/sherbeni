import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/session_students/session_students_cubit.dart';
import 'session_students_stat_chip.dart';

class SessionStudentsHeader extends StatelessWidget {
  final SessionEntity session;

  const SessionStudentsHeader({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionStudentsCubit, SessionStudentsState>(
      builder: (context, state) {
        String countDisplay = '-';
        bool canExport = false;

        if (state is SessionStudentsLoaded) {
          canExport = state.attendances.isNotEmpty;
          final count =
              state.pagination?.totalItems ?? state.attendances.length;
          countDisplay = '$count';
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: AppLightColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15.r,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Title and Excel Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AppText(
                      session.courseTitle.isNotEmpty
                          ? session.courseTitle
                          : 'Unnamed Session',
                      style: font18w700.copyWith(color: AppLightColors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // Premium Export Button
                  GestureDetector(
                    onTap: canExport
                        ? () => context
                              .read<SessionStudentsCubit>()
                              .exportToExcel(
                                session.courseTitle.isNotEmpty
                                    ? session.courseTitle
                                    : 'Session',
                                session.id.toString(),
                              )
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: canExport
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF10B981), // Emerald 500
                                  Color(0xFF059669), // Emerald 600
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.shade300,
                                  Colors.grey.shade400,
                                ],
                              ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: canExport
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withValues(alpha: 0.25),
                                  blurRadius: 12.r,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.download_rounded,
                            color: AppLightColors.white,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          AppText(
                            'Excel',
                            style: font14w700.copyWith(
                              color: AppLightColors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Bottom Row: Statistics Chips (using Wrap to prevent overflow)
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  // Total
                  SessionStudentsStatChip(
                    icon: Icons.people_alt_rounded,
                    color: AppLightColors.primary,
                    bgColor: AppLightColors.primaryLight,
                    text: "Total: $countDisplay",
                  ),
                  // On time
                  if (state is SessionStudentsLoaded)
                    SessionStudentsStatChip(
                      icon: Icons.check_circle_outline,
                      color: const Color(0xFF43A047),
                      bgColor: const Color(0xFFF2FFF5),
                      text:
                          "On Time: ${state.attendances.where((e) => !e.isLate).length}",
                    ),
                  // Late
                  if (state is SessionStudentsLoaded)
                    SessionStudentsStatChip(
                      icon: Icons.access_time_rounded,
                      color: const Color(0xFFE53935),
                      bgColor: const Color(0xFFFFF2F2),
                      text:
                          "Late: ${state.attendances.where((e) => e.isLate).length}",
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
