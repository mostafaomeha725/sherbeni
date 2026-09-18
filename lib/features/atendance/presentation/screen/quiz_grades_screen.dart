import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/core/widgets/custom_app_bar.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/quiz_grades/quiz_grades_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/quiz_grades_screen_body.dart';

class QuizGradesScreen extends StatefulWidget {
  final SessionEntity session;

  const QuizGradesScreen({super.key, required this.session});

  @override
  State<QuizGradesScreen> createState() => _QuizGradesScreenState();
}

class _QuizGradesScreenState extends State<QuizGradesScreen> {
  late QuizGradesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<QuizGradesCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.fetchStudents(widget.session.id.toString());
    });
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFE),
        appBar: const CustomAppBar(title: "Quiz Grades"),
        body: QuizGradesScreenBody(session: widget.session),
      ),
    );
  }
}
