import 'package:qrattendance/core/cache/preferences_storage.dart';
import 'package:qrattendance/core/network/network_service.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Auth
import 'package:qrattendance/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:qrattendance/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:qrattendance/features/auth/domain/repositories/auth_repository.dart';
import 'package:qrattendance/features/auth/domain/use_cases/login_use_case.dart';
import 'package:qrattendance/features/auth/presentation/cubit/login_cubit/login_cubit.dart';

// Attendance
import 'package:qrattendance/features/atendance/data/data_sources/attendance_local_data_source.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_remote_data_source.dart';
import 'package:qrattendance/features/atendance/data/repositories/attendance_repository_impl.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_sessions_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_student_data_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/save_offline_attendance_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/sync_offline_data_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/scan_online_attendance_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/record_online_attendance_use_case.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/record_online_attendance/record_online_attendance_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/scan_qr_offline/scan_qr_ofline_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/show_classes/show_classes_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/show_sessions/show_sessions_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/show_student_data/show_student_data_cubit.dart';

import 'package:qrattendance/features/atendance/domain/use_cases/get_session_attendances_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_offline_session_attendances_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_quiz_students_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/check_session_quizzes_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/update_quiz_grade_use_case.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/session_students/session_students_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/quiz_grades/quiz_grades_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/check_session_quizzes/check_session_quizzes_cubit.dart';

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
  }

  Future<void> _initStorage() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton(() => sharedPreferences);
    sl.registerLazySingleton(() => PreferencesStorage(sl()));
  }

  void _initDio() {
    sl.registerLazySingleton(() => Dio());
    sl.registerLazySingleton(() => NetworkService(sl()));
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

    // Cubits (Factory)
    sl.registerFactory(() => LoginCubit(sl()));
  }

  void _initAttendance() {
    // Data Sources
    sl.registerLazySingleton<AttendanceLocalDataSource>(
      () => AttendanceLocalDataSourceImpl(),
    );
    sl.registerLazySingleton<AttendanceRemoteDataSource>(
      () => AttendanceRemoteDataSourceImpl(sl()),
    );

    // Repository
    sl.registerLazySingleton<AttendanceRepository>(
      () => AttendanceRepositoryImpl(
        localDataSource: sl(),
        remoteDataSource: sl(),
        connectivity: sl(),
      ),
    );

    // UseCases
    sl.registerLazySingleton(() => GetSessionsUseCase(sl()));
    sl.registerLazySingleton(() => GetStudentDataUseCase(sl()));
    sl.registerLazySingleton(() => SaveOfflineAttendanceUseCase(sl()));
    sl.registerLazySingleton(() => SyncOfflineDataUseCase(sl()));
    sl.registerLazySingleton(() => ScanOnlineAttendanceUseCase(sl()));
    sl.registerLazySingleton(() => RecordOnlineAttendanceUseCase(sl()));
    sl.registerLazySingleton(() => GetSessionAttendancesUseCase(sl()));
    sl.registerLazySingleton(() => GetOfflineSessionAttendancesUseCase(sl()));
    sl.registerLazySingleton(() => GetQuizStudentsUseCase(sl()));
    sl.registerLazySingleton(() => GetCachedQuizStudentsUseCase(sl()));
    sl.registerLazySingleton(() => CheckSessionQuizzesUseCase(sl()));
    sl.registerLazySingleton(() => UpdateQuizGradeUseCase(sl()));

    // Cubits (Factory)
    sl.registerFactory(() => ScanQrOflineCubit(sl(), sl()));
    sl.registerFactory(() => ShowSessionsCubit(sl()));
    sl.registerFactory(() => ShowClassesCubit(sl()));
    sl.registerFactory(() => ShowStudentDataCubit(sl(), sl()));
    sl.registerFactory(() => RecordOnlineAttendanceCubit(sl()));
    sl.registerFactory(() => SessionStudentsCubit(sl(), sl(), sl()));
    sl.registerFactory(() => QuizGradesCubit(sl(), sl(), sl()));
    sl.registerFactory(() => CheckSessionQuizzesCubit(sl()));
  }
}
