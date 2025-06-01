import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:beardO/features/settings/domain/entities/app_settings.dart';
import 'package:beardO/features/settings/domain/repositories/settings_repository.dart';
import 'package:beardO/features/settings/presentation/bloc/settings_event.dart';
import 'package:beardO/features/settings/presentation/bloc/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsBloc(this._settingsRepository) : super(SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<SaveThemePreferenceEvent>(_onSaveThemePreference);
    on<SaveNotificationsEnabledEvent>(_onSaveNotificationsEnabled);
    on<SaveStartWeekDayEvent>(_onSaveStartWeekDay);
    on<ApplyAllSettingsEvent>(_onApplyAllSettings);
  }

  Future<void> _onLoadSettings(
      LoadSettingsEvent event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      final settings = await _settingsRepository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError('Failed to load settings: $e'));
      // Fallback to default settings
      emit(SettingsLoaded(AppSettings.initial()));
    }
  }

  Future<void> _onSaveThemePreference(
      SaveThemePreferenceEvent event, Emitter<SettingsState> emit) async {
    try {
      // Get current settings first
      final currentSettings = state is SettingsLoaded
          ? (state as SettingsLoaded).settings
          : await _settingsRepository.getSettings();

      // Update theme preference
      final updatedSettings =
          currentSettings.copyWith(themePreference: event.themePreference);

      // Save to repository
      await _settingsRepository.saveThemePreference(event.themePreference);

      // Emit new state
      emit(SettingsSaved(updatedSettings));
      emit(SettingsLoaded(updatedSettings));
    } catch (e) {
      emit(SettingsError('Failed to save theme preference: $e'));
    }
  }

  Future<void> _onSaveNotificationsEnabled(
      SaveNotificationsEnabledEvent event, Emitter<SettingsState> emit) async {
    try {
      // Get current settings first
      final currentSettings = state is SettingsLoaded
          ? (state as SettingsLoaded).settings
          : await _settingsRepository.getSettings();

      // Update notifications enabled state
      final updatedSettings = currentSettings.copyWith(
          notificationsEnabled: event.notificationsEnabled);

      // Save to repository
      await _settingsRepository
          .saveNotificationsEnabled(event.notificationsEnabled);

      // Emit new state
      emit(SettingsSaved(updatedSettings));
      emit(SettingsLoaded(updatedSettings));
    } catch (e) {
      emit(SettingsError('Failed to save notifications setting: $e'));
    }
  }

  Future<void> _onSaveStartWeekDay(
      SaveStartWeekDayEvent event, Emitter<SettingsState> emit) async {
    try {
      // Get current settings first
      final currentSettings = state is SettingsLoaded
          ? (state as SettingsLoaded).settings
          : await _settingsRepository.getSettings();

      // Update start week day
      final updatedSettings =
          currentSettings.copyWith(startWeekDay: event.startWeekDay);

      // Save to repository
      await _settingsRepository.saveStartWeekDay(event.startWeekDay);

      // Emit new state
      emit(SettingsSaved(updatedSettings));
      emit(SettingsLoaded(updatedSettings));
    } catch (e) {
      emit(SettingsError('Failed to save start week day: $e'));
    }
  }

  Future<void> _onApplyAllSettings(
      ApplyAllSettingsEvent event, Emitter<SettingsState> emit) async {
    try {
      // Save all settings at once
      await _settingsRepository.saveSettings(event.settings);

      // Emit new state
      emit(SettingsSaved(event.settings));
      emit(SettingsLoaded(event.settings));
    } catch (e) {
      emit(SettingsError('Failed to apply all settings: $e'));
    }
  }
}
