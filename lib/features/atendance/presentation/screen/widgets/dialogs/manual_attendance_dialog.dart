import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/manual_attendance/manual_attendance_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/manual_attendance/manual_attendance_body_content.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/manual_attendance/manual_attendance_header.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/manual_attendance/manual_attendance_search_bar.dart';

import 'package:qrattendance/features/atendance/presentation/screen/widgets/manual_attendance/manual_attendance_logic_mixin.dart';
import 'package:qrattendance/features/atendance/domain/entities/student_entity.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/student_data_bottom_sheet/student_data_bottom_sheet.dart';
import 'package:qrattendance/core/utils/audio_helper.dart';

class ManualAttendanceDialog extends StatefulWidget {
  final SessionEntity session;
  final bool hasInternet;
  final VoidCallback? onClose;

  const ManualAttendanceDialog({
    super.key,
    required this.session,
    required this.hasInternet,
    this.onClose,
  });

  @override
  State<ManualAttendanceDialog> createState() => _ManualAttendanceDialogState();
}

class _ManualAttendanceDialogState extends State<ManualAttendanceDialog>
    with SingleTickerProviderStateMixin, ManualAttendanceLogicMixin {
  @override
  Widget build(BuildContext context) {
    // The dialog content wrapper
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 750),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ManualAttendanceHeader(
                hasInternet: widget.hasInternet,
                onClose: () {
                  if (widget.onClose != null) {
                    widget.onClose!();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
              ManualAttendanceSearchBar(
                searchController: searchController,
                focusNode: focusNode,
                onSearch: onSearch,
                onClear: onClear,
              ),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20),
                  child: BlocConsumer<ManualAttendanceCubit, ManualAttendanceState>(
                    listenWhen: (prev, curr) =>
                        curr is ManualAttendanceSuccess ||
                        curr is ManualAttendanceBulkSuccess ||
                        curr is ManualAttendanceError ||
                        curr is ManualAttendanceSearchError ||
                        curr is ManualAttendanceEmpty,
                    listener: (context, state) {
                      // Handle sounds and snacks
                      if (state is ManualAttendanceSuccess) {
                        AudioHelper.playSuccess();
                        showTopMessage('Attendance recorded successfully.');
                        // We do not emit ScanQrOflineSuccess here to avoid showing two success UI elements.
                        if (widget.session.hasHomework) {
                          final studentEntity = StudentEntity(
                            id: state.student.studentId,
                            studentQrCode: state.student.studentCode,
                            name: state.student.studentName,
                            email: state.student.email,
                            studentPhone: state.student.phone,
                            parentPhone: state.student.parentPhone,
                            studentType: state.student.educationalLevel,
                            isApproved:
                                state.student.status.toLowerCase() ==
                                'approved',
                          );
                          StudentDataBottomSheet.show(
                            context,
                            studentEntity,
                            session: widget.session,
                            forceHomework: true,
                            isOffline: !widget.hasInternet,
                          );
                        }
                      } else if (state is ManualAttendanceBulkSuccess) {
                        AudioHelper.playSuccess();
                        showTopMessage(
                          'تم حفظ الحضور لـ ${state.count} طالب بنجاح في وضع عدم الاتصال',
                        );

                        if (widget.session.hasHomework &&
                            state.queries.isNotEmpty) {
                          final query = state.queries.first;
                          final pendingKey = state.queryToKeyMap[query];
                          if (pendingKey != null) {
                            Future.delayed(const Duration(milliseconds: 250), () {
                              if (!context.mounted) return;
                              StudentDataBottomSheet.show(
                                context,
                                null,
                                session: widget.session,
                                forceHomework: true,
                                isOffline: true,
                                offlineStudentId: pendingKey,
                                offlineStudentName: query,
                              );
                            });
                          }
                        }

                        // Clear the field automatically upon success
                        onClear();
                      } else if (state is ManualAttendanceError) {
                        AudioHelper.playError();
                        showTopMessage(state.message, isError: true);
                      } else if (state is ManualAttendanceEmpty) {
                        if (!hasPlayedErrorForCurrentState) {
                          AudioHelper.playError();
                          hasPlayedErrorForCurrentState = true;
                        }
                      } else if (state is ManualAttendanceSearchError) {
                        if (!hasPlayedErrorForCurrentState) {
                          AudioHelper.playError();
                          hasPlayedErrorForCurrentState = true;
                        }
                      }
                    },
                    builder: (context, state) {
                      return AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        child: ManualAttendanceBodyContent(
                          state: state,
                          onMakeCall: makeCall,
                          onShowTopMessage: showTopMessage,
                          onSubmitAttendance: submitAttendance,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
