import 'package:bloc/bloc.dart';
import 'package:qrattendance/features/atendance/data/model/homework_student_model.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_homework_students_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/update_homework_grade_use_case.dart';
import 'homework_grades_state.dart';

class HomeworkGradesCubit extends Cubit<HomeworkGradesState> {
  final GetHomeworkStudentsUseCase getHomeworkStudentsUseCase;
  final GetCachedHomeworkStudentsUseCase getCachedHomeworkStudentsUseCase;
  final UpdateHomeworkGradeUseCase updateHomeworkGradeUseCase;

  HomeworkGradesCubit(
    this.getHomeworkStudentsUseCase,
    this.getCachedHomeworkStudentsUseCase,
    this.updateHomeworkGradeUseCase,
  ) : super(HomeworkGradesInitial());

  String _currentSessionId = '';

  Future<void> fetchStudents(String sessionId, {bool isRefresh = false}) async {
    _currentSessionId = sessionId;

    emit(HomeworkGradesLoading());

    // 1. Check local cache (default query)
    bool hasCache = false;
    final cacheResult = await getCachedHomeworkStudentsUseCase.call(sessionId);

    cacheResult.fold((_) {}, (data) {
      if (data != null &&
          data['data'] != null &&
          data['data']['grades'] != null) {
        hasCache = true;
        final students = (data['data']['grades'] as List)
            .map((e) => HomeworkStudentModel.fromJson(e))
            .toList();

        final homeworkName = data['data']['homework_name']?.toString();
        final maxScore = data['data']['max_score'] as num?;

        emit(
          HomeworkGradesLoaded(
            students: students,
            pagination: null,
            isOffline:
                true, // we assume it might be offline, will update if online success
            homeworkName: homeworkName,
            maxScore: maxScore,
          ),
        );
      }
    });

    // 2. Fetch from API
    final result = await getHomeworkStudentsUseCase.call(sessionId);

    result.fold(
      (failure) {
        if (!hasCache) {
          emit(HomeworkGradesError(failure.message));
        }
      },
      (data) {
        final newStudents = (data['data']['grades'] as List)
            .map((e) => HomeworkStudentModel.fromJson(e))
            .toList();

        final homeworkName = data['data']['homework_name']?.toString();
        final maxScore = data['data']['max_score'] as num?;

        emit(
          HomeworkGradesLoaded(
            students: newStudents,
            pagination: null, // No pagination in new API
            isOffline: false,
            homeworkName: homeworkName,
            maxScore: maxScore,
          ),
        );
      },
    );
  }

  void fetchNextPage() {
    // Pagination is removed in the new API
  }

  Future<void> searchStudents(String query) async {
    if (state is! HomeworkGradesLoaded) return;
    final currentState = state as HomeworkGradesLoaded;

    emit(HomeworkGradesLoading());

    final result = await getHomeworkStudentsUseCase.call(
      _currentSessionId,
      search: query,
      gradingStatus: currentState.currentFilter,
    );

    result.fold(
      (failure) {
        // If offline and we are searching, we show error or fallback
        emit(HomeworkGradesError(failure.message));
      },
      (data) {
        final students = (data['data']['grades'] as List)
            .map((e) => HomeworkStudentModel.fromJson(e))
            .toList();

        final homeworkName = data['data']['homework_name']?.toString();
        final maxScore = data['data']['max_score'] as num?;

        emit(
          HomeworkGradesLoaded(
            students: students,
            pagination: null,
            currentSearch: query,
            currentFilter: currentState.currentFilter,
            isOffline: false,
            homeworkName: homeworkName,
            maxScore: maxScore,
          ),
        );
      },
    );
  }

  Future<void> setFilter(String filter) async {
    if (state is! HomeworkGradesLoaded) return;
    final currentState = state as HomeworkGradesLoaded;
    if (currentState.currentFilter == filter) return;

    emit(HomeworkGradesLoading());

    final result = await getHomeworkStudentsUseCase.call(
      _currentSessionId,
      search: currentState.currentSearch,
      gradingStatus: filter,
    );

    result.fold(
      (failure) {
        emit(HomeworkGradesError(failure.message));
      },
      (data) {
        final students = (data['data']['grades'] as List)
            .map((e) => HomeworkStudentModel.fromJson(e))
            .toList();

        final homeworkName = data['data']['homework_name']?.toString();
        final maxScore = data['data']['max_score'] as num?;

        emit(
          HomeworkGradesLoaded(
            students: students,
            pagination: null,
            currentSearch: currentState.currentSearch,
            currentFilter: filter,
            isOffline: false,
            homeworkName: homeworkName,
            maxScore: maxScore,
          ),
        );
      },
    );
  }

  Future<void> updateGrade(String studentId, num grade, {String? sessionName}) async {
    if (state is! HomeworkGradesLoaded) return;
    final currentState = state as HomeworkGradesLoaded;

    // Reset any previous action message immediately
    emit(currentState.copyWith(clearActionMessage: true));

    final result = await updateHomeworkGradeUseCase.call(
      _currentSessionId,
      sessionName,
      studentId,
      grade,
    );

    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            actionMessage: failure.message,
            isActionSuccess: false,
          ),
        );
      },
      (data) {
        final updatedStudentData = data['data'];

        final updatedStudents = currentState.students.map((student) {
          if (student.studentId == studentId) {
            return HomeworkStudentModel(
              studentId: student.studentId,
              name: student.name,
              studentCode: student.studentCode,
              email: student.email,
              phoneNumber: student.phoneNumber,
              picture: student.picture,
              offlineStatus: student.offlineStatus,
              homeworkAttemptId: student.homeworkAttemptId,
              gradingStatus: updatedStudentData?['grading_status'] ?? 'graded',
              grade: updatedStudentData?['grade'] ?? grade,
              maxScore: updatedStudentData?['maxScore'] ?? student.maxScore,
              percentage:
                  updatedStudentData?['percentage'] ?? student.percentage,
              approvedBy:
                  updatedStudentData?['approved_by'] ?? student.approvedBy,
              approvedAt:
                  updatedStudentData?['approved_at'] ?? student.approvedAt,
            );
          }
          return student;
        }).toList();

        emit(
          currentState.copyWith(
            students: updatedStudents,
            actionMessage: data['message'] ?? 'تم تحديث الدرجة بنجاح',
            isActionSuccess: true,
          ),
        );
      },
    );
  }
}
