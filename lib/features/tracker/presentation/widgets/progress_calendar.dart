import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:beardO/core/widgets/animated_progress_button.dart';
import 'package:beardO/core/widgets/app_card.dart';
import 'package:beardO/core/widgets/background_gradient.dart';
import 'package:beardO/core/widgets/fancy_calendar.dart';
import 'package:beardO/core/widgets/progress_entry_view_card.dart';
import 'package:beardO/features/settings/domain/entities/app_settings.dart';
import 'package:beardO/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:beardO/features/settings/presentation/bloc/settings_state.dart';
import 'package:beardO/features/tracker/domain/entities/progress_entry.dart';
import 'package:beardO/features/tracker/presentation/bloc/progress_bloc.dart';
import 'package:beardO/features/tracker/presentation/bloc/progress_event.dart';
import 'package:beardO/features/tracker/presentation/bloc/progress_state.dart';
import 'package:table_calendar/table_calendar.dart';

class ProgressCalendar extends StatefulWidget {
  const ProgressCalendar({super.key});

  @override
  State<ProgressCalendar> createState() => _ProgressCalendarState();
}

class _ProgressCalendarState extends State<ProgressCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<ProgressEntry>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    context.read<ProgressBloc>().add(GetProgressEntriesEvent());
    _loadEntriesByDate();
  }

  void _loadEntriesByDate() {
    if (_selectedDay == null) {
      return;
    }
    context
        .read<ProgressBloc>()
        .add(GetProgressEntryByDateEvent(date: _selectedDay!));
  }

  List<ProgressEntry> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  // TODO: This method will be used when FancyCalendar is updated to support the startingDayOfWeek property
  // Currently the FancyCalendar widget doesn't expose this property from TableCalendar
  // Get the starting day of week based on user settings
  StartingDayOfWeek _getStartingDayOfWeek(BuildContext context) {
    final settingsState = context.watch<SettingsBloc>().state;
    if (settingsState is SettingsLoaded) {
      switch (settingsState.settings.startWeekDay) {
        case StartWeekDay.monday:
          return StartingDayOfWeek.monday;
        case StartWeekDay.sunday:
          return StartingDayOfWeek.sunday;
        case StartWeekDay.saturday:
          return StartingDayOfWeek.saturday;
        // These are in AppSettings enum for future-proofing but not currently used in UI
        case StartWeekDay.tuesday:
        case StartWeekDay.wednesday:
        case StartWeekDay.thursday:
        case StartWeekDay.friday:
          return StartingDayOfWeek.monday; // Default for now
      }
    }
    // Default to Monday if settings aren't loaded
    return StartingDayOfWeek.monday;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Add a nice background gradient
        BackgroundGradient(
          animate: true,
          child: Container(), // Empty container as required child
        ),

        BlocConsumer<ProgressBloc, ProgressState>(
          listener: (context, state) {
            if (state is EntriesLoaded) {
              // Convert entries to event map format
              final eventMap = <DateTime, List<ProgressEntry>>{};
              for (final entry in state.entries) {
                final date =
                    DateTime(entry.date.year, entry.date.month, entry.date.day);
                if (eventMap[date] == null) {
                  eventMap[date] = [entry];
                } else {
                  eventMap[date]!.add(entry);
                }
              }
              setState(() {
                _events = eventMap;
              });
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                const SizedBox(height: 16),
                _buildCalendar(),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildSelectedDayInfo(state),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          // Get starting day of week from settings
          // Now that FancyCalendar supports startingDayOfWeek, get it from settings
          final startDay = _getStartingDayOfWeek(context);

          return FancyCalendar<ProgressEntry>(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            // Use the user-preferred start day of week from settings
            startingDayOfWeek: startDay,
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            selectedDay: _selectedDay,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadEntriesByDate();
            },
          );
        },
      ),
    );
  }

  Widget _buildSelectedDayInfo(ProgressState state) {
    if (state is ProgressLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    } else if (state is EntryLoaded && state.entry != null) {
      // Use a SingleChildScrollView to prevent overflow
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ProgressEntryViewCard(entry: state.entry!),
        ),
      );
    } else if (state is ProgressError) {
      return Center(
        child: AppCard(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_selectedDay != null) {
                      context.read<ProgressBloc>().add(
                            GetProgressEntryByDateEvent(date: _selectedDay!),
                          );
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AppCard(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.yMMMMd().format(_selectedDay!),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No entry for this date',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AnimatedProgressButton(
                      text: 'Create Entry',
                      icon: Icons.add,
                      onPressed: () {
                        context
                            .read<ProgressBloc>()
                            .add(CreateProgressEntryEvent(date: _selectedDay!));
                      }),
                ],
              ),
            ),
          ));
    }
  }
}
