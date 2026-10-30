import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrattendance/core/widgets/custom_search.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/homework_grades/homework_grades_cubit.dart';

class HomeworkGradesSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const HomeworkGradesSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomSearch(
      controller: controller,
      hintText: 'Search by name, code, or phone...',
      borderColor: const Color(0xFFE2E8F0),
      onChanged: (value) =>
          context.read<HomeworkGradesCubit>().searchStudents(value),
    );
  }
}
