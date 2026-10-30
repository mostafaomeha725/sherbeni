import 'package:flutter/material.dart';

class ManualAttendanceDivider extends StatelessWidget {
  const ManualAttendanceDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
    );
  }
}
