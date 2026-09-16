import 'package:bloc/bloc.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_quiz_students_use_case.dart';
import 'quiz_grades_state.dart';

class QuizGradesCubit extends Cubit<QuizGradesState> {
  final GetQuizStudentsUseCase getQuizStudentsUseCase;

  QuizGradesCubit(this.getQuizStudentsUseCase) : super(QuizGradesInitial());

  Map<String, int> _currentGrades = {};

  Future<void> fetchStudents(String sessionId) async {
    emit(QuizGradesLoading());

    final result = await getQuizStudentsUseCase.call(sessionId);

    result.fold((failure) => emit(QuizGradesError(failure.message)), (
      students,
    ) {
      // Dummy existing grades for testing
      _currentGrades = {'student_0': 15, 'student_3': 20};

      emit(
        QuizGradesLoaded(
          allStudents: students,
          filteredStudents: students,
          quizGrades: Map.from(_currentGrades),
        ),
      );
    });
  }

  String _currentQuery = '';

  void searchStudents(String query) {
    if (state is! QuizGradesLoaded) return;
    _currentQuery = query;
    _applyFilters();
  }

  void setFilter(QuizGradeFilter filter) {
    if (state is! QuizGradesLoaded) return;
    final currentState = state as QuizGradesLoaded;
    if (currentState.currentFilter == filter) return;
    
    emit(currentState.copyWith(currentFilter: filter));
    _applyFilters();
  }

  void _applyFilters() {
    if (state is! QuizGradesLoaded) return;
    final currentState = state as QuizGradesLoaded;

    final lowerQuery = _currentQuery.toLowerCase();
    
    final filtered = currentState.allStudents.where((student) {
      // 1. Text Search
      final matchesSearch = _currentQuery.isEmpty || 
          student.name.toLowerCase().contains(lowerQuery) ||
          student.studentQrCode.toLowerCase().contains(lowerQuery) ||
          student.studentPhone.contains(lowerQuery);

      if (!matchesSearch) return false;

      // 2. Filter Status
      final hasGrade = currentState.quizGrades.containsKey(student.id);
      
      switch (currentState.currentFilter) {
        case QuizGradeFilter.all:
          return true;
        case QuizGradeFilter.graded:
          return hasGrade;
        case QuizGradeFilter.notGraded:
          return !hasGrade;
      }
    }).toList();

    emit(currentState.copyWith(filteredStudents: filtered));
  }

  void updateGrade(String studentId, int grade) {
    if (state is! QuizGradesLoaded) return;
    final currentState = state as QuizGradesLoaded;

    _currentGrades[studentId] = grade;

    // TODO: Call an UpdateQuizGradeUseCase when API is ready
    emit(currentState.copyWith(quizGrades: Map.from(_currentGrades)));
    
    // Re-apply filters in case the active filter was "Not Graded" and now they are graded
    _applyFilters();
  }
}
