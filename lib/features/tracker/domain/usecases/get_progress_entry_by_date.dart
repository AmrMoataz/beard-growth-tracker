import 'package:dartz/dartz.dart';
import 'package:beardO/core/error/failures.dart';
import 'package:beardO/features/tracker/domain/entities/progress_entry.dart';
import 'package:beardO/features/tracker/domain/repositories/progress_repository.dart';

class GetProgressEntryByDate {
  final ProgressRepository repository;

  GetProgressEntryByDate(this.repository);

  Future<Either<Failure, ProgressEntry?>> call(DateTime date) async {
    return await repository.getProgressEntryByDate(date);
  }
}
