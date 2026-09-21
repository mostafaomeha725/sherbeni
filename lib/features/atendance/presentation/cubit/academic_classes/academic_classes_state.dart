part of 'academic_classes_cubit.dart';

@immutable
sealed class AcademicClassesState {}

final class AcademicClassesInitial extends AcademicClassesState {}

final class AcademicClassesLoading extends AcademicClassesState {}

final class AcademicClassesSuccess extends AcademicClassesState {
  final List<AcademicClassEntity> classes;
  AcademicClassesSuccess(this.classes);
}

final class AcademicClassesFailure extends AcademicClassesState {
  final String message;
  AcademicClassesFailure(this.message);
}

final class AcademicClassesOfflineFallback extends AcademicClassesState {}
