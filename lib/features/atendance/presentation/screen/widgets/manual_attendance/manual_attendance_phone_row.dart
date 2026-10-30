import 'package:flutter/material.dart';

class ManualAttendancePhoneRow extends StatelessWidget {
  final String label;
  final String phone;
  final Function(String) onCall;

  const ManualAttendancePhoneRow({
    super.key,
    required this.label,
    required this.phone,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = phone.isNotEmpty ? phone : 'Not available';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.phone_rounded, size: 20, color: Colors.grey.shade400),
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
                    color: phone.isNotEmpty ? Colors.black87 : Colors.grey.shade400,
                    fontWeight: phone.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          if (phone.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () => onCall(phone),
              icon: const Icon(Icons.call_rounded, size: 16),
              label: const Text('Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
        ],
      ),
    );
  }
}
