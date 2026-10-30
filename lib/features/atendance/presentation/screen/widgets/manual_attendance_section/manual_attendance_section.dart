import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/manual_attendance/manual_attendance_cubit.dart';

import 'package:qrattendance/features/atendance/presentation/screen/widgets/manual_attendance_section/manual_attendance_section_logic_mixin.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/manual_attendance_section/manual_attendance_section_header.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/manual_attendance_section/manual_attendance_section_search_bar.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/manual_attendance_section/manual_attendance_section_body_content.dart';

class ManualAttendanceSection extends StatefulWidget {
  final SessionEntity session;
  final bool hasInternet;

  const ManualAttendanceSection({
    super.key,
    required this.session,
    required this.hasInternet,
  });

  @override
  State<ManualAttendanceSection> createState() =>
      _ManualAttendanceSectionState();
}

class _ManualAttendanceSectionState extends State<ManualAttendanceSection>
    with SingleTickerProviderStateMixin, ManualAttendanceSectionLogicMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ManualAttendanceSectionHeader(hasInternet: widget.hasInternet),
              ManualAttendanceSectionSearchBar(
                searchController: searchController,
                focusNode: focusNode,
                onSearch: onSearch,
                onClear: onClear,
              ),
              BlocConsumer<ManualAttendanceCubit, ManualAttendanceState>(
                listenWhen: (prev, curr) =>
                    curr is ManualAttendanceSuccess ||
                    curr is ManualAttendanceBulkSuccess ||
                    curr is ManualAttendanceError,
                listener: (context, state) {
                  if (state is ManualAttendanceSuccess) {
                    showResultSnackbar(
                      context,
                      'Attendance recorded successfully.',
                      isSuccess: true,
                    );
                  } else if (state is ManualAttendanceBulkSuccess) {
                    showResultSnackbar(
                      context,
                      'تم حفظ الحضور لـ ${state.count} طالب بنجاح في وضع عدم الاتصال',
                      isSuccess: true,
                    );
                    onClear();
                  } else if (state is ManualAttendanceError) {
                    showResultSnackbar(
                      context,
                      state.message,
                      isSuccess: false,
                    );
                  }
                },
                builder: (context, state) {
                  return ManualAttendanceSectionBodyContent(
                    state: state,
                    onSearch: onSearch,
                    onSubmitAttendance: submitAttendance,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
