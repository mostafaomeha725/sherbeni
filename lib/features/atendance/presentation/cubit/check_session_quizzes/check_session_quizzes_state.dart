part of 'check_session_quizzes_cubit.dart';

@immutable
abstract class CheckSessionQuizzesState {}

class CheckSessionQuizzesInitial extends CheckSessionQuizzesState {}

class CheckSessionQuizzesLoading extends CheckSessionQuizzesState {}

final class CheckSessionQuizzesSuccess extends CheckSessionQuizzesState {
  final List<dynamic> quizzes;
  final SessionEntity session;

  CheckSessionQuizzesSuccess(this.quizzes, this.session);
}

class CheckSessionQuizzesFailure extends CheckSessionQuizzesState {
  final String message;

  CheckSessionQuizzesFailure(this.message);
}
