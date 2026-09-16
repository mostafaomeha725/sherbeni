import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/core/widgets/custom_app_bar.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/session_students/session_students_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/session_students_screen_body.dart';

class SessionStudentsScreen extends StatefulWidget {
  final SessionEntity session;

  const SessionStudentsScreen({super.key, required this.session});

  @override
  State<SessionStudentsScreen> createState() => _SessionStudentsScreenState();
}

class _SessionStudentsScreenState extends State<SessionStudentsScreen> {
  late SessionStudentsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<SessionStudentsCubit>();
    _cubit.fetchStudents(widget.session.id.toString());
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
        appBar: const CustomAppBar(title: "Students"),
        body: SessionStudentsScreenBody(session: widget.session),
      ),
    );
  }
}
