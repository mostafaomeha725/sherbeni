import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/bouncing_widgets.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/presentation/screen/session_students_screen.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_offline_session_attendances_use_case.dart';

class StudentCountIcon extends StatefulWidget {
  final SessionEntity session;

  const StudentCountIcon({super.key, required this.session});

  @override
  State<StudentCountIcon> createState() => _StudentCountIconState();
}

class _StudentCountIconState extends State<StudentCountIcon> {
  bool isOffline = false;
  int offlineCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final connectivityResult = await sl<Connectivity>().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      isOffline = true;
      final result = await sl<GetOfflineSessionAttendancesUseCase>().call(
        widget.session.id,
      );
      result.fold((l) => null, (r) => offlineCount = r.length);
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 32.w,
        width: 32.w,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (isOffline) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppLightColors.primaryLight,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_alt_outlined,
              size: 14.sp,
              color: AppLightColors.primary,
            ),
            SizedBox(width: 4.w),
            AppText(
              '$offlineCount',
              style: font12w700.copyWith(color: AppLightColors.primary),
            ),
          ],
        ),
      );
    }

    return BounceIt(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SessionStudentsScreen(session: widget.session),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.people_alt_outlined,
          size: 16.sp,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }
}
