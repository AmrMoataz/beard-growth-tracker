import 'package:dartz/dartz.dart';
import 'package:beardO/core/error/failures.dart';
import 'package:beardO/features/tracker/domain/entities/progress_entry.dart';
import 'package:beardO/features/tracker/domain/repositories/progress_repository.dart';

class GetProgressEntries {
  final ProgressRepository repository;

  GetProgressEntries(this.repository);

  Future<Either<Failure, List<ProgressEntry>>> call() async {
    return await repository.getProgressEntries();
  }
}
