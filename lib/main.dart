import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:qrattendance/core/app/app.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/features/atendance/data/model/attendance_model.dart';
import 'package:qrattendance/features/atendance/data/model/session_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:qrattendance/features/atendance/data/model/student_model.dart';
import 'package:qrattendance/features/atendance/data/model/pending_quiz_grade_model.dart';
import 'package:qrattendance/features/atendance/data/model/pending_homework_grade_model.dart';
import 'package:qrattendance/features/atendance/data/model/academic_class_model.dart';
import 'package:qrattendance/features/atendance/data/model/attendance_history_model.dart';
import 'package:qrattendance/features/atendance/data/model/quiz_grade_history_model.dart';
import 'package:qrattendance/features/atendance/data/model/pending_search_model.dart';
import 'package:qrattendance/features/atendance/domain/repositories/history_repository.dart';

import 'package:qrattendance/core/services/global_sync_coordinator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dependency Injection
  await ServiceLocator().initDependencies();

  // Hive Initialization
  await Hive.initFlutter();
  Hive.registerAdapter(AttendanceModelAdapter());
  Hive.registerAdapter(SessionModelAdapter());
  Hive.registerAdapter(StudentModelAdapter());
  Hive.registerAdapter(PendingQuizGradeModelAdapter());
  Hive.registerAdapter(PendingHomeworkGradeModelAdapter());
  Hive.registerAdapter(AcademicClassModelAdapter());
  Hive.registerAdapter(AttendanceHistoryModelAdapter());
  Hive.registerAdapter(QuizGradeHistoryModelAdapter());
  Hive.registerAdapter(PendingSearchModelAdapter());

  // Open Boxes
  await Hive.openBox<AttendanceModel>('studentSessions');
  await Hive.openBox<StudentModel>('students');
  await Hive.openBox<PendingQuizGradeModel>('pendingQuizGrades');
  await Hive.openBox<PendingHomeworkGradeModel>('pendingHomeworkGrades');
  await Hive.openBox<AcademicClassModel>('academicClasses');
  await Hive.openBox<PendingSearchModel>('pendingSearches');

  // Initialize Global Sync
  sl<GlobalSyncCoordinator>().init();

  // Run cleanup for old history records silently
  sl<HistoryRepository>().cleanupOldHistory();

  configLoading();

  runApp(const MathmagicianApp());
}

void configLoading() {
  EasyLoading.instance
    ..userInteractions = false
    ..dismissOnTap = false;
}
