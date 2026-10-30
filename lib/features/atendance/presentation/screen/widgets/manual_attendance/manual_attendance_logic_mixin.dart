import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qrattendance/features/atendance/domain/entities/manual_search_student_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/manual_attendance/manual_attendance_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/dialogs/manual_attendance_dialog.dart';

mixin ManualAttendanceLogicMixin on State<ManualAttendanceDialog> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  bool hasPlayedErrorForCurrentState = false;
  OverlayEntry? topToast;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    topToast?.remove();
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void onSearch() {
    final query = searchController.text.trim();
    if (query.isEmpty) return;
    focusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    hasPlayedErrorForCurrentState = false;

    if (widget.hasInternet) {
      context.read<ManualAttendanceCubit>().searchStudent(query);
    } else {
      final sessionName =
          '${widget.session.courseTitle} - ${widget.session.title}';
      context.read<ManualAttendanceCubit>().searchAndSubmitBulkOffline(
        queriesString: query,
        sessionId: widget.session.id.toString(),
        sessionName: sessionName,
      );
    }
  }

  void onClear() {
    searchController.clear();
    context.read<ManualAttendanceCubit>().reset();
    focusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void submitAttendance(ManualSearchStudentEntity student) {
    final cubit = context.read<ManualAttendanceCubit>();
    final sessionName =
        '${widget.session.courseTitle} - ${widget.session.title}';

    if (widget.hasInternet) {
      cubit.recordOnlineAttendance(
        student: student,
        sessionId: widget.session.id.toString(),
      );
    } else {
      cubit.recordOfflineAttendance(
        student: student,
        sessionId: widget.session.id.toString(),
        sessionName: sessionName,
      );
    }
  }

  Future<void> makeCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      showTopMessage('Phone number is not available', isError: true);
      return;
    }

    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        showTopMessage('Cannot open phone dialer', isError: true);
      }
    } catch (e) {
      showTopMessage('Failed to make a call', isError: true);
    }
  }

  void showTopMessage(String message, {bool isError = false}) {
    topToast?.remove();
    topToast = null;

    if (!mounted) return;

    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, -50 * (1 - value)),
                  child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isError ? Colors.red.shade800 : Colors.green.shade800,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      isError
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    topToast = entry;

    Future.delayed(const Duration(seconds: 3), () {
      if (topToast == entry && mounted) {
        topToast?.remove();
        topToast = null;
      }
    });
  }
}
