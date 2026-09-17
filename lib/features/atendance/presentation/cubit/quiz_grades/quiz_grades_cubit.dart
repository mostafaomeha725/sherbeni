import 'package:bloc/bloc.dart';
import 'package:qrattendance/features/atendance/data/model/quiz_student_model.dart';
import 'package:qrattendance/core/models/pagination_model.dart';
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

  int _currentPage = 1;
  final int _limit = 10;
  String _currentSessionId = '';
  String _currentQuizTemplateId = '';

  Future<void> fetchStudents(
    String sessionId,
    String quizTemplateId, {
    bool isRefresh = false,
  }) async {
    _currentSessionId = sessionId;
    _currentQuizTemplateId = quizTemplateId;

    if (isRefresh) {
      _currentPage = 1;
    }

    if (_currentPage == 1) {
      emit(QuizGradesLoading());
    } else {
      if (state is QuizGradesLoaded) {
        emit((state as QuizGradesLoaded).copyWith(isFetchingMore: true));
      }
    }

    // 1. Check local cache (default query) only for page 1
    bool hasCache = false;
    if (_currentPage == 1) {
      final cacheResult = await getCachedQuizStudentsUseCase.call(
        sessionId,
        quizTemplateId,
      );

      cacheResult.fold((_) {}, (data) {
        if (data != null &&
            data['data'] != null &&
            data['data']['students'] != null) {
          hasCache = true;
          final students = (data['data']['students'] as List)
              .map((e) => QuizStudentModel.fromJson(e))
              .toList();

          emit(
            QuizGradesLoaded(
              students: students,
              pagination: null, // No pagination while offline/loading
              isOffline:
                  true, // we assume it might be offline, will update if online success
            ),
          );
        }
      });
    }

    // 2. Fetch from API
    final result = await getQuizStudentsUseCase.call(
      sessionId,
      quizTemplateId,
      page: _currentPage,
      limit: _limit,
    );

    result.fold(
      (failure) {
        if (_currentPage == 1) {
          if (!hasCache) {
            emit(QuizGradesError(failure.message));
          }
        } else {
          if (state is QuizGradesLoaded) {
            _currentPage--;
            emit((state as QuizGradesLoaded).copyWith(isFetchingMore: false));
          }
        }
      },
      (data) {
        final newStudents = (data['data']['students'] as List)
            .map((e) => QuizStudentModel.fromJson(e))
            .toList();

        PaginationModel? pagination;
        if (data['pagination'] != null) {
          pagination = PaginationModel.fromJson(data['pagination']);
        }

        if (_currentPage == 1) {
          emit(
            QuizGradesLoaded(
              students: newStudents,
              pagination: pagination,
              isOffline: false,
            ),
          );
        } else {
          if (state is QuizGradesLoaded) {
            final currentState = state as QuizGradesLoaded;
            emit(
              currentState.copyWith(
                students: [...currentState.students, ...newStudents],
                pagination: pagination,
                isFetchingMore: false,
                isOffline: false,
              ),
            );
          }
        }
      },
    );
  }

  void fetchNextPage() {
    if (state is QuizGradesLoaded) {
      final currentState = state as QuizGradesLoaded;
      if (currentState.isFetchingMore) return;

      final pagination = currentState.pagination;
      if (pagination != null && pagination.hasNextPage) {
        _currentPage++;
        fetchStudents(_currentSessionId, _currentQuizTemplateId);
      }
    }
  }

  Future<void> searchStudents(String query) async {
    if (state is! QuizGradesLoaded) return;
    final currentState = state as QuizGradesLoaded;

    emit(QuizGradesLoading());
    _currentPage = 1;

    final result = await getQuizStudentsUseCase.call(
      _currentSessionId,
      _currentQuizTemplateId,
      page: _currentPage,
      limit: _limit,
      search: query,
      gradingStatus: currentState.currentFilter,
    );

    result.fold(
      (failure) {
        // If offline and we are searching, we show error or fallback
        emit(QuizGradesError(failure.message));
      },
      (data) {
        final students = (data['data']['students'] as List)
            .map((e) => QuizStudentModel.fromJson(e))
            .toList();

        PaginationModel? pagination;
        if (data['pagination'] != null) {
          pagination = PaginationModel.fromJson(data['pagination']);
        }

        emit(
          QuizGradesLoaded(
            students: students,
            pagination: pagination,
            currentSearch: query,
            currentFilter: currentState.currentFilter,
            isOffline: false,
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
    _currentPage = 1;

    final result = await getQuizStudentsUseCase.call(
      _currentSessionId,
      _currentQuizTemplateId,
      page: _currentPage,
      limit: _limit,
      search: currentState.currentSearch,
      gradingStatus: filter,
    );

    result.fold(
      (failure) {
        emit(QuizGradesError(failure.message));
      },
      (data) {
        final students = (data['data']['students'] as List)
            .map((e) => QuizStudentModel.fromJson(e))
            .toList();

        PaginationModel? pagination;
        if (data['pagination'] != null) {
          pagination = PaginationModel.fromJson(data['pagination']);
        }

        emit(
          QuizGradesLoaded(
            students: students,
            pagination: pagination,
            currentSearch: currentState.currentSearch,
            currentFilter: filter,
            isOffline: false,
          ),
        );
      },
    );
  }

  Future<void> updateGrade(String quizAttemptId, num grade) async {
    if (state is! QuizGradesLoaded) return;
    final currentState = state as QuizGradesLoaded;

    // Reset any previous action message immediately
    emit(currentState.copyWith(clearActionMessage: true));

    final result = await updateQuizGradeUseCase.call(
      quizAttemptId,
      grade,
      _currentSessionId,
      _currentQuizTemplateId,
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
          if (student.quizAttemptId == quizAttemptId) {
            return QuizStudentModel(
              studentId: student.studentId,
              name: student.name,
              studentCode: student.studentCode,
              email: student.email,
              phone: student.phone,
              picture: student.picture,
              offlineStatus: student.offlineStatus,
              quizAttemptId: student.quizAttemptId,
              gradingStatus: updatedStudentData?['grading_status'] ?? 'graded',
              grade: updatedStudentData?['grade'] ?? grade,
              maxScore: updatedStudentData?['maxScore'] ?? student.maxScore,
              percentage:
                  (updatedStudentData?['percentage'] ??
                          (grade / student.maxScore * 100))
                      .toInt(),
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
