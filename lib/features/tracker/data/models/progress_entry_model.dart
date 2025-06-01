import 'package:progress_tracker/features/tracker/domain/entities/progress_entry.dart';

class ProgressEntryModel extends ProgressEntry {
  const ProgressEntryModel({
    required String id,
    required DateTime date,
    required bool morningApplicationDone,
    required bool eveningApplicationDone,
    String? notes,
    String? photoPath,
  }) : super(
          id: id,
          date: date,
          morningApplicationDone: morningApplicationDone,
          eveningApplicationDone: eveningApplicationDone,
          notes: notes,
          photoPath: photoPath,
        );

  factory ProgressEntryModel.fromJson(Map<String, dynamic> json) {
    return ProgressEntryModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      morningApplicationDone: json['morningApplicationDone'] as bool,
      eveningApplicationDone: json['eveningApplicationDone'] as bool,
      notes: json['notes'] as String?,
      photoPath: json['photoPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'morningApplicationDone': morningApplicationDone,
      'eveningApplicationDone': eveningApplicationDone,
      'notes': notes,
      'photoPath': photoPath,
    };
  }

  factory ProgressEntryModel.fromEntity(ProgressEntry entry) {
    return ProgressEntryModel(
      id: entry.id,
      date: entry.date,
      morningApplicationDone: entry.morningApplicationDone,
      eveningApplicationDone: entry.eveningApplicationDone,
      notes: entry.notes,
      photoPath: entry.photoPath,
    );
  }
}
