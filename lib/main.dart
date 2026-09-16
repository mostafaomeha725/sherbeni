import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:qrattendance/core/app/app.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/features/atendance/data/model/attendance_model.dart';
import 'package:qrattendance/features/atendance/data/model/session_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:qrattendance/features/atendance/data/model/student_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Dependency Injection
  await ServiceLocator().initDependencies();
  
  // Hive Initialization
  await Hive.initFlutter();
  Hive.registerAdapter(AttendanceModelAdapter());
  Hive.registerAdapter(SessionModelAdapter());
  Hive.registerAdapter(StudentModelAdapter());
  
  // Open Boxes
  await Hive.openBox<AttendanceModel>('studentSessions');
  await Hive.openBox<SessionModel>('sessions');
  await Hive.openBox<StudentModel>('students');
  
  configLoading();

  runApp(const MathmagicianApp());
}

void configLoading() {
  EasyLoading.instance
    ..userInteractions = false
    ..dismissOnTap = false;
}
