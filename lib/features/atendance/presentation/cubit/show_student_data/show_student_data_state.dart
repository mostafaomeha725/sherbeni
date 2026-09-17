part of 'show_student_data_cubit.dart';

@immutable
sealed class ShowStudentDataState {}

final class ShowStudentDataInitial extends ShowStudentDataState {}

final class ShowStudentDataLoading extends ShowStudentDataState {}

final class ShowStudentDataSuccess extends ShowStudentDataState {
  final StudentEntity
  student; // Kept property name as student to avoid breaking presentation layer
  final bool isOnline;

  ShowStudentDataSuccess(this.student, {required this.isOnline});
}

final class ShowStudentDataFailure extends ShowStudentDataState {
  final String message;

  ShowStudentDataFailure(this.message);
}
