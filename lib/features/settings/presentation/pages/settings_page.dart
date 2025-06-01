import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:beardO/core/widgets/animated_fade_in.dart';
import 'package:beardO/core/widgets/app_card.dart';
import 'package:beardO/core/widgets/background_gradient.dart';
import 'package:beardO/features/settings/domain/entities/app_settings.dart';
import 'package:beardO/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:beardO/features/settings/presentation/bloc/settings_event.dart';
import 'package:beardO/features/settings/presentation/bloc/settings_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Load settings when page is opened
    context.read<SettingsBloc>().add(LoadSettingsEvent());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Add a nice background gradient
          BackgroundGradient(
            animate: true,
            child: Container(), // Empty container as required child
          ),

          // Main content
          BlocConsumer<SettingsBloc, SettingsState>(
            listener: (context, state) {
              if (state is SettingsSaved) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Settings saved successfully'),
                      ],
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              } else if (state is SettingsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(child: Text(state.message)),
                      ],
                    ),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is SettingsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final settings = state is SettingsLoaded
                  ? state.settings
                  : AppSettings.initial();

              return FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: AnimatedFadeIn(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, 'Appearance'),
                        _buildThemeSelector(context, settings),
                        const SizedBox(height: 24),
                        _buildSectionHeader(context, 'Notifications'),
                        _buildNotificationsToggle(context, settings),
                        const SizedBox(height: 24),
                        _buildSectionHeader(context, 'Calendar'),
                        _buildStartWeekDaySelector(context, settings),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, AppSettings settings) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Theme Mode',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(),
          RadioListTile<ThemePreference>(
            title: const Row(
              children: [
                Icon(Icons.light_mode),
                SizedBox(width: 16),
                Text('Light Theme'),
              ],
            ),
            value: ThemePreference.light,
            groupValue: settings.themePreference,
            onChanged: (ThemePreference? value) {
              if (value != null) {
                context
                    .read<SettingsBloc>()
                    .add(SaveThemePreferenceEvent(value));
              }
            },
          ),
          RadioListTile<ThemePreference>(
            title: const Row(
              children: [
                Icon(Icons.dark_mode),
                SizedBox(width: 16),
                Text('Dark Theme'),
              ],
            ),
            value: ThemePreference.dark,
            groupValue: settings.themePreference,
            onChanged: (ThemePreference? value) {
              if (value != null) {
                context
                    .read<SettingsBloc>()
                    .add(SaveThemePreferenceEvent(value));
              }
            },
          ),
          RadioListTile<ThemePreference>(
            title: const Row(
              children: [
                Icon(Icons.devices),
                SizedBox(width: 16),
                Text('System Default'),
              ],
            ),
            value: ThemePreference.system,
            groupValue: settings.themePreference,
            onChanged: (ThemePreference? value) {
              if (value != null) {
                context
                    .read<SettingsBloc>()
                    .add(SaveThemePreferenceEvent(value));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsToggle(BuildContext context, AppSettings settings) {
    return AppCard(
      child: SwitchListTile(
        title: const Row(
          children: [
            Icon(Icons.notifications),
            SizedBox(width: 16),
            Text('Enable Notifications'),
          ],
        ),
        subtitle: const Text(
            'Get reminded morning and evening to track your progress'),
        value: settings.notificationsEnabled,
        onChanged: (bool value) {
          context
              .read<SettingsBloc>()
              .add(SaveNotificationsEnabledEvent(value));
        },
      ),
    );
  }

  Widget _buildStartWeekDaySelector(
      BuildContext context, AppSettings settings) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Start Week On',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(),
          ...StartWeekDay.values.map((day) {
            return RadioListTile<StartWeekDay>(
              title: Text(_getDayName(day)),
              value: day,
              groupValue: settings.startWeekDay,
              onChanged: (StartWeekDay? value) {
                if (value != null) {
                  context
                      .read<SettingsBloc>()
                      .add(SaveStartWeekDayEvent(value));
                }
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getDayName(StartWeekDay day) {
    switch (day) {
      case StartWeekDay.monday:
        return 'Monday';
      case StartWeekDay.tuesday:
        return 'Tuesday';
      case StartWeekDay.wednesday:
        return 'Wednesday';
      case StartWeekDay.thursday:
        return 'Thursday';
      case StartWeekDay.friday:
        return 'Friday';
      case StartWeekDay.saturday:
        return 'Saturday';
      case StartWeekDay.sunday:
        return 'Sunday';
    }
  }
}
