import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:beardO/core/error/failures.dart';
import 'package:beardO/features/tracker/domain/entities/progress_entry.dart';

abstract class ProgressRepository {
  Future<Either<Failure, List<ProgressEntry>>> getProgressEntries();
  Future<Either<Failure, ProgressEntry?>> getProgressEntryByDate(DateTime date);
  Future<Either<Failure, ProgressEntry>> saveProgressEntry(ProgressEntry entry);
  Future<Either<Failure, ProgressEntry>> updateProgressEntry(
      ProgressEntry entry);
  Future<Either<Failure, String>> saveProgressPhoto(String entryId, File photo);
  Future<Either<Failure, bool>> deleteProgressEntry(String entryId);
  Future<Either<Failure, int>> getCompletionRate();
}
