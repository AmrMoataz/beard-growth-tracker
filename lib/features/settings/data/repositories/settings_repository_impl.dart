import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_tracker/features/settings/domain/entities/app_settings.dart';
import 'package:progress_tracker/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences _prefs;

  // Keys for SharedPreferences
  static const _themePreferenceKey = 'theme_preference';
  static const _notificationsEnabledKey = 'notifications_enabled';
  static const _startWeekDayKey = 'start_week_day';

  SettingsRepositoryImpl(this._prefs);

  @override
  Future<AppSettings> getSettings() async {
    // Get theme preference (default: system)
    final themeIndex = _prefs.getInt(_themePreferenceKey) ?? ThemePreference.system.index;
    final themePreference = ThemePreference.values[themeIndex];

    // Get notifications enabled (default: true)
    final notificationsEnabled = _prefs.getBool(_notificationsEnabledKey) ?? true;

    // Get start week day (default: monday)
    final startWeekDayIndex = _prefs.getInt(_startWeekDayKey) ?? StartWeekDay.monday.index;
    final startWeekDay = StartWeekDay.values[startWeekDayIndex];

    return AppSettings(
      themePreference: themePreference,
      notificationsEnabled: notificationsEnabled,
      startWeekDay: startWeekDay,
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setInt(_themePreferenceKey, settings.themePreference.index);
    await _prefs.setBool(_notificationsEnabledKey, settings.notificationsEnabled);
    await _prefs.setInt(_startWeekDayKey, settings.startWeekDay.index);
  }

  @override
  Future<void> saveThemePreference(ThemePreference preference) async {
    await _prefs.setInt(_themePreferenceKey, preference.index);
  }

  @override
  Future<void> saveNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_notificationsEnabledKey, enabled);
  }

  @override
  Future<void> saveStartWeekDay(StartWeekDay startWeekDay) async {
    await _prefs.setInt(_startWeekDayKey, startWeekDay.index);
  }
}
