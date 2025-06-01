import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:progress_tracker/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class FancyCalendar<T> extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final DateTime firstDay;
  final DateTime lastDay;
  final List<T> Function(DateTime day)? eventLoader;
  final void Function(DateTime selectedDay, DateTime focusedDay)? onDaySelected;
  final void Function(DateTime focusedDay)? onPageChanged;
  final void Function(CalendarFormat format)? onFormatChanged;
  final CalendarFormat calendarFormat;
  final CalendarStyle? calendarStyle;
  final HeaderStyle? headerStyle;
  final StartingDayOfWeek? startingDayOfWeek;

  const FancyCalendar({
    Key? key,
    required this.focusedDay,
    this.selectedDay,
    required this.firstDay,
    required this.lastDay,
    this.eventLoader,
    this.onDaySelected,
    this.onPageChanged,
    this.onFormatChanged,
    this.calendarFormat = CalendarFormat.month,
    this.calendarStyle,
    this.headerStyle,
    this.startingDayOfWeek,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Color.lerp(AppColors.surfaceDark, primaryColor, 0.05) ??
                      AppColors.surfaceDark,
                  AppColors.surfaceDark,
                ]
              : [
                  Colors.white,
                  Color.lerp(Colors.white, primaryColor, 0.03) ?? Colors.white,
                ],
        ),
      ),
      child: Column(
        children: [
          _buildCalendarHeader(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TableCalendar<T>(
              firstDay: firstDay,
              lastDay: lastDay,
              focusedDay: focusedDay,
              selectedDayPredicate: (day) =>
                  selectedDay != null && isSameDay(selectedDay!, day),
              calendarFormat: calendarFormat,
              eventLoader: eventLoader,
              startingDayOfWeek: startingDayOfWeek ?? StartingDayOfWeek.monday,
              onDaySelected: onDaySelected,
              onFormatChanged: onFormatChanged,
              onPageChanged: onPageChanged,
              calendarStyle: calendarStyle ?? _buildCalendarStyle(context),
              headerStyle: headerStyle ?? _buildHeaderStyle(context),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return null;
                  return Positioned(
                    bottom: 1,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor,
                      ),
                      width: 8,
                      height: 8,
                    ),
                  );
                },
                selectedBuilder: (context, date, _) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          HSLColor.fromColor(primaryColor)
                              .withLightness(
                                  HSLColor.fromColor(primaryColor).lightness *
                                      0.9)
                              .toColor(),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        date.day.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
                todayBuilder: (context, date, _) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final textColor = theme.brightness == Brightness.dark
        ? Colors.white
        : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.9),
            primaryColor,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Month and year with animation
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutQuart,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat.MMMM().format(focusedDay),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat.y().format(focusedDay),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Navigation buttons with ripple effect
              Row(
                children: [
                  _buildHeaderButton(
                    context,
                    Icons.arrow_back_ios_new_rounded,
                    () {
                      if (onPageChanged != null) {
                        onPageChanged!(
                            DateTime(focusedDay.year, focusedDay.month - 1));
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildHeaderButton(
                    context,
                    Icons.arrow_forward_ios_rounded,
                    () {
                      if (onPageChanged != null) {
                        onPageChanged!(
                            DateTime(focusedDay.year, focusedDay.month + 1));
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Days of week header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildWeekdayLabels(textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(
      BuildContext context, IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildWeekdayLabels(Color textColor) {
    final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return List.generate(7, (index) {
      final isWeekend = index >= 5;
      return SizedBox(
        width: 24,
        child: Text(
          weekdays[index],
          style: TextStyle(
            color: isWeekend ? Colors.white.withOpacity(0.7) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      );
    });
  }

  CalendarStyle _buildCalendarStyle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CalendarStyle(
      isTodayHighlighted: true,
      outsideDaysVisible: false,
      markersMaxCount: 3,
      markerSize: 8,
      markerDecoration: BoxDecoration(
        color: theme.colorScheme.primary,
        shape: BoxShape.circle,
      ),
      markersAnchor: 0.7,
      canMarkersOverflow: false,
      // We're using custom builders for these
      todayDecoration: const BoxDecoration(),
      selectedDecoration: const BoxDecoration(),
      // Default text styles
      defaultTextStyle: TextStyle(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        fontSize: 16,
      ),
      weekendTextStyle: TextStyle(
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        fontSize: 16,
      ),
      outsideTextStyle: TextStyle(
        color: isDark
            ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
            : AppColors.textSecondary.withValues(alpha: 0.5),
        fontSize: 16,
      ),
    );
  }

  HeaderStyle _buildHeaderStyle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return HeaderStyle(
      titleTextStyle: theme.textTheme.titleLarge!.copyWith(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
      formatButtonTextStyle: theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      formatButtonDecoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      titleCentered: false,
      formatButtonVisible: false,
      headerPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      leftChevronIcon: Icon(
        Icons.chevron_left,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
      rightChevronIcon: Icon(
        Icons.chevron_right,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
      leftChevronMargin: const EdgeInsets.only(left: 0),
      rightChevronMargin: const EdgeInsets.only(right: 0),
    );
  }
}
