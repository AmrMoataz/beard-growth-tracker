import 'package:equatable/equatable.dart';

class ProgressEntry extends Equatable {
  final String id;
  final DateTime date;
  final bool morningApplicationDone;
  final bool eveningApplicationDone;
  final String? notes;
  final String? photoPath;

  const ProgressEntry({
    required this.id,
    required this.date,
    required this.morningApplicationDone,
    required this.eveningApplicationDone,
    this.notes,
    this.photoPath,
  });

  @override
  List<Object?> get props => [
        id,
        date,
        morningApplicationDone,
        eveningApplicationDone,
        notes,
        photoPath,
      ];

  bool get isToday =>
      date.year == DateTime.now().year &&
      date.month == DateTime.now().month &&
      date.day == DateTime.now().day;

  ProgressEntry copyWith({
    String? id,
    DateTime? date,
    bool? morningApplicationDone,
    bool? eveningApplicationDone,
    String? notes,
    String? photoPath,
  }) {
    return ProgressEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      morningApplicationDone:
          morningApplicationDone ?? this.morningApplicationDone,
      eveningApplicationDone:
          eveningApplicationDone ?? this.eveningApplicationDone,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
