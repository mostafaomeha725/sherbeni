import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:qrattendance/core/routes/route_paths.dart';
import 'package:qrattendance/core/utils/easy_loading.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/academic_classes/academic_classes_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/attendance_header.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/academic_class_card.dart';
import 'package:qrattendance/core/widgets/empty_state_widget.dart';

class AcademicClassesScreenBody extends StatefulWidget {
  final String token;

  const AcademicClassesScreenBody({super.key, required this.token});

  @override
  State<AcademicClassesScreenBody> createState() =>
      _AcademicClassesScreenBodyState();
}

class _AcademicClassesScreenBodyState extends State<AcademicClassesScreenBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicClassesCubit>().fetchAcademicClasses(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AcademicClassesCubit, AcademicClassesState>(
      listener: (context, state) {
        if (state is AcademicClassesLoading) {
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
              const AttendanceHeader(
                title: 'Select Academic Year',
                subtitle: 'Choose a year to continue.',
              ),
              SizedBox(height: 24.h),
              if (state is AcademicClassesSuccess)
                if (state.classes.isEmpty)
                  const Expanded(
                    child: EmptyStateWidget(
                      text: 'No academic years available.',
                      icon: Icons.class_outlined,
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.only(bottom: 24.h),
                      itemCount: state.classes.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16.h),
                      itemBuilder: (context, index) {
                        final academicClass = state.classes[index];
                        return AcademicClassCard(
                          academicClass: academicClass,
                          onTap: () {
                            GoRouter.of(context).push(
                              Routes.attendanceScreen,
                              extra: {
                                'token': widget.token,
                                'academicClass': academicClass,
                              },
                            );
                          },
                        );
                      },
                    ),
                  )
              else if (state is AcademicClassesFailure ||
                  state is AcademicClassesOfflineFallback)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          state is AcademicClassesOfflineFallback
                              ? Icons.wifi_off_rounded
                              : Icons.error_outline_rounded,
                          color: Colors.redAccent,
                          size: 64.sp,
                        ),
                        SizedBox(height: 16.h),
                        AppText(
                          state is AcademicClassesOfflineFallback
                              ? 'No internet connection and no academic years are available offline.'
                              : (state as AcademicClassesFailure).message,
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
                              context
                                  .read<AcademicClassesCubit>()
                                  .fetchAcademicClasses(widget.token);
                            },
                            child: AppText(
                              'Retry',
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
