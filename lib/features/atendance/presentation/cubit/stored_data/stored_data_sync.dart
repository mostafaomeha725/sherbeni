part of 'stored_data_cubit.dart';

extension StoredDataSync on StoredDataCubit {
  Future<void> retrySync() async {
    if (state is! StoredDataLoaded) return;

    final currentState = state as StoredDataLoaded;

    final retryableAttendance = currentState.attendanceHistory
        .where(
          (e) => e.syncStatus == 'failed' || e.syncStatus == 'pending',
        )
        .toList();

    final retryableGrades = currentState.quizGradeHistory
        .where(
          (e) => e.syncStatus == 'failed' || e.syncStatus == 'pending',
        )
        .toList();

    if (retryableAttendance.isEmpty && retryableGrades.isEmpty) {
      EasyLoading.showInfo("لا توجد بيانات تحتاج إلى إعادة مزامنة");
      return;
    }

    emitState(
      StoredDataSyncing(
        attendanceHistory: currentState.attendanceHistory,
        quizGradeHistory: currentState.quizGradeHistory,
      ),
    );

    EasyLoading.show(status: 'جاري محاولة المزامنة...');

    bool hasErrors = false;
    String? offlineMessage;

    int? validCount;
    int? invalidCount;
    List<Map<String, dynamic>> invalidRecords = [];

    // Retry Attendance Records (ONE BULK REQUEST)
    final attendanceResult = await retryAllOfflineAttendanceUseCase.call();
    attendanceResult.fold(
      (l) {
        hasErrors = true;
        if (l.message.contains('لا يوجد اتصال') ||
            l.message.contains('سيتم الاحتفاظ') ||
            l.message.contains('تم حفظ البيانات وسيتم رفعها تلقائيًا')) {
          offlineMessage = l.message;
        }
      },
      (r) {
        if (r['data'] != null) {
          final data = r['data'];
          validCount = data['valid_results'] as int?;
          final invalidList = data['invalid_results'] as List? ?? [];
          invalidCount = invalidList.length;

          for (var item in invalidList) {
            if (item is Map) {
              final uid = item['student_id']?.toString() ?? '';
              final reason = item['reason']?.toString() ?? 'Invalid data';
              // Find student name from retryable records
              String studentName = 'مجهول';
              try {
                final match = retryableAttendance.firstWhere(
                  (e) => e.uid == uid,
                );
                studentName = match.studentName;
              } catch (_) {}

              invalidRecords.add({'name': studentName, 'reason': reason});
            }
          }
        }
      },
    );

    // Retry Quiz Grades
    if (retryableGrades.isNotEmpty) {
      // Existing Quiz Grade retry rule is just the global sync use case
      final result = await syncOfflineDataUseCase.call();
      result.fold((l) {
        hasErrors = true;
        if (l.message.contains('لا يوجد اتصال') ||
            l.message.contains('سيتم الاحتفاظ') ||
            l.message.contains('تم حفظ البيانات وسيتم رفعها تلقائيًا')) {
          offlineMessage = l.message;
        }
      }, (r) {});
    }

    EasyLoading.dismiss();

    await loadHistory();

    if (validCount != null && (validCount! > 0 || invalidCount! > 0)) {
      emitState(
        StoredDataBulkSyncResult(
          validCount: validCount!,
          invalidCount: invalidCount!,
          invalidRecords: invalidRecords,
          attendanceHistory: currentState.attendanceHistory,
          quizGradeHistory: currentState.quizGradeHistory,
        ),
      );
    } else if (offlineMessage != null) {
      EasyLoading.showInfo(
        "لا يوجد اتصال بالإنترنت، تم حفظ البيانات وسيتم رفعها تلقائيًا عند عودة الاتصال.",
        duration: const Duration(seconds: 4),
      );
    } else if (hasErrors) {
      EasyLoading.showError(
        "بعض السجلات لم تنجح في المزامنة. يرجى مراجعة الحالات.",
      );
    } else {
      EasyLoading.showSuccess("اكتملت محاولة المزامنة");
    }
  }

  Future<void> retryAttendance(String pendingKey) async {
    if (state is! StoredDataLoaded) return;

    EasyLoading.show(status: 'جاري محاولة المزامنة...');

    final result = await retrySpecificOfflineAttendanceUseCase.call(pendingKey);

    EasyLoading.dismiss();
    result.fold(
      (l) {
        EasyLoading.showError(l.message);
        loadHistory();
      },
      (r) {
        EasyLoading.showSuccess("تمت مزامنة الطالب بنجاح");
        loadHistory();
      },
    );
  }

  Future<void> retryQuizGrade(String pendingKey) async {
    if (state is! StoredDataLoaded) return;

    final hasInternet = await NetworkService.hasInternetReachability();
    if (!hasInternet) {
      EasyLoading.showError("لا يوجد اتصال بالإنترنت");
      return;
    }

    EasyLoading.show(status: 'جاري محاولة المزامنة...');

    // We reuse the existing bulk sync which will pick up the pending record
    // from the queue automatically if it's there.
    final result = await syncOfflineDataUseCase.call();

    EasyLoading.dismiss();
    result.fold(
      (l) {
        EasyLoading.showError(l.message);
        loadHistory();
      },
      (r) {
        EasyLoading.showSuccess("اكتملت محاولة المزامنة");
        loadHistory();
      },
    );
  }
}

