import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:qrattendance/core/utils/easy_loading.dart';
import 'package:qrattendance/core/widgets/custom_button.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/show_classes/show_classes_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/select_class_card.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/select_class_header.dart';
import 'package:qrattendance/core/widgets/empty_state_widget.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/select_class_action_sheet.dart';

class SelectClassScreenBody extends StatefulWidget {
  final String subjectId;
  const SelectClassScreenBody({super.key, required this.subjectId});

  @override
  State<SelectClassScreenBody> createState() => _SelectClassScreenBodyState();
}

class _SelectClassScreenBodyState extends State<SelectClassScreenBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShowClassesCubit>().fetchClasses(widget.subjectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShowClassesCubit, ShowClassesState>(
      listener: (context, state) {
        if (state is ShowClassesLoading) {
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
              const SelectClassHeader(),
              SizedBox(height: 24.h),

              if (state is ShowClassesSuccess)
                if (state.classes.isEmpty)
                  const Expanded(
                    child: EmptyStateWidget(
                      text: 'لا يوجد حصص متاحة حالياً',
                      icon: Icons.meeting_room_outlined,
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.classes.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16.h),
                      itemBuilder: (context, index) {
                        final session = state.classes[index];
                        return SelectClassCard(
                          session: session,
                          onTap: () {
                            SelectClassActionSheet.show(context, session);
                          },
                        );
                      },
                    ),
                  )
              else if (state is ShowClassesFailure)
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
                          child: AppButton(
                            text: 'إعادة المحاولة',
                            onPressed: () {
                              context.read<ShowClassesCubit>().fetchClasses(
                                widget.subjectId,
                              );
                            },
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
