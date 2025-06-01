import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:beardO/core/theme/app_colors.dart';
import 'package:beardO/core/theme/app_typography.dart';

/// Defines the application theme and provides both light and dark variants
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Creates the light theme for the application
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.secondaryDark,
        tertiary: AppColors.accent,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.accentLight,
        onTertiaryContainer: AppColors.accentDark,
        error: AppColors.error,
        onError: Colors.white,
        background: AppColors.background,
        onBackground: AppColors.textPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceVariant: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.divider,
        shadow: AppColors.shadow,
      ),
      // Text theme
      textTheme: TextTheme(
        displayLarge: AppTypography.h1.copyWith(color: AppColors.textPrimary),
        displayMedium: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        displaySmall: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        headlineLarge: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        headlineMedium: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        headlineSmall: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        titleLarge:
            AppTypography.subtitle1.copyWith(color: AppColors.textPrimary),
        titleMedium:
            AppTypography.subtitle2.copyWith(color: AppColors.textPrimary),
        titleSmall: AppTypography.subtitle2
            .copyWith(color: AppColors.textSecondary, fontSize: 13),
        bodyLarge: AppTypography.body1.copyWith(color: AppColors.textPrimary),
        bodyMedium: AppTypography.body2.copyWith(color: AppColors.textPrimary),
        bodySmall:
            AppTypography.caption.copyWith(color: AppColors.textSecondary),
        labelLarge: AppTypography.button.copyWith(color: AppColors.textPrimary),
        labelMedium:
            AppTypography.caption.copyWith(color: AppColors.textSecondary),
        labelSmall:
            AppTypography.overline.copyWith(color: AppColors.textSecondary),
      ),
      // Card theme
      cardTheme: CardTheme(
        elevation: 2,
        color: AppColors.surface,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        actionsIconTheme: IconThemeData(color: AppColors.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle:
            AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.caption,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppTypography.button,
          elevation: 2,
          shadowColor: AppColors.shadow,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.button,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTypography.body2.copyWith(color: AppColors.textHint),
        errorStyle: AppTypography.caption.copyWith(color: AppColors.error),
      ),
      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return AppColors.buttonDisabled;
          }
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: AppColors.textSecondary, width: 1.5),
      ),
      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.primaryLight.withOpacity(0.3),
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.2),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle:
            AppTypography.caption.copyWith(color: Colors.white),
      ),
      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return AppColors.buttonDisabled;
          }
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return AppColors.buttonDisabled.withOpacity(0.5);
          }
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.textSecondary.withOpacity(0.3);
        }),
      ),
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 24,
      ),
      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        contentTextStyle:
            AppTypography.body1.copyWith(color: AppColors.textPrimary),
      ),
      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        contentTextStyle: AppTypography.body2.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        disabledColor: AppColors.buttonDisabled,
        selectedColor: AppColors.primaryLight,
        secondarySelectedColor: AppColors.secondaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle:
            AppTypography.caption.copyWith(color: AppColors.textPrimary),
        secondaryLabelStyle:
            AppTypography.caption.copyWith(color: AppColors.textPrimary),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTypography.caption.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      // Other settings
      scaffoldBackgroundColor: AppColors.background,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// Creates the dark theme for the application
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.secondaryDark,
        tertiary: AppColors.accent,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.accentLight,
        onTertiaryContainer: AppColors.accentDark,
        error: AppColors.error,
        onError: Colors.white,
        background: AppColors.backgroundDark,
        onBackground: AppColors.textPrimaryDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        surfaceVariant: AppColors.surfaceVariantDark,
        onSurfaceVariant: AppColors.textSecondaryDark,
        outline: AppColors.dividerDark,
        shadow: AppColors.shadowDark,
      ),
      // Text theme
      textTheme: TextTheme(
        displayLarge:
            AppTypography.h1.copyWith(color: AppColors.textPrimaryDark),
        displayMedium:
            AppTypography.h2.copyWith(color: AppColors.textPrimaryDark),
        displaySmall:
            AppTypography.h3.copyWith(color: AppColors.textPrimaryDark),
        headlineLarge:
            AppTypography.h2.copyWith(color: AppColors.textPrimaryDark),
        headlineMedium:
            AppTypography.h3.copyWith(color: AppColors.textPrimaryDark),
        headlineSmall:
            AppTypography.h4.copyWith(color: AppColors.textPrimaryDark),
        titleLarge:
            AppTypography.subtitle1.copyWith(color: AppColors.textPrimaryDark),
        titleMedium:
            AppTypography.subtitle2.copyWith(color: AppColors.textPrimaryDark),
        titleSmall: AppTypography.subtitle2
            .copyWith(color: AppColors.textSecondaryDark, fontSize: 13),
        bodyLarge:
            AppTypography.body1.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium:
            AppTypography.body2.copyWith(color: AppColors.textPrimaryDark),
        bodySmall:
            AppTypography.caption.copyWith(color: AppColors.textSecondaryDark),
        labelLarge:
            AppTypography.button.copyWith(color: AppColors.textPrimaryDark),
        labelMedium:
            AppTypography.caption.copyWith(color: AppColors.textSecondaryDark),
        labelSmall:
            AppTypography.overline.copyWith(color: AppColors.textSecondaryDark),
      ),
      // Card theme
      cardTheme: CardTheme(
        elevation: 4,
        color: AppColors.surfaceDark,
        shadowColor: AppColors.shadowDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle:
            AppTypography.h4.copyWith(color: AppColors.textPrimaryDark),
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
        actionsIconTheme: IconThemeData(color: AppColors.textPrimaryDark),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryDark,
        selectedLabelStyle:
            AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.caption,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppTypography.button,
          elevation: 2,
          shadowColor: AppColors.shadowDark,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.button,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantDark,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTypography.body2.copyWith(color: AppColors.textHintDark),
        errorStyle: AppTypography.caption.copyWith(color: AppColors.error),
      ),
      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return AppColors.buttonDisabledDark;
          }
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: AppColors.textSecondaryDark, width: 1.5),
      ),
      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.primaryLight.withOpacity(0.3),
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.2),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle:
            AppTypography.caption.copyWith(color: Colors.white),
      ),
      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return AppColors.buttonDisabledDark;
          }
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.surfaceVariantDark;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return AppColors.buttonDisabledDark.withOpacity(0.5);
          }
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.textSecondaryDark.withOpacity(0.3);
        }),
      ),
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 24,
      ),
      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceDark,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle:
            AppTypography.h3.copyWith(color: AppColors.textPrimaryDark),
        contentTextStyle:
            AppTypography.body1.copyWith(color: AppColors.textPrimaryDark),
      ),
      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface.withOpacity(0.9),
        contentTextStyle:
            AppTypography.body2.copyWith(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariantDark,
        disabledColor: AppColors.buttonDisabledDark,
        selectedColor: AppColors.primaryLight,
        secondarySelectedColor: AppColors.secondaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle:
            AppTypography.caption.copyWith(color: AppColors.textPrimaryDark),
        secondaryLabelStyle:
            AppTypography.caption.copyWith(color: AppColors.textPrimaryDark),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTypography.caption.copyWith(color: AppColors.textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      // Other settings
      scaffoldBackgroundColor: AppColors.backgroundDark,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
