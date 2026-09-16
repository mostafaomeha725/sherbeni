part of 'session_students_cubit.dart';

@immutable
abstract class SessionStudentsState extends Equatable {
  const SessionStudentsState();

  @override
  List<Object?> get props => [];
}

class SessionStudentsInitial extends SessionStudentsState {}

class SessionStudentsLoading extends SessionStudentsState {}

class SessionStudentsLoaded extends SessionStudentsState {
  final List<SessionAttendanceEntity> attendances;
  final PaginationModel? pagination;
  final bool isFetchingMore;
  final bool isOffline;

  const SessionStudentsLoaded({
    required this.attendances,
    this.pagination,
    this.isFetchingMore = false,
    this.isOffline = false,
  });

  SessionStudentsLoaded copyWith({
    List<SessionAttendanceEntity>? attendances,
    PaginationModel? pagination,
    bool? isFetchingMore,
    bool? isOffline,
  }) {
    return SessionStudentsLoaded(
      attendances: attendances ?? this.attendances,
      pagination: pagination ?? this.pagination,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [attendances, pagination, isFetchingMore, isOffline];
}

class SessionStudentsFailure extends SessionStudentsState {
  final String message;

  const SessionStudentsFailure(this.message);

  @override
  List<Object> get props => [message];
}
