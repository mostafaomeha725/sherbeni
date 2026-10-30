import 'package:flutter/material.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/features/atendance/domain/entities/manual_search_student_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/manual_attendance/manual_attendance_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/manual_attendance/manual_attendance_student_card.dart';

class ManualAttendanceBodyContent extends StatelessWidget {
  final ManualAttendanceState state;
  final Function(String) onMakeCall;
  final Function(String, {bool isError}) onShowTopMessage;
  final Function(ManualSearchStudentEntity) onSubmitAttendance;

  const ManualAttendanceBodyContent({
    super.key,
    required this.state,
    required this.onMakeCall,
    required this.onShowTopMessage,
    required this.onSubmitAttendance,
  });

  @override
  Widget build(BuildContext context) {
    if (state is ManualAttendanceIdle) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.search_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Search for a student to record attendance',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (state is ManualAttendanceSearching) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const CircularProgressIndicator(color: AppLightColors.primary),
            const SizedBox(height: 16),
            Text(
              'Searching...',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (state is ManualAttendanceSearchError) {
      final msg = (state as ManualAttendanceSearchError).message;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              msg,
              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (state is ManualAttendanceEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.person_off_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No student found with that data',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
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

    if (state is ManualAttendanceSearchSuccess ||
        state is ManualAttendanceSubmitting ||
        state is ManualAttendanceSuccess ||
        state is ManualAttendanceError) {
      
      ManualSearchStudentEntity? student;
      bool isSubmitting = false;
      bool isSuccess = false;

      if (state is ManualAttendanceSearchSuccess) {
        student = (state as ManualAttendanceSearchSuccess).student;
      } else if (state is ManualAttendanceSubmitting) {
        student = (state as ManualAttendanceSubmitting).student;
        isSubmitting = true;
      } else if (state is ManualAttendanceSuccess) {
        student = (state as ManualAttendanceSuccess).student;
        isSuccess = true;
      } else if (state is ManualAttendanceError) {
        student = (state as ManualAttendanceError).student;
      }

      if (student == null) return const SizedBox.shrink();

      return ManualAttendanceStudentCard(
        student: student,
        isSubmitting: isSubmitting,
        isSuccess: isSuccess,
        onMakeCall: onMakeCall,
        onShowTopMessage: onShowTopMessage,
        onSubmitAttendance: () => onSubmitAttendance(student!),
      );
    }

    return const SizedBox.shrink();
  }
}
