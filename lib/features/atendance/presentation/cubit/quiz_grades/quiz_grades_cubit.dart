import 'package:bloc/bloc.dart';
import 'package:qrattendance/features/atendance/data/model/quiz_student_model.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_quiz_students_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/update_quiz_grade_use_case.dart';
import 'quiz_grades_state.dart';

class QuizGradesCubit extends Cubit<QuizGradesState> {
  final GetQuizStudentsUseCase getQuizStudentsUseCase;
  final GetCachedQuizStudentsUseCase getCachedQuizStudentsUseCase;
  final UpdateQuizGradeUseCase updateQuizGradeUseCase;

  QuizGradesCubit(
    this.getQuizStudentsUseCase,
    this.getCachedQuizStudentsUseCase,
    this.updateQuizGradeUseCase,
  ) : super(QuizGradesInitial());

  String _currentSessionId = '';

  Future<void> fetchStudents(String sessionId, {bool isRefresh = false}) async {
    _currentSessionId = sessionId;

    emit(QuizGradesLoading());

    // 1. Check local cache (default query)
    bool hasCache = false;
    final cacheResult = await getCachedQuizStudentsUseCase.call(sessionId);

    cacheResult.fold((_) {}, (data) {
      if (data != null &&
          data['data'] != null &&
          data['data']['grades'] != null) {
        hasCache = true;
        final students = (data['data']['grades'] as List)
            .map((e) => QuizStudentModel.fromJson(e))
            .toList();

        final quizName = data['data']['quiz_name']?.toString();
        final maxScore = data['data']['max_score'] as num?;

        emit(
          QuizGradesLoaded(
            students: students,
            pagination: null,
            isOffline:
                true, // we assume it might be offline, will update if online success
            quizName: quizName,
            maxScore: maxScore,
          ),
        );
      }
    });

    // 2. Fetch from API
    final result = await getQuizStudentsUseCase.call(sessionId);

    result.fold(
      (failure) {
        if (!hasCache) {
          emit(QuizGradesError(failure.message));
        }
      },
      (data) {
        final newStudents = (data['data']['grades'] as List)
            .map((e) => QuizStudentModel.fromJson(e))
            .toList();

        final quizName = data['data']['quiz_name']?.toString();
        final maxScore = data['data']['max_score'] as num?;

        emit(
          QuizGradesLoaded(
            students: newStudents,
            pagination: null, // No pagination in new API
            isOffline: false,
            quizName: quizName,
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
    if (state is! QuizGradesLoaded) return;
    final currentState = state as QuizGradesLoaded;

    emit(QuizGradesLoading());

    final result = await getQuizStudentsUseCase.call(
      _currentSessionId,
      search: query,
      gradingStatus: currentState.currentFilter,
    );

    result.fold(
      (failure) {
        // If offline and we are searching, we show error or fallback
        emit(QuizGradesError(failure.message));
      },
      (data) {
        final students = (data['data']['grades'] as List)
            .map((e) => QuizStudentModel.fromJson(e))
            .toList();

        final quizName = data['data']['quiz_name']?.toString();
        final maxScore = data['data']['max_score'] as num?;

        emit(
          QuizGradesLoaded(
            students: students,
            pagination: null,
            currentSearch: query,
            currentFilter: currentState.currentFilter,
            isOffline: false,
            quizName: quizName,
            maxScore: maxScore,
          ),
        );
      },
    );
  }

  Future<void> setFilter(String filter) async {
    if (state is! QuizGradesLoaded) return;
    final currentState = state as QuizGradesLoaded;
    if (currentState.currentFilter == filter) return;

    emit(QuizGradesLoading());

    final result = await getQuizStudentsUseCase.call(
      _currentSessionId,
      search: currentState.currentSearch,
      gradingStatus: filter,
    );

    result.fold(
      (failure) {
        emit(QuizGradesError(failure.message));
      },
      (data) {
        final students = (data['data']['grades'] as List)
            .map((e) => QuizStudentModel.fromJson(e))
            .toList();

        final quizName = data['data']['quiz_name']?.toString();
        final maxScore = data['data']['max_score'] as num?;

        emit(
          QuizGradesLoaded(
            students: students,
            pagination: null,
            currentSearch: currentState.currentSearch,
            currentFilter: filter,
            isOffline: false,
            quizName: quizName,
            maxScore: maxScore,
          ),
        );
      },
    );
  }

  Future<void> updateGrade(String studentId, num grade) async {
    if (state is! QuizGradesLoaded) return;
    final currentState = state as QuizGradesLoaded;

    // Reset any previous action message immediately
    emit(currentState.copyWith(clearActionMessage: true));

    final result = await updateQuizGradeUseCase.call(
      _currentSessionId,
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
            return QuizStudentModel(
              studentId: student.studentId,
              name: student.name,
              studentCode: student.studentCode,
              email: student.email,
              phoneNumber: student.phoneNumber,
              picture: student.picture,
              offlineStatus: student.offlineStatus,
              quizAttemptId: student.quizAttemptId,
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
