import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrattendance/core/cache/preferences_storage.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/core/widgets/custom_app_bar.dart';
import 'package:qrattendance/core/widgets/custom_loading.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/show_sessions/show_sessions_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/attendance_screen_body.dart';

class AttendanceScreen extends StatefulWidget {
  final String? token;

  const AttendanceScreen({super.key, this.token});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? finalToken;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  void loadToken() {
    // ✅ هات التوكن من SharedPreferences أو من widget لو مبعوت
    final token = sl<PreferencesStorage>().getUserToken() ?? widget.token;
    setState(() {
      finalToken = token;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<ShowSessionsCubit>()..fetchSessions(finalToken ?? ''),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFE),
        appBar: const CustomAppBar(title: 'Subjects'),
        body: isLoading
            ? CustomLoading.showLoader()
            : AttendanceScreenBody(token: finalToken ?? ''),
      ),
    );
  }
}
