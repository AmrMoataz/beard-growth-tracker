import 'package:beardO/features/settings/domain/entities/app_settings.dart';

abstract class SettingsRepository {
  /// Get the current app settings
  Future<AppSettings> getSettings();

  /// Save the app settings
  Future<void> saveSettings(AppSettings settings);

  /// Save the theme preference
  Future<void> saveThemePreference(ThemePreference preference);

  /// Save the notifications enabled state
  Future<void> saveNotificationsEnabled(bool enabled);

  /// Save the start week day
  Future<void> saveStartWeekDay(StartWeekDay startWeekDay);
}
