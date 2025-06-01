import 'package:dartz/dartz.dart';
import 'package:progress_tracker/core/error/failures.dart';
import 'package:progress_tracker/features/tracker/domain/entities/progress_entry.dart';
import 'package:progress_tracker/features/tracker/domain/repositories/progress_repository.dart';

class GetProgressEntries {
  final ProgressRepository repository;

  GetProgressEntries(this.repository);

  Future<Either<Failure, List<ProgressEntry>>> call() async {
    return await repository.getProgressEntries();
  }
}
