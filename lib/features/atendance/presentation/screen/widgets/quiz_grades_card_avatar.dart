import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';

class QuizGradesCardAvatar extends StatelessWidget {
  final String studentName;
  final bool isGraded;

  const QuizGradesCardAvatar({
    super.key,
    required this.studentName,
    required this.isGraded,
  });

  String _getInitials(String name) {
    if (name.isEmpty) return 'S';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGraded
              ? [
                  const Color(
                    0xFF22C55E,
                  ).withOpacity(0.2), // Keeping original opacity for now
                  const Color(0xFF16A34A).withOpacity(0.1),
                ]
              : [
                  AppLightColors.primaryLight,
                  AppLightColors.primary.withOpacity(0.05),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: isGraded
              ? const Color(0xFF16A34A).withOpacity(0.3)
              : AppLightColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Center(
        child: AppText(
          _getInitials(studentName),
          alignment: AlignmentDirectional.center,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isGraded ? const Color(0xFF15803D) : AppLightColors.primary,
            height: 1.2, // Help adjust Arabic vertical font metrics
          ),
        ),
      ),
    );
  }
}
