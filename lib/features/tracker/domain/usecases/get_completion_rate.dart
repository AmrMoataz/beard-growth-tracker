import 'package:dartz/dartz.dart';
import 'package:progress_tracker/core/error/failures.dart';
import 'package:progress_tracker/features/tracker/domain/repositories/progress_repository.dart';

class GetCompletionRate {
  GetCompletionRate(this.repository);

  final ProgressRepository repository;

  Future<Either<Failure, int>> call() async {
    return await repository.getCompletionRate();
  }
}
