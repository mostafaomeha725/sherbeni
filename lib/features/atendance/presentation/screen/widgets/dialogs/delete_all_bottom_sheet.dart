import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/bouncing_widgets.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/stored_data/stored_data_cubit.dart';

void showDeleteAllBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (bottomSheetContext) => Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_sweep_rounded,
              color: Colors.red,
              size: 32.sp,
            ),
          ),
          SizedBox(height: 16.h),
          AppText(
            'حذف جميع السجلات',
            style: font18w700.copyWith(color: const Color(0xFF222222)),
            alignment: AlignmentDirectional.center,
          ),
          SizedBox(height: 8.h),
          AppText(
            'هل أنت متأكد من حذف جميع السجلات؟ هذا الإجراء لا يمكن التراجع عنه وسيتم مسح جميع بيانات الحضور ودرجات الكويز.',
            style: font14w500.copyWith(
              color: const Color(0xFF777777),
              height: 1.5,
            ),
            maxLines: 5,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: BounceIt(
                  onPressed: () => bottomSheetContext.pop(),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: AppText(
                        'إلغاء',
                        style: font14w700.copyWith(
                          color: const Color(0xFF555555),
                        ),
                        alignment: AlignmentDirectional.center,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: BounceIt(
                  onPressed: () {
                    bottomSheetContext.pop();
                    context.read<StoredDataCubit>().deleteAllHistory();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.3),
                          blurRadius: 8.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AppText(
                        'حذف الكل',
                        style: font14w700.copyWith(color: Colors.white),
                        alignment: AlignmentDirectional.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
