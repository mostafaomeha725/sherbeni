import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/bouncing_widgets.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/stored_data/stored_data_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/stored_data/stored_data_state.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/stored_data/stored_data_dialogs.dart';

class StoredDataActionsBar extends StatelessWidget {
  const StoredDataActionsBar({super.key});

  Widget _buildActionCard({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return BounceIt(
      onPressed: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Center(
              child: Icon(icon, color: color, size: 20.sp),
            ),
            Flexible(
              child: AppText(
                label,
                style: font12w700.copyWith(color: const Color(0xFF222222)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                alignment: AlignmentDirectional.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              icon: Icons.sync_rounded,
              color: const Color(0xFF059669),
              label: 'مزامنة الكل',
              onPressed: () => context.read<StoredDataCubit>().retrySync(),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildActionCard(
              icon: Icons.download_rounded,
              color: Colors.blueAccent,
              label: 'اكسيل',
              onPressed: () {
                final state = context.read<StoredDataCubit>().state;
                bool hasData = false;
                if (state is StoredDataLoaded) {
                  hasData =
                      state.attendanceHistory.isNotEmpty ||
                      state.quizGradeHistory.isNotEmpty;
                }

                if (!hasData) {
                  EasyLoading.showInfo('لا يوجد بيانات لتصديرها');
                  return;
                }
                context.read<StoredDataCubit>().exportToExcel();
              },
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildActionCard(
              icon: Icons.delete_sweep_rounded,
              color: Colors.redAccent,
              label: 'حذف الكل',
              onPressed: () {
                final state = context.read<StoredDataCubit>().state;
                bool hasData = false;
                if (state is StoredDataLoaded) {
                  hasData =
                      state.attendanceHistory.isNotEmpty ||
                      state.quizGradeHistory.isNotEmpty;
                }

                if (!hasData) {
                  EasyLoading.showInfo('لا يوجد بيانات لحذفها');
                  return;
                }
                StoredDataDialogs.showDeleteAllBottomSheet(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
