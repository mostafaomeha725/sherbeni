import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrattendance/core/theme/light_colors.dart';

class ManualAttendanceInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool canCopy;
  final Function(String) onCopy;

  const ManualAttendanceInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.canCopy = false,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value.isNotEmpty ? value : 'Not available';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 14, 
                    color: value.isNotEmpty ? Colors.black87 : Colors.grey.shade400,
                    fontWeight: value.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          if (canCopy && value.isNotEmpty)
            IconButton(
              icon: Icon(Icons.copy_rounded, size: 18, color: AppLightColors.primary.withOpacity(0.7)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                onCopy('$label copied to clipboard');
              },
              tooltip: 'Copy',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
            ),
        ],
      ),
    );
  }
}
