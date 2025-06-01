import 'package:flutter/material.dart';
import 'package:beardO/core/theme/app_theme.dart';
import 'package:beardO/features/settings/domain/entities/app_settings.dart';

class ThemeManager {
  // Convert our ThemePreference enum to Flutter's ThemeMode
  static ThemeMode getThemeMode(ThemePreference preference) {
    switch (preference) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }

  // Get the current theme data based on the theme mode
  static ThemeData getTheme(ThemeMode themeMode, BuildContext? context) {
    if (context != null) {
      final brightness = MediaQuery.platformBrightnessOf(context);
      // If it's system theme, determine from the platform brightness
      if (themeMode == ThemeMode.system) {
        return brightness == Brightness.dark
            ? AppTheme.darkTheme
            : AppTheme.lightTheme;
      }
    }

    // Otherwise use the selected theme
    return themeMode == ThemeMode.dark
        ? AppTheme.darkTheme
        : AppTheme.lightTheme;
  }

  // Convert a StartWeekDay enum to the int value expected by the calendar
  static int getFirstDayOfWeek(StartWeekDay day) {
    return day.value;
  }
}
