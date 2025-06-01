import 'package:dartz/dartz.dart';
import 'package:beardO/core/error/failures.dart';
import 'package:beardO/features/tracker/domain/entities/progress_entry.dart';
import 'package:beardO/features/tracker/domain/repositories/progress_repository.dart';

class SaveProgressEntry {
  final ProgressRepository repository;

  SaveProgressEntry(this.repository);

  Future<Either<Failure, ProgressEntry>> call(ProgressEntry entry) async {
    return await repository.saveProgressEntry(entry);
  }
}
