import 'package:equatable/equatable.dart';
import 'package:qrattendance/core/models/pagination_model.dart';
import 'package:qrattendance/features/atendance/data/model/quiz_student_model.dart';

abstract class QuizGradesState extends Equatable {
  const QuizGradesState();

  @override
  List<Object?> get props => [];
}

class QuizGradesInitial extends QuizGradesState {}

class QuizGradesLoading extends QuizGradesState {}

class QuizGradesLoaded extends QuizGradesState {
  final List<QuizStudentModel> students;
  final PaginationModel? pagination;
  final bool isFetchingMore;
  final String currentSearch;
  final String currentFilter;
  final bool isOffline;
  final String? actionMessage;
  final bool? isActionSuccess;

  const QuizGradesLoaded({
    required this.students,
    this.pagination,
    this.isFetchingMore = false,
    this.currentSearch = '',
    this.currentFilter = 'all',
    this.isOffline = false,
    this.actionMessage,
    this.isActionSuccess,
  });

  QuizGradesLoaded copyWith({
    List<QuizStudentModel>? students,
    PaginationModel? pagination,
    bool? isFetchingMore,
    String? currentSearch,
    String? currentFilter,
    bool? isOffline,
    String? actionMessage,
    bool? isActionSuccess,
    bool clearActionMessage = false,
  }) {
    return QuizGradesLoaded(
      students: students ?? this.students,
      pagination: pagination ?? this.pagination,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      currentFilter: currentFilter ?? this.currentFilter,
      currentSearch: currentSearch ?? this.currentSearch,
      isOffline: isOffline ?? this.isOffline,
      actionMessage: clearActionMessage
          ? null
          : (actionMessage ?? this.actionMessage),
      isActionSuccess: clearActionMessage
          ? null
          : (isActionSuccess ?? this.isActionSuccess),
    );
  }

  @override
  List<Object?> get props => [
    students,
    pagination,
    isFetchingMore,
    currentSearch,
    currentFilter,
    isOffline,
    actionMessage,
    isActionSuccess,
  ];
}

class QuizGradesError extends QuizGradesState {
  final String message;

  const QuizGradesError(this.message);

  @override
  List<Object?> get props => [message];
}
