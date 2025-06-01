import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:progress_tracker/core/error/failures.dart';
import 'package:progress_tracker/features/tracker/data/datasources/progress_local_data_source.dart';
import 'package:progress_tracker/features/tracker/data/models/progress_entry_model.dart';
import 'package:progress_tracker/features/tracker/domain/entities/progress_entry.dart';
import 'package:progress_tracker/features/tracker/domain/repositories/progress_repository.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressLocalDataSource localDataSource;

  ProgressRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<ProgressEntry>>> getProgressEntries() async {
    try {
      final entries = await localDataSource.getProgressEntries();
      return Right(entries);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, ProgressEntry?>> getProgressEntryByDate(
      DateTime date) async {
    try {
      final entry = await localDataSource.getProgressEntryByDate(date);
      if (entry == null) {
        return const Right(null);
      }
      return Right(entry);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, ProgressEntry>> saveProgressEntry(
      ProgressEntry entry) async {
    try {
      final entryModel = ProgressEntryModel.fromEntity(entry);
      final savedEntry = await localDataSource.saveProgressEntry(entryModel);
      return Right(savedEntry);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, ProgressEntry>> updateProgressEntry(
      ProgressEntry entry) async {
    try {
      final entryModel = ProgressEntryModel.fromEntity(entry);
      final updatedEntry =
          await localDataSource.updateProgressEntry(entryModel);
      return Right(updatedEntry);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, String>> saveProgressPhoto(
      String entryId, File photo) async {
    try {
      final photoPath = await localDataSource.saveProgressPhoto(entryId, photo);
      return Right(photoPath);
    } catch (e) {
      return Left(PhotoStorageFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteProgressEntry(String entryId) async {
    try {
      final result = await localDataSource.deleteProgressEntry(entryId);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, int>> getCompletionRate() async {
    try {
      final completionRate = await localDataSource.getCompletionRate();
      return Right(completionRate);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }
}
