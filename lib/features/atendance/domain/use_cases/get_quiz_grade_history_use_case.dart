import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import '../../data/model/quiz_grade_history_model.dart';
import '../repositories/history_repository.dart';

class GetQuizGradeHistoryUseCase {
  final HistoryRepository repository;

  GetQuizGradeHistoryUseCase(this.repository);

  Future<Either<Failure, List<QuizGradeHistoryModel>>> call() async {
    return await repository.getQuizGradeHistory();
  }
}
