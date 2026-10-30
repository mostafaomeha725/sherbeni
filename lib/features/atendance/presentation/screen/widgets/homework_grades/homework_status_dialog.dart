import 'package:flutter/material.dart';

class HomeworkStatusDialog {
  static Future<String?> show(
    BuildContext context, {
    String? studentName,
  }) async {
    final String title = studentName != null
        ? "Homework Status for $studentName"
        : "Homework Status";

    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontSize: 22)),
          content: const Text("Select the student's homework status"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, "done"),
              child: const Text("✅ Completed"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, "incomplete"),
              child: const Text("⚠️ Incomplete"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, "not_done"),
              child: const Text("❌ Not Done"),
            ),
          ],
        );
      },
    );
  }
}
