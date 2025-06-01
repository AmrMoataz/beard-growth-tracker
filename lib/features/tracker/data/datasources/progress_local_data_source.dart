import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:beardO/features/tracker/data/models/progress_entry_model.dart';

abstract class ProgressLocalDataSource {
  Future<List<ProgressEntryModel>> getProgressEntries();
  Future<ProgressEntryModel?> getProgressEntryByDate(DateTime date);
  Future<ProgressEntryModel> saveProgressEntry(ProgressEntryModel entry);
  Future<ProgressEntryModel> updateProgressEntry(ProgressEntryModel entry);
  Future<String> saveProgressPhoto(String entryId, File photo);
  Future<bool> deleteProgressEntry(String entryId);
  Future<int> getCompletionRate();
}

class ProgressLocalDataSourceImpl implements ProgressLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String entriesKey = 'progress_entries';

  ProgressLocalDataSourceImpl({
    required this.sharedPreferences,
  });

  // Helper method to get all entries as a Map with ID as key
  Map<String, ProgressEntryModel> _getAllEntriesMap() {
    final entriesJson = sharedPreferences.getString(entriesKey) ?? '{}';
    final Map<String, dynamic> entriesMap =
        json.decode(entriesJson) as Map<String, dynamic>;

    return entriesMap.map((key, value) => MapEntry(
        key, ProgressEntryModel.fromJson(value as Map<String, dynamic>)));
  }

  // Helper method to save all entries from a Map
  Future<void> _saveEntriesMap(Map<String, ProgressEntryModel> entries) async {
    final Map<String, dynamic> entriesJson =
        entries.map((key, value) => MapEntry(key, value.toJson()));
    await sharedPreferences.setString(entriesKey, json.encode(entriesJson));
  }

  @override
  Future<List<ProgressEntryModel>> getProgressEntries() async {
    final entries = _getAllEntriesMap().values.toList();
    // Sort by date descending
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  @override
  Future<ProgressEntryModel?> getProgressEntryByDate(DateTime date) async {
    final entries = _getAllEntriesMap().values.toList();

    if (entries.isEmpty) {
      return null;
    }

    try {
      return entries.firstWhere((entry) {
        // Compare year, month and day to find entries for the same day
        return entry.date.year == date.year &&
            entry.date.month == date.month &&
            entry.date.day == date.day;
      });
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ProgressEntryModel> saveProgressEntry(ProgressEntryModel entry) async {
    final id = entry.id.isEmpty ? const Uuid().v4() : entry.id;
    final entryToSave = ProgressEntryModel(
      id: id,
      date: entry.date,
      morningApplicationDone: entry.morningApplicationDone,
      eveningApplicationDone: entry.eveningApplicationDone,
      notes: entry.notes,
      photoPath: entry.photoPath,
    );

    final entries = _getAllEntriesMap();
    entries[id] = entryToSave;
    await _saveEntriesMap(entries);

    return entryToSave;
  }

  @override
  Future<ProgressEntryModel> updateProgressEntry(
      ProgressEntryModel entry) async {
    final entries = _getAllEntriesMap();
    entries[entry.id] = entry;
    await _saveEntriesMap(entries);
    return entry;
  }

  @override
  Future<String> saveProgressPhoto(String entryId, File photo) async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDir.path}/photos');

    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final fileName = '${entryId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPhotoPath = '${photosDir.path}/$fileName';

    // Copy the photo to our app's storage
    await photo.copy(savedPhotoPath);

    // Get the entry and update its photo path
    final entries = _getAllEntriesMap();
    if (entries.containsKey(entryId)) {
      final entry = entries[entryId]!;
      final updatedEntry = ProgressEntryModel(
        id: entry.id,
        date: entry.date,
        morningApplicationDone: entry.morningApplicationDone,
        eveningApplicationDone: entry.eveningApplicationDone,
        notes: entry.notes,
        photoPath: savedPhotoPath,
      );

      await updateProgressEntry(updatedEntry);
    }

    return savedPhotoPath;
  }

  @override
  Future<bool> deleteProgressEntry(String entryId) async {
    final entries = _getAllEntriesMap();
    final removed = entries.remove(entryId);
    if (removed != null) {
      await _saveEntriesMap(entries);
      return true;
    }
    return false;
  }

  @override
  Future<int> getCompletionRate() async {
    // Calculate the percentage of days with both morning and evening applications completed
    final entries = await getProgressEntries();
    if (entries.isEmpty) return 0;

    final completedEntries = entries
        .where(
          (entry) =>
              entry.morningApplicationDone && entry.eveningApplicationDone,
        )
        .length;

    return ((completedEntries / entries.length) * 100).round();
  }
}
