import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/core/utils/easy_loading.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/domain/entities/student_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/update_homework_grade/update_homework_grade_cubit.dart';
import 'student_data_bottom_sheet_content.dart';

class StudentDataBottomSheet extends StatefulWidget {
  final StudentEntity? student;
  final SessionEntity? session;
  final bool forceHomework;
  final bool isOffline;
  final String? offlineStudentId;
  final String? offlineStudentName;

  const StudentDataBottomSheet({
    super.key,
    this.student,
    this.session,
    this.forceHomework = false,
    this.isOffline = false,
    this.offlineStudentId,
    this.offlineStudentName,
  });

  static Future<void> show(
    BuildContext context,
    StudentEntity? student, {
    SessionEntity? session,
    bool forceHomework = false,
    bool isOffline = false,
    String? offlineStudentId,
    String? offlineStudentName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        final needsHomework =
            forceHomework || (session != null && session.hasHomework);

        if (needsHomework) {
          return BlocProvider(
            create: (context) => sl<UpdateHomeworkGradeCubit>(),
            child: StudentDataBottomSheet(
              student: student,
              session: session,
              forceHomework: forceHomework,
              isOffline: isOffline,
              offlineStudentId: offlineStudentId,
              offlineStudentName: offlineStudentName,
            ),
          );
        }

        return StudentDataBottomSheet(
          student: student,
          session: session,
          forceHomework: forceHomework,
          isOffline: isOffline,
          offlineStudentId: offlineStudentId,
          offlineStudentName: offlineStudentName,
        );
      },
    );
  }

  @override
  State<StudentDataBottomSheet> createState() => _StudentDataBottomSheetState();
}

class _StudentDataBottomSheetState extends State<StudentDataBottomSheet> {
  final TextEditingController _gradeController = TextEditingController();

  bool get _showHomework =>
      widget.forceHomework ||
      (widget.session != null && widget.session!.hasHomework);

  @override
  void dispose() {
    _gradeController.dispose();
    super.dispose();
  }

  void _submitGrade() {
    if (widget.session == null) return;

    final gradeText = _gradeController.text.trim();
    if (gradeText.isEmpty) {
      showError("يرجى إدخال درجة الواجب");
      return;
    }
    final grade = num.tryParse(gradeText);
    if (grade == null) {
      showError("يرجى إدخال رقم صحيح");
      return;
    }

    if (grade < 0) {
      showError("لا يمكن أن تكون الدرجة أقل من صفر");
      return;
    }

    if (grade > widget.session!.effectiveHomeworkMaxGrade) {
      showError(
        "الدرجة لا يمكن أن تتجاوز النهاية العظمى (${widget.session!.effectiveHomeworkMaxGrade})",
      );
      return;
    }

    context.read<UpdateHomeworkGradeCubit>().submitGrade(
      sessionId: widget.session!.id.toString(),
      sessionName: "${widget.session!.courseTitle} - ${widget.session!.title}",
      studentId: widget.student?.id ?? widget.offlineStudentId ?? '',
      grade: grade,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showHomework) {
      return BlocConsumer<UpdateHomeworkGradeCubit, UpdateHomeworkGradeState>(
        listener: (context, state) {
          if (state is UpdateHomeworkGradeSuccess) {
            showSuccess(state.message);
            Navigator.of(context).pop();
          } else if (state is UpdateHomeworkGradeFailure) {
            showError(state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is UpdateHomeworkGradeLoading;
          return StudentDataBottomSheetContent(
            student: widget.student,
            session: widget.session,
            showHomework: _showHomework,
            isOffline: widget.isOffline,
            offlineStudentName: widget.offlineStudentName,
            gradeController: _gradeController,
            isLoading: isLoading,
            onSubmitGrade: _submitGrade,
          );
        },
      );
    }

    return StudentDataBottomSheetContent(
      student: widget.student,
      session: widget.session,
      showHomework: _showHomework,
      isOffline: widget.isOffline,
      offlineStudentName: widget.offlineStudentName,
      gradeController: _gradeController,
      isLoading: false,
      onSubmitGrade: _submitGrade,
    );
  }
}
