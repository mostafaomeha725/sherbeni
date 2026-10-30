import 'package:flutter/material.dart';
import 'package:qrattendance/features/atendance/domain/entities/manual_search_student_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/manual_attendance/manual_attendance_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/manual_attendance_section/manual_attendance_section_states.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/manual_attendance_section/manual_attendance_section_student_card.dart';

class ManualAttendanceSectionBodyContent extends StatelessWidget {
  final ManualAttendanceState state;
  final Function(ManualSearchStudentEntity) onSubmitAttendance;
  final VoidCallback onSearch;

  const ManualAttendanceSectionBodyContent({
    super.key,
    required this.state,
    required this.onSubmitAttendance,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    if (state is ManualAttendanceIdle) {
      return const ManualAttendanceSectionIdlePlaceholder();
    }
    if (state is ManualAttendanceSearching) {
      return const ManualAttendanceSectionLoadingState();
    }
    if (state is ManualAttendanceSearchError) {
      final currentState = state as ManualAttendanceSearchError;
      return ManualAttendanceSectionErrorState(
        message: currentState.message,
        onRetry: onSearch,
      );
    }
    if (state is ManualAttendanceEmpty) {
      return const ManualAttendanceSectionEmptyState();
    }
    if (state is ManualAttendanceBulkSuccess) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.check_circle_rounded, size: 48, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Successfully recorded attendance for ${(state as ManualAttendanceBulkSuccess).count} student(s) offline.',
              style: const TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    if (state is ManualAttendanceSearchSuccess) {
      final currentState = state as ManualAttendanceSearchSuccess;
      return ManualAttendanceSectionStudentCard(
        student: currentState.student,
        onTap: () => onSubmitAttendance(currentState.student),
        isSubmitting: false,
      );
    }
    if (state is ManualAttendanceSubmitting) {
      final currentState = state as ManualAttendanceSubmitting;
      return ManualAttendanceSectionStudentCard(
        student: currentState.student,
        onTap: null,
        isSubmitting: true,
      );
    }
    if (state is ManualAttendanceSuccess) {
      final currentState = state as ManualAttendanceSuccess;
      return ManualAttendanceSectionStudentCard(
        student: currentState.student,
        onTap: () => onSubmitAttendance(currentState.student),
        isSubmitting: false,
        showSuccess: true,
      );
    }
    if (state is ManualAttendanceError) {
      final currentState = state as ManualAttendanceError;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ManualAttendanceSectionStudentCard(
            student: currentState.student,
            onTap: () => onSubmitAttendance(currentState.student),
            isSubmitting: false,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: ManualAttendanceSectionInlineError(message: currentState.message),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
