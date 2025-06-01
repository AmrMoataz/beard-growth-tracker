import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:beardO/core/widgets/animated_fade_in.dart';
import 'package:beardO/core/widgets/background_gradient.dart';
import 'package:beardO/core/widgets/progress_entry_card.dart';
import 'package:beardO/core/widgets/progress_indicator_card.dart';
import 'package:beardO/features/tracker/domain/entities/progress_entry.dart';
import 'package:beardO/features/tracker/presentation/bloc/progress_bloc.dart';
import 'package:beardO/features/tracker/presentation/bloc/progress_event.dart';
import 'package:beardO/features/tracker/presentation/bloc/progress_state.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<ProgressBloc>().add(GetProgressEntriesEvent());
    context.read<ProgressBloc>().add(GetCompletionRateEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgressBloc, ProgressState>(
      builder: (context, state) {
        // Show progress indicator while loading
        if (state is ProgressLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            // Add a nice background gradient
            BackgroundGradient(
              animate: true,
              child: Container(), // Empty container as required child
            ),

            // Main content
            RefreshIndicator(
              onRefresh: () async {
                _loadData();
                return Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: AnimatedFadeIn(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCompletionRateCard(context, state),
                      const SizedBox(height: 20),
                      _buildStreak(context, state),
                      const SizedBox(height: 20),
                      _buildTipOfTheDay(),
                      const SizedBox(height: 20),
                      if (state is EntriesLoaded)
                        _buildRecentProgress(context, state),
                      // Add some bottom padding for comfort
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompletionRateCard(BuildContext context, ProgressState state) {
    double completionRate = 0;

    if (state is CompletionRateLoaded) {
      completionRate = state.overallRate; // Already a value between 0-1
    }

    return AnimatedFadeIn(
      delay: const Duration(milliseconds: 300),
      child: ProgressIndicatorCard(
        title: 'Completion Rate',
        subtitle: 'Your beard growth progress',
        progress: completionRate,
        progressColor: _getColorForRate((completionRate * 100).toInt()),
        icon: Icons.local_fire_department_rounded,
        onTap: () {
          // Navigate to completion rate details screen
        },
      ),
    );
  }

  Widget _buildStreak(BuildContext context, ProgressState state) {
    int streakDays = 0;

    if (state is EntriesLoaded) {
      streakDays = _calculateCurrentStreak(state.entries);
    }

    return AnimatedFadeIn(
      delay: const Duration(milliseconds: 500),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Streak',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.5, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: const Icon(Icons.local_fire_department,
                            color: Colors.orange, size: 36),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: streakDays),
                    duration: const Duration(milliseconds: 1200),
                    builder: (context, value, child) {
                      return Text(
                        '$value',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'days',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                streakDays > 0
                    ? 'Keep up the good work! Your beard is loving the consistency.'
                    : 'Start your streak today by logging your morning and evening application.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipOfTheDay() {
    final tips = [
      'Massage the serum into your skin for better absorption.',
      'Consistency is key for beard growth results.',
      'Keep your beard clean and wash it regularly.',
      'Use a beard brush to distribute oils evenly.',
      'Be patient! Beard growth takes time.',
      'Stay hydrated for healthier hair growth.',
      'Consider taking biotin supplements for faster growth.',
      'Reduce stress to promote better hair growth.',
      'Get enough sleep for optimal growth hormone production.',
      'Eat a balanced diet rich in proteins and vitamins.',
    ];

    // Select a tip based on the day of the year to keep it consistent for the day
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final tipIndex = dayOfYear % tips.length;

    return AnimatedFadeIn(
      delay: const Duration(milliseconds: 700),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.5, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: const Icon(
                          Icons.lightbulb,
                          color: Colors.amber,
                          size: 28,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tip of the Day',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                tips[tipIndex],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentProgress(BuildContext context, EntriesLoaded state) {
    final recentEntries = List.of(state.entries);
    recentEntries.sort((a, b) => b.date.compareTo(a.date));
    final displayEntries = recentEntries.take(5).toList();

    return AnimatedFadeIn(
      delay: const Duration(milliseconds: 900),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...displayEntries.asMap().entries.map((entry) {
                // Add staggered animation delay for each item
                return AnimatedFadeIn(
                  delay: Duration(milliseconds: 300 + (entry.key * 100)),
                  offset: const Offset(0, 10),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ProgressEntryCard(
                      entry: entry.value,
                      onTap: () {
                        // Navigate to detail screen or show modal with entry details
                      },
                    ),
                  ),
                );
              }),
              if (displayEntries.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'No recent entries. Start tracking today!',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateCurrentStreak(List<ProgressEntry> entries) {
    if (entries.isEmpty) return 0;

    // Sort entries by date descending (newest first)
    final sortedEntries = List<ProgressEntry>.from(entries)
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime? lastDate;

    for (final entry in sortedEntries) {
      if (lastDate == null) {
        // First entry in the streak
        lastDate = entry.date;
        if (entry.morningApplicationDone || entry.eveningApplicationDone) {
          streak = 1;
        } else {
          return 0; // First entry has no application, streak is 0
        }
      } else {
        // Check if this entry is for the previous day
        final expectedDate = DateTime(
          lastDate.year,
          lastDate.month,
          lastDate.day - 1,
        );

        // Compare year, month, and day instead of direct equality
        final sameDate = entry.date.year == expectedDate.year &&
            entry.date.month == expectedDate.month &&
            entry.date.day == expectedDate.day;

        if (sameDate) {
          if (entry.morningApplicationDone || entry.eveningApplicationDone) {
            streak++;
            lastDate = entry.date;
          } else {
            // Break the streak if no application was done
            break;
          }
        } else {
          // Break the streak if there's a gap in dates
          break;
        }
      }
    }

    return streak;
  }

  Color _getColorForRate(int rate) {
    if (rate < 30) {
      return Colors.red;
    } else if (rate < 70) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
