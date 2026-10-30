import 'package:qrattendance/core/cache/preferences_storage.dart';
import 'package:qrattendance/core/network/network_service.dart';
import 'package:qrattendance/core/network/token_refresh_service.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Auth
import 'package:qrattendance/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:qrattendance/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:qrattendance/features/auth/domain/repositories/auth_repository.dart';
import 'package:qrattendance/features/auth/domain/use_cases/login_use_case.dart';
import 'package:qrattendance/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:qrattendance/features/auth/presentation/cubit/login_cubit/login_cubit.dart';
import 'package:qrattendance/features/auth/presentation/cubit/logout_cubit/logout_cubit.dart';

// Attendance
import 'package:qrattendance/features/atendance/data/data_sources/attendance_local_data_source.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_remote_data_source.dart';
import 'package:qrattendance/features/atendance/data/repositories/attendance_repository_impl.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';
import 'package:qrattendance/features/atendance/data/data_sources/history_local_data_source.dart';
import 'package:qrattendance/features/atendance/data/repositories/history_repository_impl.dart';
import 'package:qrattendance/features/atendance/domain/repositories/history_repository.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_sessions_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_student_data_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/save_offline_attendance_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/save_offline_search_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/retry_specific_offline_attendance_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/retry_all_offline_attendance_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/sync_offline_data_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/scan_online_attendance_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/record_online_attendance_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_attendance_history_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_quiz_grade_history_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/delete_history_record_use_case.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/record_online_attendance/record_online_attendance_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/scan_qr_offline/scan_qr_ofline_cubit.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_academic_classes_use_case.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/academic_classes/academic_classes_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/show_classes/show_classes_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/show_sessions/show_sessions_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/show_student_data/show_student_data_cubit.dart';

import 'package:qrattendance/features/atendance/domain/use_cases/get_session_attendances_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_offline_session_attendances_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/delete_session_attendance_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_quiz_students_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_homework_students_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/check_session_quizzes_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/update_quiz_grade_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/update_homework_grade_use_case.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/session_students/session_students_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/quiz_grades/quiz_grades_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/homework_grades/homework_grades_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/update_homework_grade/update_homework_grade_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/check_session_quizzes/check_session_quizzes_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/stored_data/stored_data_cubit.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/search_student_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/bulk_search_students_use_case.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/manual_attendance/manual_attendance_cubit.dart';

import 'package:qrattendance/core/services/global_sync_coordinator.dart';

final sl = GetIt.instance;

class ServiceLocator {
  Future<void> initDependencies() async {
    await _initCore();
    _initAuth();
    _initAttendance();
  }

  Future<void> _initCore() async {
    await _initStorage();
    _initDio();
    sl.registerLazySingleton(() => Connectivity());
    sl.registerLazySingleton(
      () => GlobalSyncCoordinator(
        syncOfflineDataUseCase: sl(),
        localDataSource: sl(),
        connectivity: sl(),
      ),
    );
  }

  Future<void> _initStorage() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton(() => sharedPreferences);
    sl.registerLazySingleton(() => PreferencesStorage(sl()));
  }

  void _initDio() {
    sl.registerLazySingleton(() => Dio());
    sl.registerLazySingleton(() => NetworkService(sl()));
    sl.registerLazySingleton(() => TokenRefreshService(sl()));
  }

  void _initAuth() {
    // Data Sources
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl()),
    );

    // Repository
    sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

    // UseCases
    sl.registerLazySingleton(() => LoginUseCase(sl()));
    sl.registerLazySingleton(() => LogoutUseCase(sl()));

    // Cubits (Factory)
    sl.registerFactory(() => LoginCubit(sl()));
    sl.registerFactory(() => LogoutCubit(sl()));
  }

  void _initAttendance() {
    // Data Sources
    sl.registerLazySingleton<AttendanceLocalDataSource>(
      () => AttendanceLocalDataSourceImpl(),
    );
    sl.registerLazySingleton<AttendanceRemoteDataSource>(
      () => AttendanceRemoteDataSourceImpl(sl()),
    );
    sl.registerLazySingleton<HistoryLocalDataSource>(
      () => HistoryLocalDataSourceImpl(),
    );

    // Repository
    sl.registerLazySingleton<HistoryRepository>(
      () => HistoryRepositoryImpl(localDataSource: sl()),
    );
    sl.registerLazySingleton<AttendanceRepository>(
      () => AttendanceRepositoryImpl(
        localDataSource: sl(),
        remoteDataSource: sl(),
        connectivity: sl(),
        historyLocalDataSource: sl(),
      ),
    );

    // UseCases
    sl.registerLazySingleton(() => GetSessionsUseCase(sl()));
    sl.registerLazySingleton(() => GetAcademicClassesUseCase(sl()));
    sl.registerLazySingleton(() => GetStudentDataUseCase(sl()));
    sl.registerLazySingleton(() => SaveOfflineAttendanceUseCase(sl()));
    sl.registerLazySingleton(() => SaveOfflineSearchUseCase(sl()));
    sl.registerLazySingleton(() => SyncOfflineDataUseCase(sl()));
    sl.registerLazySingleton(() => ScanOnlineAttendanceUseCase(sl()));
    sl.registerLazySingleton(() => RecordOnlineAttendanceUseCase(sl()));
    sl.registerLazySingleton(() => GetSessionAttendancesUseCase(sl()));
    sl.registerLazySingleton(() => GetOfflineSessionAttendancesUseCase(sl()));
    sl.registerLazySingleton(() => DeleteSessionAttendanceUseCase(sl()));
    sl.registerLazySingleton(() => GetQuizStudentsUseCase(sl()));
    sl.registerLazySingleton(() => GetCachedQuizStudentsUseCase(sl()));
    sl.registerLazySingleton(() => GetHomeworkStudentsUseCase(sl()));
    sl.registerLazySingleton(() => GetCachedHomeworkStudentsUseCase(sl()));
    sl.registerLazySingleton(() => CheckSessionQuizzesUseCase(sl()));
    sl.registerLazySingleton(() => UpdateQuizGradeUseCase(sl()));
    sl.registerLazySingleton(() => UpdateHomeworkGradeUseCase(sl()));
    sl.registerLazySingleton(() => GetAttendanceHistoryUseCase(sl()));
    sl.registerLazySingleton(() => GetQuizGradeHistoryUseCase(sl()));
    sl.registerLazySingleton(() => DeleteHistoryRecordUseCase(sl()));
    sl.registerLazySingleton(() => RetrySpecificOfflineAttendanceUseCase(sl()));
    sl.registerLazySingleton(() => RetryAllOfflineAttendanceUseCase(sl()));
    sl.registerLazySingleton(() => SearchStudentUseCase(sl()));
    sl.registerLazySingleton(() => BulkSearchStudentsUseCase(sl()));

    // Cubits (Factory)
    sl.registerFactory(() => ScanQrOflineCubit(sl(), sl()));
    sl.registerFactory(() => ShowSessionsCubit(sl()));
    sl.registerFactory(() => AcademicClassesCubit(sl()));
    sl.registerFactory(() => ShowClassesCubit(sl()));
    sl.registerFactory(() => ShowStudentDataCubit(sl(), sl()));
    sl.registerFactory(() => RecordOnlineAttendanceCubit(sl()));
    sl.registerFactory(() => SessionStudentsCubit(sl(), sl(), sl(), sl()));
    sl.registerFactory(() => QuizGradesCubit(sl(), sl(), sl()));
    sl.registerFactory(() => HomeworkGradesCubit(sl(), sl(), sl()));
    sl.registerFactory(() => UpdateHomeworkGradeCubit(sl()));
    sl.registerFactory(() => CheckSessionQuizzesCubit(sl()));
    sl.registerFactory(
      () => StoredDataCubit(
        getAttendanceHistoryUseCase: sl(),
        getQuizGradeHistoryUseCase: sl(),
        deleteHistoryRecordUseCase: sl(),
        syncOfflineDataUseCase: sl(),
        retrySpecificOfflineAttendanceUseCase: sl(),
        retryAllOfflineAttendanceUseCase: sl(),
      ),
    );
    sl.registerFactory(
      () => ManualAttendanceCubit(
        searchStudentUseCase: sl(),
        bulkSearchStudentsUseCase: sl(),
        recordOnlineAttendanceUseCase: sl(),
        saveOfflineAttendanceUseCase: sl(),
        saveOfflineSearchUseCase: sl(),
      ),
    );
  }
}
