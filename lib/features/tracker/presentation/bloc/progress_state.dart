import 'package:equatable/equatable.dart';
import 'package:progress_tracker/features/tracker/domain/entities/progress_entry.dart';

abstract class ProgressState extends Equatable {
  const ProgressState();

  @override
  List<Object?> get props => [];
}

class ProgressInitial extends ProgressState {}

class ProgressLoading extends ProgressState {}

class EntriesLoaded extends ProgressState {
  final List<ProgressEntry> entries;

  const EntriesLoaded({required this.entries});

  @override
  List<Object> get props => [entries];
}

class TodayEntryLoaded extends ProgressState {
  final ProgressEntry? entry;

  const TodayEntryLoaded({this.entry});

  @override
  List<Object?> get props => [entry];
}

class EntryCreated extends ProgressState {
  final ProgressEntry entry;

  const EntryCreated({required this.entry});

  @override
  List<Object> get props => [entry];
}

class EntryDeleted extends ProgressState {
  final String entryId;

  const EntryDeleted({required this.entryId});

  @override
  List<Object> get props => [entryId];
}

class PhotoSaved extends ProgressState {
  final String entryId;
  final String photoPath;

  const PhotoSaved({required this.entryId, required this.photoPath});

  @override
  List<Object> get props => [entryId, photoPath];
}

class NoteUpdated extends ProgressState {
  final ProgressEntry entry;

  const NoteUpdated({required this.entry});

  @override
  List<Object> get props => [entry];
}

class MorningApplicationToggled extends ProgressState {
  final ProgressEntry entry;

  const MorningApplicationToggled({required this.entry});

  @override
  List<Object> get props => [entry];
}

class EveningApplicationToggled extends ProgressState {
  final ProgressEntry entry;

  const EveningApplicationToggled({required this.entry});

  @override
  List<Object> get props => [entry];
}

class CompletionRateLoaded extends ProgressState {
  final double morningRate;
  final double eveningRate;
  final double overallRate;

  const CompletionRateLoaded({
    required this.morningRate,
    required this.eveningRate,
    required this.overallRate,
  });

  @override
  List<Object> get props => [morningRate, eveningRate, overallRate];
}

class ProgressError extends ProgressState {
  final String message;

  const ProgressError({required this.message});

  @override
  List<Object> get props => [message];
}

class EntryLoaded extends ProgressState {
  const EntryLoaded({this.entry});
  final ProgressEntry? entry;

  @override
  List<Object?> get props => [entry];
}

class EntryNotFound extends ProgressState {
  final String message;

  const EntryNotFound({required this.message});

  @override
  List<Object> get props => [message];
}
