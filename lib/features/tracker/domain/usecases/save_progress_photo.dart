import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:beardO/core/error/failures.dart';
import 'package:beardO/features/tracker/domain/repositories/progress_repository.dart';

class SaveProgressPhoto {
  final ProgressRepository repository;

  SaveProgressPhoto(this.repository);

  Future<Either<Failure, String>> call(String entryId, File photo) async {
    return await repository.saveProgressPhoto(entryId, photo);
  }
}
