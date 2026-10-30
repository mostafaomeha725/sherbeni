part of 'stored_data_cubit.dart';

extension StoredDataDelete on StoredDataCubit {
  Future<void> deleteAttendance(String pendingKey) async {
    await deleteHistoryRecordUseCase.deleteAttendance(pendingKey);
    await loadHistory();
  }

  Future<void> deleteQuizGrade(String pendingKey) async {
    await deleteHistoryRecordUseCase.deleteQuizGrade(pendingKey);
    await loadHistory();
  }

  Future<void> deleteAllHistory() async {
    await deleteHistoryRecordUseCase.clearAllAttendance();
    await deleteHistoryRecordUseCase.clearAllQuizGrades();
    await loadHistory();
  }
}
