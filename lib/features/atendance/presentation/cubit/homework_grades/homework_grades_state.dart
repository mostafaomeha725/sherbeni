import 'package:equatable/equatable.dart';
import 'package:qrattendance/core/models/pagination_model.dart';
import 'package:qrattendance/features/atendance/data/model/homework_student_model.dart';

abstract class HomeworkGradesState extends Equatable {
  const HomeworkGradesState();

  @override
  List<Object?> get props => [];
}

class HomeworkGradesInitial extends HomeworkGradesState {}

class HomeworkGradesLoading extends HomeworkGradesState {}

class HomeworkGradesLoaded extends HomeworkGradesState {
  final List<HomeworkStudentModel> students;
  final PaginationModel? pagination;
  final bool isFetchingMore;
  final String currentSearch;
  final String currentFilter;
  final bool isOffline;
  final String? actionMessage;
  final bool? isActionSuccess;

  final String? homeworkName;
  final num? maxScore;

  const HomeworkGradesLoaded({
    required this.students,
    this.pagination,
    this.isFetchingMore = false,
    this.currentSearch = '',
    this.currentFilter = 'all',
    this.isOffline = false,
    this.actionMessage,
    this.isActionSuccess,
    this.homeworkName,
    this.maxScore,
  });

  HomeworkGradesLoaded copyWith({
    List<HomeworkStudentModel>? students,
    PaginationModel? pagination,
    bool? isFetchingMore,
    String? currentSearch,
    String? currentFilter,
    bool? isOffline,
    String? actionMessage,
    bool? isActionSuccess,
    bool clearActionMessage = false,
    String? homeworkName,
    num? maxScore,
  }) {
    return HomeworkGradesLoaded(
      students: students ?? this.students,
      pagination: pagination ?? this.pagination,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      currentFilter: currentFilter ?? this.currentFilter,
      currentSearch: currentSearch ?? this.currentSearch,
      isOffline: isOffline ?? this.isOffline,
      homeworkName: homeworkName ?? this.homeworkName,
      maxScore: maxScore ?? this.maxScore,
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
    homeworkName,
    maxScore,
  ];
}

class HomeworkGradesError extends HomeworkGradesState {
  final String message;

  const HomeworkGradesError(this.message);

  @override
  List<Object?> get props => [message];
}
