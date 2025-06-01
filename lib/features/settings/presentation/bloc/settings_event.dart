import 'package:equatable/equatable.dart';
import 'package:progress_tracker/features/settings/domain/entities/app_settings.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {}

class SaveThemePreferenceEvent extends SettingsEvent {
  final ThemePreference themePreference;

  const SaveThemePreferenceEvent(this.themePreference);

  @override
  List<Object> get props => [themePreference];
}

class SaveNotificationsEnabledEvent extends SettingsEvent {
  final bool notificationsEnabled;

  const SaveNotificationsEnabledEvent(this.notificationsEnabled);

  @override
  List<Object> get props => [notificationsEnabled];
}

class SaveStartWeekDayEvent extends SettingsEvent {
  final StartWeekDay startWeekDay;

  const SaveStartWeekDayEvent(this.startWeekDay);

  @override
  List<Object> get props => [startWeekDay];
}

class ApplyAllSettingsEvent extends SettingsEvent {
  final AppSettings settings;

  const ApplyAllSettingsEvent(this.settings);

  @override
  List<Object> get props => [settings];
}
