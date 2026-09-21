import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:qrattendance/core/routes/route_paths.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/session_card.dart';

class ShowSessionsListWidget extends StatelessWidget {
  final List<SessionEntity> sessions;
  final String classId;

  const ShowSessionsListWidget({
    super.key,
    required this.sessions,
    required this.classId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 24.h),
      itemCount: sessions.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final session = sessions[index];
        return SessionCard(
          session: session,
          onTap: () {
            GoRouter.of(context).push(
              Routes.selectClassScreen,
              extra: {'subject': session, 'classId': classId},
            );
          },
        );
      },
    );
  }
}
