import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:qrattendance/core/cache/preferences_storage.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/core/routes/route_paths.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/widgets/custom_app_bar.dart';
import 'package:qrattendance/core/widgets/custom_loading.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/academic_classes/academic_classes_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/stored_data_screen.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/academic_classes/academic_classes_logout_sheet.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/academic_classes/academic_classes_screen_body.dart';
import 'package:qrattendance/features/auth/presentation/cubit/logout_cubit/logout_cubit.dart';
import 'package:qrattendance/features/auth/presentation/cubit/logout_cubit/logout_state.dart';

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
        BlocProvider(create: (context) => sl<LogoutCubit>()),
      ],
      child: BlocListener<LogoutCubit, LogoutState>(
        listener: (context, state) {
          if (state is LogoutLoading) {
            EasyLoading.show(status: 'جاري تسجيل الخروج...');
          } else {
            EasyLoading.dismiss();
            if (state is LogoutSuccess) {
              EasyLoading.showSuccess('تم تسجيل الخروج بنجاح');
              context.go(Routes.loginScreen);
            } else if (state is LogoutFailure) {
              EasyLoading.showError(
                state.message,
                duration: const Duration(seconds: 2),
              );
            }
          }
        },
        child: Builder(
          builder: (innerContext) => Scaffold(
            backgroundColor: const Color(0xFFFDFDFE),
            appBar: CustomAppBar(
              title: 'Academic Year',
              showBackButton: false,
              leading: IconButton(
                icon: const Icon(Icons.logout, color: AppLightColors.primary),
                tooltip: 'تسجيل الخروج',
                onPressed: () => AcademicClassesLogoutSheet.show(innerContext),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.cloud_off,
                    color: AppLightColors.primary,
                  ),
                  tooltip: 'البيانات المخزنة',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StoredDataScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: isLoading
                ? CustomLoading.showLoader()
                : AcademicClassesScreenBody(token: finalToken ?? ''),
          ),
        ),
      ),
    );
  }
}
