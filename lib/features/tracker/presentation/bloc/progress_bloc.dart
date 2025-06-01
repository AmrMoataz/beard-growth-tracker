import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:beardO/core/error/failures.dart';
import 'package:beardO/features/tracker/domain/entities/progress_entry.dart';
import 'package:beardO/features/tracker/domain/usecases/get_completion_rate.dart';
import 'package:beardO/features/tracker/domain/usecases/get_progress_entries.dart';
import 'package:beardO/features/tracker/domain/usecases/get_progress_entry_by_date.dart';
import 'package:beardO/features/tracker/domain/usecases/save_progress_entry.dart';
import 'package:beardO/features/tracker/domain/usecases/save_progress_photo.dart';
import 'package:beardO/features/tracker/domain/usecases/update_progress_entry.dart';
import 'package:beardO/features/tracker/presentation/bloc/progress_event.dart';
import 'package:beardO/features/tracker/presentation/bloc/progress_state.dart';

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final GetProgressEntries getProgressEntries;
  final GetProgressEntryByDate getProgressEntryByDate;
  final SaveProgressEntry saveProgressEntry;
  final UpdateProgressEntry updateProgressEntry;
  final SaveProgressPhoto saveProgressPhoto;
  final GetCompletionRate getCompletionRate;

  // Keep track of loaded entries for more efficient state updates
  List<ProgressEntry> _loadedEntries = [];

  ProgressBloc({
    required this.getProgressEntries,
    required this.getProgressEntryByDate,
    required this.saveProgressEntry,
    required this.updateProgressEntry,
    required this.saveProgressPhoto,
    required this.getCompletionRate,
  }) : super(ProgressInitial()) {
    on<GetProgressEntriesEvent>(_onGetProgressEntries);
    on<GetTodayProgressEvent>(_onGetTodayProgress);
    on<GetProgressEntryByDateEvent>(_onGetProgressEntryByDate);
    on<GetCompletionRateEvent>(_onGetCompletionRate);
    on<ToggleMorningApplicationEvent>(_onToggleMorningApplication);
    on<ToggleEveningApplicationEvent>(_onToggleEveningApplication);
    on<UpdateNotesEvent>(_onUpdateNotes);
    on<SaveProgressPhotoEvent>(_onSaveProgressPhoto);
    on<CreateProgressEntryEvent>(_onCreateProgressEntry);
    on<DeleteProgressEntryEvent>(_onDeleteProgressEntry);
  }

  Future<void> _onGetProgressEntries(
      GetProgressEntriesEvent event, Emitter<ProgressState> emit) async {
    emit(ProgressLoading());
    final result = await getProgressEntries();
    _emitEither(result, (entries) {
      _loadedEntries = entries;
      return EntriesLoaded(entries: entries);
    }, emit);
  }

  Future<void> _onGetTodayProgress(
      GetTodayProgressEvent event, Emitter<ProgressState> emit) async {
    emit(ProgressLoading());
    final today = DateTime.now();
    final result = await getProgressEntryByDate(
        DateTime(today.year, today.month, today.day));

    result.fold((failure) {
      emit(ProgressError(message: _mapFailureToMessage(failure)));
    }, (entry) {
      emit(TodayEntryLoaded(entry: entry));
    });
  }

  Future<void> _onGetProgressEntryByDate(
      GetProgressEntryByDateEvent event, Emitter<ProgressState> emit) async {
    emit(ProgressLoading());
    final normalizedDate =
        DateTime(event.date.year, event.date.month, event.date.day);
    final result = await getProgressEntryByDate(normalizedDate);

    result.fold((failure) {
      emit(ProgressError(message: _mapFailureToMessage(failure)));
    }, (entry) {
      emit(EntryLoaded(entry: entry));
    });
  }

  Future<void> _onGetCompletionRate(
      GetCompletionRateEvent event, Emitter<ProgressState> emit) async {
    emit(ProgressLoading());
    final result = await getCompletionRate();

    result.fold(
        (failure) =>
            emit(ProgressError(message: _mapFailureToMessage(failure))),
        (rate) {
      // Here we're making the assumption that the repository returns an int percentage
      // We'll convert it to three separate rates for morning, evening, and overall
      // This matches the CompletionRateLoaded state definition
      final double percentage = rate / 100.0;
      emit(CompletionRateLoaded(
        morningRate: percentage,
        eveningRate: percentage,
        overallRate: percentage,
      ));
    });
  }

  Future<void> _onToggleMorningApplication(
      ToggleMorningApplicationEvent event, Emitter<ProgressState> emit) async {
    final updatedEntry = event.entry.copyWith(
      morningApplicationDone: !event.entry.morningApplicationDone,
    );

    final result = await updateProgressEntry(updatedEntry);
    _emitEither(result, (entry) {
      _updateEntryInList(entry);
      return MorningApplicationToggled(entry: entry);
    }, emit);
  }

  Future<void> _onToggleEveningApplication(
      ToggleEveningApplicationEvent event, Emitter<ProgressState> emit) async {
    final updatedEntry = event.entry.copyWith(
      eveningApplicationDone: !event.entry.eveningApplicationDone,
    );

    final result = await updateProgressEntry(updatedEntry);
    _emitEither(result, (entry) {
      _updateEntryInList(entry);
      return EveningApplicationToggled(entry: entry);
    }, emit);
  }

  Future<void> _onUpdateNotes(
      UpdateNotesEvent event, Emitter<ProgressState> emit) async {
    final updatedEntry = event.entry.copyWith(
      notes: event.notes,
    );

    final result = await updateProgressEntry(updatedEntry);
    _emitEither(result, (entry) {
      _updateEntryInList(entry);
      return NoteUpdated(entry: entry);
    }, emit);
  }

  Future<void> _onSaveProgressPhoto(
      SaveProgressPhotoEvent event, Emitter<ProgressState> emit) async {
    emit(ProgressLoading());
    final result = await saveProgressPhoto(event.entryId, event.photo);

    result.fold(
        (failure) =>
            emit(ProgressError(message: _mapFailureToMessage(failure))),
        (photoPath) {
      // Find the entry and update it with new photo path
      final entryIndex =
          _loadedEntries.indexWhere((e) => e.id == event.entryId);
      if (entryIndex != -1) {
        final updatedEntry =
            _loadedEntries[entryIndex].copyWith(photoPath: photoPath);
        _updateEntryInList(updatedEntry);
      }
      emit(PhotoSaved(entryId: event.entryId, photoPath: photoPath));
    });
  }

  Future<void> _onCreateProgressEntry(
      CreateProgressEntryEvent event, Emitter<ProgressState> emit) async {
    emit(ProgressLoading());

    // Create a new entry with default values
    final newEntry = ProgressEntry(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Generate a unique ID
      date: event.date,
      morningApplicationDone: false,
      eveningApplicationDone: false,
    );

    final result = await saveProgressEntry(newEntry);
    await result.fold((failure) async {
      emit(ProgressError(message: _mapFailureToMessage(failure)));
    }, (entry) async {
      _loadedEntries.add(entry);
      emit(EntryCreated(entry: entry));

      // After creating entry, reload all entries
      final entriesResult = await getProgressEntries();
      entriesResult.fold(
          (failure) =>
              emit(ProgressError(message: _mapFailureToMessage(failure))),
          (entries) {
        _loadedEntries = entries;
        emit(EntriesLoaded(entries: entries));
      });

      // Also get the entry for the current date
      final normalizedDate =
          DateTime(event.date.year, event.date.month, event.date.day);
      final dateEntryResult = await getProgressEntryByDate(normalizedDate);
      dateEntryResult.fold(
          (failure) =>
              emit(ProgressError(message: _mapFailureToMessage(failure))),
          (dateEntry) => emit(EntryLoaded(entry: dateEntry)));
    });
  }

  Future<void> _onDeleteProgressEntry(
      DeleteProgressEntryEvent event, Emitter<ProgressState> emit) async {
    emit(ProgressLoading());

    // Find the entry to remove it from our local cache
    final entryIndex = _loadedEntries.indexWhere((e) => e.id == event.entryId);
    if (entryIndex != -1) {
      _loadedEntries.removeAt(entryIndex);
    }

    // For now we'll just emit the deleted state since we don't have a delete usecase
    // In a real implementation, we'd call a delete usecase here
    emit(EntryDeleted(entryId: event.entryId));
  }

  // Helper methods
  void _updateEntryInList(ProgressEntry updatedEntry) {
    final index = _loadedEntries.indexWhere((e) => e.id == updatedEntry.id);
    if (index != -1) {
      _loadedEntries[index] = updatedEntry;
    }
  }

  void _emitEither<T>(
    Either<Failure, T> result,
    ProgressState Function(T) onSuccess,
    Emitter<ProgressState> emit,
  ) {
    result.fold(
      (failure) => emit(ProgressError(message: _mapFailureToMessage(failure))),
      (data) => emit(onSuccess(data)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return 'Network error. Please check your connection and try again.';
      case CacheFailure:
        return 'Cache error. Please clear app data and try again.';
      case DatabaseFailure:
        return 'Database error. Data not found or could not be accessed.';
      case PhotoStorageFailure:
        return 'Error saving photo. Please check storage permissions.';
      default:
        return 'Unexpected error. Please try again later.';
    }
  }
}
