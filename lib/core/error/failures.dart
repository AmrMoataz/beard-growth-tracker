import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  @override
  List<Object> get props => [];
}

class CacheFailure extends Failure {}

class PhotoStorageFailure extends Failure {}

class DatabaseFailure extends Failure {}

class NetworkFailure extends Failure {}
