import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrattendance/core/cache/preferences_storage.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/core/widgets/custom_app_bar.dart';
import 'package:qrattendance/core/widgets/custom_loading.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/academic_classes/academic_classes_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/academic_classes_screen_body.dart';

class AcademicClassesScreen extends StatefulWidget {
  final String? token;

  const AcademicClassesScreen({super.key, this.token});

  @override
  State<AcademicClassesScreen> createState() => _AcademicClassesScreenState();
}

class _AcademicClassesScreenState extends State<AcademicClassesScreen> {
  String? finalToken;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  void loadToken() {
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
              sl<AcademicClassesCubit>()
                ..fetchAcademicClasses(finalToken ?? ''),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFE),
        appBar: const CustomAppBar(
          title: 'Academic Year',
          showBackButton: false,
        ),
        body: isLoading
            ? CustomLoading.showLoader()
            : AcademicClassesScreenBody(token: finalToken ?? ''),
      ),
    );
  }
}
