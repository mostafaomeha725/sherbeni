import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/stored_data/stored_data_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/stored_data/stored_data_view.dart';

class StoredDataScreen extends StatelessWidget {
  const StoredDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<StoredDataCubit>()..loadHistory(),
      child: const StoredDataView(),
    );
  }
}
