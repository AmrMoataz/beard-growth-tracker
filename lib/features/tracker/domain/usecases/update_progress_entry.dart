import 'package:dartz/dartz.dart';
import 'package:beardO/core/error/failures.dart';
import 'package:beardO/features/tracker/domain/entities/progress_entry.dart';
import 'package:beardO/features/tracker/domain/repositories/progress_repository.dart';

class UpdateProgressEntry {
  final ProgressRepository repository;

  UpdateProgressEntry(this.repository);

  Future<Either<Failure, ProgressEntry>> call(ProgressEntry entry) async {
    return await repository.updateProgressEntry(entry);
  }
}
