import 'package:flutter/material.dart';

class AttendanceStatusDialog {
  static Future<String?> show(
    BuildContext context, {
    String? studentName,
    String? groupName,
  }) async {
    final String title = studentName != null && groupName != null
        ? "Select Attendance Status for $studentName in $groupName"
        : "Select Attendance Status";

    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontSize: 22)),
          content: const Text("Please select the student's status"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, "yes"),
              child: const Text("✅ Present"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, "late"),
              child: const Text("⚠️ Late"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, "no"),
              child: const Text("❌ Absent"),
            ),
          ],
        );
      },
    );
  }
}
