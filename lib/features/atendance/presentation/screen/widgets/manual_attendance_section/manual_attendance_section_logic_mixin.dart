import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrattendance/features/atendance/domain/entities/manual_search_student_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/manual_attendance/manual_attendance_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/manual_attendance_section/manual_attendance_section.dart';

mixin ManualAttendanceSectionLogicMixin on State<ManualAttendanceSection> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  
  void onSearch() {
    final query = searchController.text.trim();
    if (query.isEmpty) return;
    focusNode.unfocus();
    
    if (widget.hasInternet) {
      context.read<ManualAttendanceCubit>().searchStudent(query);
    } else {
      final sessionName = '${widget.session.courseTitle} - ${widget.session.title}';
      context.read<ManualAttendanceCubit>().searchAndSubmitBulkOffline(
            queriesString: query,
            sessionId: widget.session.id.toString(),
            sessionName: sessionName,
          );
    }
  }

  void onClear() {
    searchController.clear();
    context.read<ManualAttendanceCubit>().reset();
    focusNode.unfocus();
  }


  void submitAttendance(ManualSearchStudentEntity student) {
    final cubit = context.read<ManualAttendanceCubit>();
    final sessionName = '${widget.session.courseTitle} - ${widget.session.title}';

    if (widget.hasInternet) {
      cubit.recordOnlineAttendance(
        student: student,
        sessionId: widget.session.id.toString(),
      );
    } else {
      cubit.recordOfflineAttendance(
        student: student,
        sessionId: widget.session.id.toString(),
        sessionName: sessionName,
      );
    }
  }

  void showResultSnackbar(
    BuildContext ctx,
    String message, {
    required bool isSuccess,
  }) {
    ScaffoldMessenger.of(ctx).clearSnackBars();
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green[700] : Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
