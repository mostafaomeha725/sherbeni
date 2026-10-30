import 'package:qrattendance/features/atendance/data/model/attendance_model.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_offline_base_mixin.dart';
import 'package:intl/intl.dart';
import 'package:qrattendance/features/atendance/data/model/pending_homework_grade_model.dart';

mixin AttendanceOfflineSearchSyncMixin on AttendanceOfflineBaseMixin {
  Future<void> syncPendingSearches() async {
    final pendingSearches = await localDataSource.getPendingSearches();
    if (pendingSearches.isEmpty) return;

    print('PENDING_SEARCHES_FOUND:\ncount=${pendingSearches.length}');

    final queries = pendingSearches.map((e) => e.searchValue).toList();

    try {
      print('BULK_SEARCH_START:\ncount=${queries.length}');
      final rawDataList = await remoteDataSource.bulkSearchStudents(queries);

      final Map<String, dynamic> responseMap = {};
      for (final item in rawDataList) {
        final searchString = item['search']?.toString().trim();
        if (searchString != null) {
          responseMap[searchString] = item;
        }
      }

      final List<String> toDelete = [];

      int successCount = 0;
      int failedCount = 0;

      for (final pending in pendingSearches) {
        final result = responseMap[pending.searchValue.trim()];

        if (result != null) {
          final data = result['data'];
          if (data != null) {
            // Successfully found
            final studentId = data['studentId'] ?? data['student_id'];
            if (studentId != null) {
              final attendanceModel = AttendanceModel(
                uid: studentId.toString(),
                sessionId: pending.sessionId,
                scanTime: DateFormat(
                  'yyyy-MM-dd HH:mm:ss',
                  'en_US',
                ).format(DateTime.now()),
              );
              // Save to offline attendance queue so the syncAttendances() will pick it up
              await localDataSource.saveOfflineAttendance(attendanceModel);

              // Link offline homework grade if it exists
              final pendingHomeworks = await localDataSource
                  .getPendingHomeworkGrades();
              for (final hw in pendingHomeworks) {
                if (hw.studentId == pending.pendingKey) {
                  final updatedHw = PendingHomeworkGradeModel(
                    homeworkAttemptId: hw.homeworkAttemptId,
                    studentId: studentId.toString(),
                    sessionId: hw.sessionId,
                    homeworkTemplateId: hw.homeworkTemplateId,
                    grade: hw.grade,
                    error: hw.error,
                  );
                  await localDataSource.savePendingHomeworkGrade(updatedHw);
                  print(
                    'OFFLINE_HOMEWORK_MAPPING:\nsearch=${pending.searchValue.trim()}\npendingKey=${pending.pendingKey}\nstudentId=$studentId',
                  );
                  await hw.delete();
                }
              }

              successCount++;
            } else {
              failedCount++;
            }
          } else {
            failedCount++;
          }
        } else {
          // Missing from valid response means not found by backend
          failedCount++;
        }

        // Either found or not found, we delete the search model.
        toDelete.add(pending.pendingKey);
      }

      print(
        'BULK_SEARCH_RESULT:\nrequested=${pendingSearches.length}\nfound=$successCount\nnotFound=$failedCount',
      );

      if (toDelete.isNotEmpty) {
        await localDataSource.deletePendingSearches(toDelete);
      }
    } catch (e) {
      // If network error, leave them as pending
    }
  }
}
