import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/show_student_data/show_student_data_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/record_online_attendance/record_online_attendance_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/scan_qr_screen_body.dart';

class ScanQrScreen extends StatelessWidget {
  final SessionEntity session;

  const ScanQrScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<ShowStudentDataCubit>()),
        BlocProvider(create: (context) => sl<RecordOnlineAttendanceCubit>()),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey[850],
        body: ScanQrScreenBody(session: session),
      ),
    );
  }
}
