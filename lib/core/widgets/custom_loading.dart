import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../theme/light_colors.dart';

class CustomLoading {
  static AbsorbPointer showLoadingView() {
    return AbsorbPointer(
      absorbing: true,
      child: SizedBox(
        height: 1.sh,
        width: 1.sw,
        child: Center(
          child: SpinKitDoubleBounce(
            color: AppLightColors.primary,
            size: 40.sh,
          ),
        ),
      ),
    );
  }

  static AbsorbPointer showLoader() {
    return AbsorbPointer(
      absorbing: true,
      child: Center(
        child: SpinKitPulse(color: AppLightColors.primary, size: 40.sh),
      ),
    );
  }
}
