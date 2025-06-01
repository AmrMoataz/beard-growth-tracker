import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:progress_tracker/core/di/injection_container.dart' as di;
import 'package:progress_tracker/core/utils/notification_service.dart';
import 'package:progress_tracker/core/widgets/animated_fade_in.dart';
import 'package:progress_tracker/core/widgets/app_bar_with_backdrop.dart';
import 'package:progress_tracker/core/widgets/background_gradient.dart';
import 'package:progress_tracker/core/widgets/fancy_bottom_navigation.dart';
import 'package:progress_tracker/core/widgets/progress_entry_card.dart';
import 'package:progress_tracker/features/settings/presentation/pages/settings_page.dart';
import 'package:progress_tracker/features/tracker/presentation/bloc/progress_bloc.dart';
import 'package:progress_tracker/features/tracker/presentation/bloc/progress_event.dart';
import 'package:progress_tracker/features/tracker/presentation/bloc/progress_state.dart';
import 'package:progress_tracker/features/tracker/presentation/widgets/dashboard_widget.dart';
import 'package:progress_tracker/features/tracker/presentation/widgets/progress_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final NotificationService _notificationService = di.sl<NotificationService>();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadTodayEntry();
  }

  Future<void> _initNotifications() async {
    await _notificationService.init();
    // Setup default reminders at 9 AM and 9 PM
    await _notificationService.scheduleDailyReminders(9, 21);
  }

  void _loadTodayEntry() {
    context.read<ProgressBloc>().add(GetTodayProgressEvent());
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Method to determine which page to show based on selected index
  Widget _getPage() {
    switch (_selectedIndex) {
      case 0: // Today
        return _buildTodayTab();
      case 1: // Calendar
        return const ProgressCalendar();
      case 2: // Dashboard
        return const DashboardWidget();
      default:
        return _buildTodayTab();
    }
  }

  // Handle bottom navigation bar taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Load today's entry when switching back to Today tab
    if (index == 0) {
      _loadTodayEntry();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom app bar with backdrop
          AppBarWithBackdrop(
            title: 'Beard Growth Tracker',
            expandedHeight: 160,
            showSettings: true,
            onSettingsTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),

          // Main content
          SliverFillRemaining(
            fillOverscroll: true,
            child: AnimatedFadeIn(
              child: _getPage(),
            ),
          ),
        ],
      ),

      // Custom fancy bottom navigation
      bottomNavigationBar: FancyBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          FancyBottomNavigationItem(
            title: 'Today',
            icon: Icons.today_outlined,
            activeIcon: Icons.today,
          ),
          FancyBottomNavigationItem(
            title: 'Calendar',
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month,
          ),
          FancyBottomNavigationItem(
            title: 'Dashboard',
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTab() {
    return Stack(
      children: [
        // Add a nice background gradient
        BackgroundGradient(
          animate: true,
          child: Container(), // Empty container as required child
        ),

        BlocBuilder<ProgressBloc, ProgressState>(
          builder: (context, state) {
            if (state is ProgressLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is TodayEntryLoaded && state.entry != null) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ProgressEntryCard(entry: state.entry!),
              );
            } else if (state is EntryCreated || state is EntryLoaded) {
              final entry = state is EntryCreated
                  ? state.entry
                  : (state as EntryLoaded).entry;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: entry != null
                    ? ProgressEntryCard(entry: entry)
                    : const SizedBox.shrink(),
              );
            } else if (state is ProgressError) {
              return Center(
                child: AnimatedFadeIn(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .error
                            .withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.message}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadTodayEntry,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              // Only create a new entry if we haven't already tried to load today's entry
              // This prevents an infinite loop of entry creation
              if (!(state is TodayEntryLoaded)) {
                context
                    .read<ProgressBloc>()
                    .add(CreateProgressEntryEvent(date: DateTime.now()));
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ],
    );
  }
}
