import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:qrattendance/core/models/pagination_model.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_attendance_entity.dart';
import 'package:qrattendance/features/atendance/data/model/session_attendance_model.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_session_attendances_use_case.dart';
import 'package:qrattendance/core/network/network_service.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_offline_session_attendances_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/delete_session_attendance_use_case.dart';
import 'session_students_excel_exporter.dart';

part 'session_students_state.dart';

class SessionStudentsCubit extends Cubit<SessionStudentsState> {
  final GetSessionAttendancesUseCase getSessionAttendancesUseCase;
  final GetOfflineSessionAttendancesUseCase getOfflineSessionAttendancesUseCase;
  final Connectivity connectivity;
  final DeleteSessionAttendanceUseCase? deleteSessionAttendanceUseCase;

  int _currentPage = 1;
  final int _limit = 10;

  SessionStudentsCubit(
    this.getSessionAttendancesUseCase,
    this.getOfflineSessionAttendancesUseCase,
    this.connectivity, [
    this.deleteSessionAttendanceUseCase,
  ]) : super(SessionStudentsInitial());

  Future<void> fetchStudents(String sessionId, {bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
    }

    if (_currentPage == 1) {
      emit(SessionStudentsLoading());
    } else {
      if (state is SessionStudentsLoaded) {
        emit((state as SessionStudentsLoaded).copyWith(isFetchingMore: true));
      }
    }

    final connectivityResult = await connectivity.checkConnectivity();
    bool isOffline = connectivityResult.contains(ConnectivityResult.none);
    if (!isOffline) {
      isOffline = !(await NetworkService.hasInternetReachability());
    }

    if (isOffline) {
      // Offline mode
      final result = await getOfflineSessionAttendancesUseCase.call(sessionId);
      result.fold(
        (failure) {
          if (isClosed) return;
          emit(SessionStudentsFailure(failure.message));
        },
        (attendances) {
          if (isClosed) return;
          emit(
            SessionStudentsLoaded(
              attendances: attendances,
              pagination: null,
              isOffline: true,
            ),
          );
        },
      );
    } else {
      // Online mode
      final result = await getSessionAttendancesUseCase.call(
        sessionId,
        _currentPage,
        _limit,
      );
      result.fold(
        (failure) {
          if (isClosed) return;
          emit(SessionStudentsFailure(failure.message));
        },
        (data) {
          if (isClosed) return;
          final List dynamicList = data['data']['attendances'] ?? [];
          final newAttendances = dynamicList
              .map((e) => SessionAttendanceModel.fromJson(e))
              .toList();

          PaginationModel? pagination;
          if (data['pagination'] != null) {
            pagination = PaginationModel.fromJson(data['pagination']);
          }

          if (_currentPage == 1) {
            emit(
              SessionStudentsLoaded(
                attendances: newAttendances,
                pagination: pagination,
              ),
            );
          } else {
            if (state is SessionStudentsLoaded) {
              final currentList = (state as SessionStudentsLoaded).attendances;
              emit(
                SessionStudentsLoaded(
                  attendances: [...currentList, ...newAttendances],
                  pagination: pagination,
                ),
              );
            }
          }
        },
      );
    }
  }

  void fetchNextPage(String sessionId) {
    if (state is SessionStudentsLoaded) {
      final currentState = state as SessionStudentsLoaded;
      if (currentState.isFetchingMore) return;

      final pagination = currentState.pagination;
      if (pagination != null && pagination.hasNextPage) {
        _currentPage++;
        fetchStudents(sessionId);
      }
    }
  }

  Future<void> deleteAttendance({
    required String sessionId,
    required String attendanceId,
  }) async {
    if (state is! SessionStudentsLoaded) return;
    final currentState = state as SessionStudentsLoaded;

    if (deleteSessionAttendanceUseCase == null) {
      try {
        await EasyLoading.showError('تعذر العثور على خدمة الحذف');
      } catch (_) {}
      return;
    }

    try {
      await EasyLoading.show(status: 'جاري حذف الحضور...');
    } catch (_) {}

    final result = await deleteSessionAttendanceUseCase!.call(
      sessionId: sessionId,
      attendanceId: attendanceId,
    );

    await result.fold(
      (failure) async {
        try {
          await EasyLoading.dismiss();
          await EasyLoading.showError(failure.message);
        } catch (_) {}
      },
      (successMessage) async {
        try {
          await EasyLoading.dismiss();
          await EasyLoading.showSuccess(successMessage);
        } catch (_) {}

        final updatedAttendances = currentState.attendances
            .where((item) => item.attendanceId != attendanceId)
            .toList();

        PaginationModel? updatedPagination = currentState.pagination;
        if (updatedPagination != null) {
          final newTotal = (updatedPagination.totalItems - 1).clamp(0, 999999);
          updatedPagination = updatedPagination.copyWith(totalItems: newTotal);
        }

        emit(
          currentState.copyWith(
            attendances: updatedAttendances,
            pagination: updatedPagination,
          ),
        );
      },
    );
  }

  Future<void> exportToExcel(String sessionName, String sessionId) async {
    if (state is! SessionStudentsLoaded) return;
    final currentState = state as SessionStudentsLoaded;

    try {
      EasyLoading.show(status: 'جاري جمع بيانات الطلبة بالكامل...');

      List<SessionAttendanceEntity> allAttendances = [];

      final isOfflineResult = await connectivity.checkConnectivity();
      bool isOffline = isOfflineResult.contains(ConnectivityResult.none);
      if (!isOffline) {
        isOffline = !(await NetworkService.hasInternetReachability());
      }

      if (isOffline) {
        final result = await getOfflineSessionAttendancesUseCase.call(
          sessionId,
        );
        result.fold(
          (failure) => allAttendances = currentState.attendances,
          (data) => allAttendances = data,
        );
      } else {
        final result = await getSessionAttendancesUseCase.call(
          sessionId,
          1,
          100000,
        );
        result.fold(
          (failure) => allAttendances = currentState.attendances,
          (data) {
            final List dynamicList = data['data']['attendances'] ?? [];
            allAttendances = dynamicList
                .map((e) => SessionAttendanceModel.fromJson(e))
                .toList();
          },
        );
      }

      if (allAttendances.isEmpty) {
        allAttendances = currentState.attendances;
      }

      if (allAttendances.isEmpty) {
        EasyLoading.dismiss();
        EasyLoading.showInfo('لا يوجد طلبة لاستخراجهم');
        return;
      }

      await SessionStudentsExcelExporter.export(
        sessionName: sessionName,
        allAttendances: allAttendances,
      );
    } catch (e) {
      EasyLoading.showError('فشل في استخراج الملف: $e');
    }
  }
}
