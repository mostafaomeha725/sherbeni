import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:excel/excel.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:qrattendance/features/atendance/domain/use_cases/get_attendance_history_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_quiz_grade_history_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/delete_history_record_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/sync_offline_data_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/retry_specific_offline_attendance_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/retry_all_offline_attendance_use_case.dart';
import 'package:qrattendance/core/network/network_service.dart';

import 'stored_data_state.dart';

part 'stored_data_sync.dart';
part 'stored_data_delete.dart';
part 'stored_data_export.dart';

class StoredDataCubit extends Cubit<StoredDataState> {
  final GetAttendanceHistoryUseCase getAttendanceHistoryUseCase;
  final GetQuizGradeHistoryUseCase getQuizGradeHistoryUseCase;
  final DeleteHistoryRecordUseCase deleteHistoryRecordUseCase;
  final SyncOfflineDataUseCase syncOfflineDataUseCase;
  final RetrySpecificOfflineAttendanceUseCase
  retrySpecificOfflineAttendanceUseCase;
  final RetryAllOfflineAttendanceUseCase retryAllOfflineAttendanceUseCase;

  StoredDataCubit({
    required this.getAttendanceHistoryUseCase,
    required this.getQuizGradeHistoryUseCase,
    required this.deleteHistoryRecordUseCase,
    required this.syncOfflineDataUseCase,
    required this.retrySpecificOfflineAttendanceUseCase,
    required this.retryAllOfflineAttendanceUseCase,
  }) : super(StoredDataInitial());

  Future<void> loadHistory() async {
    emit(StoredDataLoading());

    final attendanceResult = await getAttendanceHistoryUseCase.call();
    final gradesResult = await getQuizGradeHistoryUseCase.call();

    attendanceResult.fold(
      (dynamic l) {
        emit(StoredDataError(l.message));
      },
      (attendanceData) {
        gradesResult.fold(
          (dynamic l) {
            emit(StoredDataError(l.message));
          },
          (gradesData) {
            emit(
              StoredDataLoaded(
                attendanceHistory: attendanceData,
                quizGradeHistory: gradesData,
              ),
            );
          },
        );
      },
    );
  }

  // Public method to allow extensions to emit states
  void emitState(StoredDataState newState) {
    if (!isClosed) emit(newState);
  }
}
