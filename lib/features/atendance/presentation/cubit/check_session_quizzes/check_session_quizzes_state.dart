part of 'check_session_quizzes_cubit.dart';

@immutable
abstract class CheckSessionQuizzesState {}

class CheckSessionQuizzesInitial extends CheckSessionQuizzesState {}

class CheckSessionQuizzesLoading extends CheckSessionQuizzesState {}

class CheckSessionQuizzesSuccess extends CheckSessionQuizzesState {
  final bool hasQuizzes;
  final SessionEntity session;

  CheckSessionQuizzesSuccess(this.hasQuizzes, this.session);
}

class CheckSessionQuizzesFailure extends CheckSessionQuizzesState {
  final String message;

  CheckSessionQuizzesFailure(this.message);
}
