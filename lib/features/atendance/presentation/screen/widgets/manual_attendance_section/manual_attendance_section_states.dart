import 'package:flutter/material.dart';
import 'package:qrattendance/core/theme/light_colors.dart';

class ManualAttendanceSectionIdlePlaceholder extends StatelessWidget {
  const ManualAttendanceSectionIdlePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Text(
        'Enter student full name, code, phone, or email to search.',
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class ManualAttendanceSectionLoadingState extends StatelessWidget {
  const ManualAttendanceSectionLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: CircularProgressIndicator(
          color: AppLightColors.primary,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}

class ManualAttendanceSectionEmptyState extends StatelessWidget {
  const ManualAttendanceSectionEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 36, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'No student found. Please check your search and try again.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ManualAttendanceSectionErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ManualAttendanceSectionErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 32,
            color: Colors.red[400],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 13, color: Colors.red[700], height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry', style: TextStyle(fontSize: 13)),
            style: TextButton.styleFrom(
              foregroundColor: AppLightColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class ManualAttendanceSectionInlineError extends StatelessWidget {
  final String message;
  const ManualAttendanceSectionInlineError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }
}
