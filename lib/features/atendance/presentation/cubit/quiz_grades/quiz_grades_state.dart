import 'package:equatable/equatable.dart';
import 'package:qrattendance/features/atendance/domain/entities/student_entity.dart';

abstract class QuizGradesState extends Equatable {
  const QuizGradesState();

  @override
  List<Object?> get props => [];
}

class QuizGradesInitial extends QuizGradesState {}

class QuizGradesLoading extends QuizGradesState {}

enum QuizGradeFilter { all, graded, notGraded }

class QuizGradesLoaded extends QuizGradesState {
  final List<StudentEntity> allStudents;
  final List<StudentEntity> filteredStudents;
  final Map<String, int> quizGrades; // studentId -> grade
  final QuizGradeFilter currentFilter;

  const QuizGradesLoaded({
    required this.allStudents,
    required this.filteredStudents,
    required this.quizGrades,
    this.currentFilter = QuizGradeFilter.all,
  });

  QuizGradesLoaded copyWith({
    List<StudentEntity>? allStudents,
    List<StudentEntity>? filteredStudents,
    Map<String, int>? quizGrades,
    QuizGradeFilter? currentFilter,
  }) {
    return QuizGradesLoaded(
      allStudents: allStudents ?? this.allStudents,
      filteredStudents: filteredStudents ?? this.filteredStudents,
      quizGrades: quizGrades ?? this.quizGrades,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }

  @override
  List<Object?> get props => [allStudents, filteredStudents, quizGrades, currentFilter];
}

class QuizGradesError extends QuizGradesState {
  final String message;

  const QuizGradesError(this.message);

  @override
  List<Object?> get props => [message];
}
