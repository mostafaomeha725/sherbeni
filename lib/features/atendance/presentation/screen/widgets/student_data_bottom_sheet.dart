import 'package:flutter/material.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/utils/url_launcher_util.dart';
import 'package:qrattendance/features/atendance/domain/entities/student_entity.dart';

class StudentDataBottomSheet extends StatelessWidget {
  final StudentEntity student;

  const StudentDataBottomSheet({super.key, required this.student});

  static Future<void> show(BuildContext context, StudentEntity student) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StudentDataBottomSheet(student: student),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom: bottomPadding > 0 ? bottomPadding + 16.0 : 24.0,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.green,
            child: Icon(Icons.check, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            "تم تسجيل الحضور بنجاح",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            icon: Icons.person,
            title: "اسم الطالب",
            value: student.name,
            theme: theme,
          ),
          _buildInfoRow(
            icon: Icons.qr_code,
            title: "كود الطالب",
            value: student.studentQrCode.isNotEmpty
                ? student.studentQrCode
                : student.id,
            theme: theme,
          ),
          if (student.group?.name != null && student.group!.name.isNotEmpty)
            _buildInfoRow(
              icon: Icons.school,
              title: "المرحلة الدراسية",
              value: student.group!.name,
              theme: theme,
            ),
          _buildPhoneRow(
            icon: Icons.phone_android_rounded,
            title: "رقم تليفون الطالب",
            phone: student.studentPhone,
            theme: theme,
          ),
          _buildPhoneRow(
            icon: Icons.phone_rounded,
            title: "رقم تليفون ولي الأمر",
            phone: student.parentPhone,
            theme: theme,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppLightColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "متابعة",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppLightColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppLightColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneRow({
    required IconData icon,
    required String title,
    required String phone,
    required ThemeData theme,
  }) {
    final hasPhone = phone.isNotEmpty && phone != 'null';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppLightColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppLightColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    hasPhone ? phone : "غير متوفر",
                    textDirection: TextDirection.ltr,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: hasPhone ? Colors.black87 : Colors.grey[400],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (hasPhone) ...[
            const SizedBox(width: 16),
            InkWell(
              onTap: () async {
                try {
                  await UrlLauncherUtil.launchPhone(phone);
                } catch (e) {
                  debugPrint('Could not launch phone: $e');
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.call, color: Colors.green, size: 20),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
