import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:progress_tracker/features/tracker/domain/entities/progress_entry.dart';

abstract class ProgressEvent extends Equatable {
  const ProgressEvent();

  @override
  List<Object?> get props => [];
}

class GetProgressEntriesEvent extends ProgressEvent {}

class GetTodayProgressEvent extends ProgressEvent {}

class GetProgressEntryByDateEvent extends ProgressEvent {
  final DateTime date;

  const GetProgressEntryByDateEvent({required this.date});

  @override
  List<Object> get props => [date];
}

class GetCompletionRateEvent extends ProgressEvent {}

class ToggleMorningApplicationEvent extends ProgressEvent {
  final ProgressEntry entry;

  const ToggleMorningApplicationEvent({required this.entry});

  @override
  List<Object> get props => [entry];
}

class ToggleEveningApplicationEvent extends ProgressEvent {
  final ProgressEntry entry;

  const ToggleEveningApplicationEvent({required this.entry});

  @override
  List<Object> get props => [entry];
}

class UpdateNotesEvent extends ProgressEvent {
  final ProgressEntry entry;
  final String notes;

  const UpdateNotesEvent({required this.entry, required this.notes});

  @override
  List<Object> get props => [entry, notes];
}

class SaveProgressPhotoEvent extends ProgressEvent {
  final String entryId;
  final File photo;

  const SaveProgressPhotoEvent({required this.entryId, required this.photo});

  @override
  List<Object> get props => [entryId, photo];
}

class CreateProgressEntryEvent extends ProgressEvent {
  final DateTime date;

  const CreateProgressEntryEvent({required this.date});

  @override
  List<Object> get props => [date];
}

class DeleteProgressEntryEvent extends ProgressEvent {
  final String entryId;

  const DeleteProgressEntryEvent({required this.entryId});

  @override
  List<Object> get props => [entryId];
}
