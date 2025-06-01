import 'package:dartz/dartz.dart';
import 'package:beardO/core/error/failures.dart';
import 'package:beardO/features/tracker/domain/repositories/progress_repository.dart';

class GetCompletionRate {
  GetCompletionRate(this.repository);

  final ProgressRepository repository;

  Future<Either<Failure, int>> call() async {
    return await repository.getCompletionRate();
  }
}
