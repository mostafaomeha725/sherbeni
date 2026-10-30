import 'package:flutter/material.dart';

enum DialogType { success, error, warning }

class Dialogmessage extends StatelessWidget {
  final String title;
  final String subtitle;
  final DialogType type;

  const Dialogmessage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.type,
  });

  Color get titleColor {
    switch (type) {
      case DialogType.success:
        return const Color(0xFF2DBE60);
      case DialogType.error:
        return const Color(0xFFD93434);
      case DialogType.warning:
        return const Color(0xFFFFB703);
    }
  }

  Color get iconBgColor {
    switch (type) {
      case DialogType.success:
        return const Color(0xFFE9F8F0);
      case DialogType.error:
        return const Color(0xFFFDEEEE);
      case DialogType.warning:
        return const Color(0xFFFFF7E8);
    }
  }

  IconData get iconData {
    switch (type) {
      case DialogType.success:
        return Icons.check;
      case DialogType.error:
        return Icons.error_outline;
      case DialogType.warning:
        return Icons.warning_amber_outlined;
    }
  }

  Color get iconColor {
    switch (type) {
      case DialogType.success:
        return const Color(0xFF2DBE60);
      case DialogType.error:
        return const Color(0xFFD93434);
      case DialogType.warning:
        return const Color(0xFFFFB703);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                  softWrap: true,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff6C737F),
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
