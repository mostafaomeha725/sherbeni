part of 'show_classes_cubit.dart';

abstract class ShowClassesState {}

class ShowClassesInitial extends ShowClassesState {}

class ShowClassesLoading extends ShowClassesState {}

class ShowClassesSuccess extends ShowClassesState {
  final List<SessionEntity> classes;
  ShowClassesSuccess(this.classes);
}

class ShowClassesFailure extends ShowClassesState {
  final String message;
  ShowClassesFailure(this.message);
}
