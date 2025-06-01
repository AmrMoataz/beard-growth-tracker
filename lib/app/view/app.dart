import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:beardO/core/di/injection_container.dart' as di;
import 'package:beardO/core/theme/app_theme.dart';
import 'package:beardO/core/theme/theme_manager.dart';
import 'package:beardO/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:beardO/features/settings/presentation/bloc/settings_event.dart';
import 'package:beardO/features/settings/presentation/bloc/settings_state.dart';
import 'package:beardO/features/tracker/presentation/bloc/progress_bloc.dart';
import 'package:beardO/features/tracker/presentation/bloc/progress_event.dart';
import 'package:beardO/features/tracker/presentation/pages/home_page.dart';
import 'package:beardO/l10n/l10n.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize Google Fonts before using them
    GoogleFonts.config.allowRuntimeFetching = true;

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProgressBloc>(
          create: (_) => di.sl<ProgressBloc>()..add(GetProgressEntriesEvent()),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => di.sl<SettingsBloc>()..add(LoadSettingsEvent()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
          buildWhen: (previous, current) =>
              current is SettingsLoaded &&
              (previous is! SettingsLoaded ||
                  previous.settings.themePreference !=
                      current.settings.themePreference),
          builder: (context, state) {
            final themeMode = state is SettingsLoaded
                ? ThemeManager.getThemeMode(state.settings.themePreference)
                : ThemeMode.system;

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const HomePage(),
            );
          }),
    );
  }
}
