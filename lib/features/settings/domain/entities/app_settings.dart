import 'package:equatable/equatable.dart';

enum ThemePreference {
  light,
  dark,
  system,
}

enum StartWeekDay {
  monday(1),
  tuesday(2),
  wednesday(3),
  thursday(4),
  friday(5),
  saturday(6),
  sunday(7);

  final int value;
  const StartWeekDay(this.value);
}

class AppSettings extends Equatable {
  final ThemePreference themePreference;
  final bool notificationsEnabled;
  final StartWeekDay startWeekDay;

  const AppSettings({
    required this.themePreference,
    required this.notificationsEnabled,
    required this.startWeekDay,
  });

  // Default settings
  factory AppSettings.initial() {
    return const AppSettings(
      themePreference: ThemePreference.system,
      notificationsEnabled: true,
      startWeekDay: StartWeekDay.monday,
    );
  }

  // Copy with method to create a new instance with updated values
  AppSettings copyWith({
    ThemePreference? themePreference,
    bool? notificationsEnabled,
    StartWeekDay? startWeekDay,
  }) {
    return AppSettings(
      themePreference: themePreference ?? this.themePreference,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      startWeekDay: startWeekDay ?? this.startWeekDay,
    );
  }

  @override
  List<Object> get props => [themePreference, notificationsEnabled, startWeekDay];
}
