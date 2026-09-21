// import 'package:go_router/go_router.dart';
// import 'package:flutter/material.dart';
// import 'package:qrattendance/features/atendance/data/model/session_model.dart';
// import 'package:qrattendance/features/atendance/presentation/screen/attendance_screen.dart';
// import 'package:qrattendance/features/atendance/presentation/screen/scan_qr_screen.dart';

// import 'package:qrattendance/features/auth/presentation/screen/login_screen.dart';
// import 'package:qrattendance/main.dart';
// import 'route_paths.dart'; // ملف يحتوي على المسارات الثابتة

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// final GoRouter appRouter = GoRouter(
//   initialLocation: '/',
//   navigatorKey: navigatorKey,
//   debugLogDiagnostics: true,
//   routes: [
//     GoRoute(path: '/', builder: (context, state) => const AuthRedirect()),
//     GoRoute(
//       path: Routes.loginScreen,
//       builder: (context, state) => const LoginScreen(),
//     ),
//     GoRoute(
//       path: Routes.attendanceScreen,
//       builder: (context, state) {
//         final studentId = state.extra as String;
//         return AttendanceScreen(studentId: studentId);
//       },
//     ),
//     GoRoute(
//       path: Routes.scanQrScreen,
//       builder: (context, state) {
//         final session =
//             state.extra as SessionModel; // استبدل SessionModel بنوعك الفعلي
//         return ScanQrScreen(session: session);
//       },
//     ),
//   ],
// );
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:qrattendance/core/routes/auth_redirect.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/domain/entities/academic_class_entity.dart';
import 'package:qrattendance/features/atendance/presentation/screen/academic_classes_screen.dart';
import 'package:qrattendance/features/atendance/presentation/screen/attendance_screen.dart';
import 'package:qrattendance/features/atendance/presentation/screen/quiz_grades_screen.dart';
import 'package:qrattendance/features/atendance/presentation/screen/select_class_screen.dart';
import 'package:qrattendance/features/atendance/presentation/screen/scan_qr_screen.dart';

import 'package:qrattendance/features/auth/presentation/screen/login_screen.dart';

import 'route_paths.dart'; // ملف يحتوي على المسارات الثابتة

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  navigatorKey: navigatorKey,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthRedirect()),

    GoRoute(
      path: Routes.loginScreen,
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: Routes.academicClassesScreen,
      builder: (context, state) {
        final token = state.extra as String;
        return AcademicClassesScreen(token: token);
      },
    ),

    GoRoute(
      path: Routes.attendanceScreen,
      builder: (context, state) {
        String token = '';
        AcademicClassEntity? academicClass;

        if (state.extra is String) {
          token = state.extra as String;
        } else if (state.extra is Map) {
          final map = state.extra as Map;
          token = map['token'] as String? ?? '';
          academicClass = map['academicClass'] as AcademicClassEntity?;
        }

        if (academicClass == null) {
          return AcademicClassesScreen(token: token);
        }

        return AttendanceScreen(token: token, academicClass: academicClass);
      },
    ),

    GoRoute(
      path: Routes.selectClassScreen,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final subject = extra['subject'] as SessionEntity;
        final classId = extra['classId'] as String;
        return SelectClassScreen(subject: subject, classId: classId);
      },
    ),

    GoRoute(
      path: Routes.scanQrScreen,
      builder: (context, state) {
        final session = state.extra as SessionEntity;
        return ScanQrScreen(session: session);
      },
    ),
    GoRoute(
      path: Routes.quizGradesScreen,
      builder: (context, state) {
        // Can accept SessionEntity directly or inside a Map
        final session = state.extra is Map
            ? (state.extra as Map)['session'] as SessionEntity
            : state.extra as SessionEntity;

        return QuizGradesScreen(session: session);
      },
    ),
  ],
);
