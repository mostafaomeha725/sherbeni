part of 'show_sessions_cubit.dart';

@immutable
sealed class ShowSessionsState {}

final class ShowSessionsInitial extends ShowSessionsState {}

final class ShowSessionsLoading extends ShowSessionsState {}

final class ShowSessionsSuccess extends ShowSessionsState {
  final List<SessionEntity> sessions;

  ShowSessionsSuccess(this.sessions);
}

final class ShowSessionsFailure extends ShowSessionsState {
  final String message;

  ShowSessionsFailure(this.message);
}

final class ShowSessionsOfflineFallback extends ShowSessionsState {}
