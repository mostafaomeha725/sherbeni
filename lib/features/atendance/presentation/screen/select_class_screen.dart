import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/core/widgets/custom_app_bar.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/show_classes/show_classes_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/select_class_screen_body.dart';

import 'package:qrattendance/features/atendance/presentation/cubit/check_session_quizzes/check_session_quizzes_cubit.dart';

class SelectClassScreen extends StatelessWidget {
  final SessionEntity subject;
  final String classId;

  const SelectClassScreen({
    super.key,
    required this.subject,
    required this.classId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<ShowClassesCubit>()),
        BlocProvider(create: (context) => sl<CheckSessionQuizzesCubit>()),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFE),
        appBar: const CustomAppBar(title: 'Sessions'),
        body: SelectClassScreenBody(subjectId: subject.id, classId: classId),
      ),
    );
  }
}
