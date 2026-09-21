import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qrattendance/core/utils/easy_loading.dart';
import 'package:qrattendance/core/routes/route_paths.dart';
import 'package:qrattendance/features/auth/presentation/cubit/login_cubit/login_cubit.dart';
import 'package:qrattendance/features/auth/presentation/screen/widgets/login_form.dart';
import 'package:qrattendance/features/auth/presentation/screen/widgets/login_header.dart';

class LoginScreenBody extends StatelessWidget {
  const LoginScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginLoading) {
          showLoading(status: 'Loading...');
        } else {
          hideLoading();
          if (state is LoginSuccess) {
            GoRouter.of(
              context,
            ).push(Routes.academicClassesScreen, extra: state.user.id);
          } else if (state is LoginFailure) {
            showError(state.message);
          }
        }
      },
      builder: (context, state) {
        return const Padding(
          padding: EdgeInsets.only(right: 24, left: 24, top: 52),
          child: SingleChildScrollView(
            child: Column(
              children: [LoginHeader(), SizedBox(height: 52), LoginForm()],
            ),
          ),
        );
      },
    );
  }
}
