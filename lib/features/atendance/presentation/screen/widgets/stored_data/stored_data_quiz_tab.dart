import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/stored_data/stored_data_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/quiz_grades/collapsible_quiz_card.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/sessions/session_group_card.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/stored_data/stored_data_dialogs.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/stored_data/stored_data_utils.dart';

class StoredDataQuizTab extends StatelessWidget {
  final List gradesList;
  final String searchQuery;

  const StoredDataQuizTab({
    super.key,
    required this.gradesList,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final filteredList = searchQuery.isEmpty
        ? gradesList
        : gradesList.where((item) {
            final session = StoredDataUtils.getValidSessionName(
              item.sessionName,
            ).toLowerCase();
            return session.contains(searchQuery);
          }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 60.sp,
              color: Colors.grey.withOpacity(0.5),
            ),
            SizedBox(height: 16.h),
            AppText(
              'لا يوجد درجات كويز مخزنة',
              style: font16w500.copyWith(color: Colors.grey),
              alignment: AlignmentDirectional.center,
            ),
          ],
        ),
      );
    }
    // Group by session name
    final grouped = <String, List<dynamic>>{};
    for (var item in filteredList) {
      final session = StoredDataUtils.getValidSessionName(item.sessionName);
      if (!grouped.containsKey(session)) {
        grouped[session] = [];
      }
      grouped[session]!.add(item);
    }
    final sessionNames = grouped.keys.toList();

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: sessionNames.length,
      itemBuilder: (context, index) {
        final session = sessionNames[index];
        final items = grouped[session]!;

        return SessionGroupCard(
          sessionName: session,
          type: 'quiz',
          items: items,
          itemBuilder: (context, item) {
            return CollapsibleQuizCard(
              item: item,
              sessionName: StoredDataUtils.getValidSessionName(
                item.sessionName,
              ),
              quizName: StoredDataUtils.getValidQuizName(item.quizName),
              statusBadge: StoredDataUtils.buildStatusBadge(item.syncStatus),
              onRetry:
                  item.syncStatus == 'failed' || item.syncStatus == 'pending'
                  ? () => context.read<StoredDataCubit>().retryQuizGrade(
                      item.pendingKey,
                    )
                  : null,
              onDelete: () => StoredDataDialogs.showDeleteBottomSheet(
                context,
                'حذف السجل',
                'هل أنت متأكد من حذف هذا السجل؟ إذا لم تتم مزامنته بعد فسيتم حذفه نهائياً.',
                () => context.read<StoredDataCubit>().deleteQuizGrade(
                  item.pendingKey,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
