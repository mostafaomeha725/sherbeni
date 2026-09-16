import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/device_id/get_device_id.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/widgets/app_form_field.dart';
import 'package:qrattendance/core/widgets/app_svg.dart';
import 'package:qrattendance/core/widgets/custom_button.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/auth/presentation/cubit/login_cubit/login_cubit.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty) {
      EasyLoading.showError('Please enter your Email', dismissOnTap: true);
      return;
    }

    if (password.isEmpty) {
      EasyLoading.showError('Please enter your password', dismissOnTap: true);
      return;
    }

    if (password.length < 4) {
      EasyLoading.showError(
        'Password must be at least 4 characters',
        dismissOnTap: true,
      );
      return;
    }

    final deviceId = await getDeviceId();

    if (!mounted) return;
    context.read<LoginCubit>().signIn(
      username: username,
      password: password,
      deviceId: deviceId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Email',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xff333333),
          ),
        ),
        SizedBox(height: 8.h),
        AppFormField(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 12.w),
            child: const AppSVG(assetName: 'assets/images/hugeicons_user.svg'),
          ),
          controller: usernameController,
          hintText: 'Email',
          keyboardType: TextInputType.emailAddress,
          fillColor: const Color(0xffE5E5EA),
          borderColor: Colors.transparent,
          radius: 12.r,
        ),
        SizedBox(height: 24.h),
        AppText(
          'Password',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xff333333),
          ),
        ),
        SizedBox(height: 8.h),
        AppFormField(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 12.w),
            child: const AppSVG(
              assetName: 'assets/images/hugeicons_lock-password.svg',
            ),
          ),
          controller: passwordController,
          hintText: 'Password',
          obsecureText: obscurePassword,
          keyboardType: TextInputType.visiblePassword,
          maxLines: 1,
          radius: 12.r,
          suffixIcon: IconButton(
            icon: Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
                size: 22.sp,
              ),
            ),
            onPressed: () {
              setState(() {
                obscurePassword = !obscurePassword;
              });
            },
          ),
          fillColor: const Color(0xffE5E5EA),
          borderColor: Colors.transparent,
        ),
        SizedBox(height: 48.h),
        AppButton(
          text: 'Login',
          textColor: Colors.white,
          onPressed: _handleLogin,
          // color: const Color(0xff0C1045),
          color: AppLightColors.primary,
          textSize: 18.sp,
          radius: 12.r,
          height: 48.h,
        ),
      ],
    );
  }
}
