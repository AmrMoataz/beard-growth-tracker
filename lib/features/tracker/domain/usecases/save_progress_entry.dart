import 'package:dartz/dartz.dart';
import 'package:progress_tracker/core/error/failures.dart';
import 'package:progress_tracker/features/tracker/domain/entities/progress_entry.dart';
import 'package:progress_tracker/features/tracker/domain/repositories/progress_repository.dart';

class SaveProgressEntry {
  final ProgressRepository repository;

  SaveProgressEntry(this.repository);

  Future<Either<Failure, ProgressEntry>> call(ProgressEntry entry) async {
    return await repository.saveProgressEntry(entry);
  }
}
