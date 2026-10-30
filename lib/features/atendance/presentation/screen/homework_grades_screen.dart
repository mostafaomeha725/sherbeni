import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/core/widgets/custom_app_bar.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/homework_grades/homework_grades_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/homework_grades/homework_grades_screen_body.dart';

class HomeworkGradesScreen extends StatefulWidget {
  final SessionEntity session;

  const HomeworkGradesScreen({super.key, required this.session});

  @override
  State<HomeworkGradesScreen> createState() => _HomeworkGradesScreenState();
}

class _HomeworkGradesScreenState extends State<HomeworkGradesScreen> {
  late HomeworkGradesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<HomeworkGradesCubit>();
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
        appBar: const CustomAppBar(title: "Homework Grades"),
        body: HomeworkGradesScreenBody(session: widget.session),
      ),
    );
  }
}
