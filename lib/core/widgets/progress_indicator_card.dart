import 'package:flutter/material.dart';
import 'package:beardO/core/theme/app_colors.dart';
import 'package:beardO/core/widgets/app_card.dart';

/// A beautiful card with animated progress indicator
class ProgressIndicatorCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final Color? progressColor;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ProgressIndicatorCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.icon,
    this.progressColor,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = progressColor ?? theme.colorScheme.primary;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upper content area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Circular icon with gradient background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        color,
                        color.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Optional trailing widget
                if (trailing != null) trailing!,
              ],
            ),
          ),
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: progress),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                '${(value * 100).toInt()}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              // Background track
                              Container(
                                height: 8,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surfaceVariantDark
                                      : AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              // Foreground progress
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 8,
                                width: MediaQuery.of(context).size.width *
                                    0.9 *
                                    value,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      color.withOpacity(0.7),
                                      color,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getMotivationalMessage(progress.toInt() * 100),
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _getMotivationalMessage(int rate) {
    if (rate < 30) {
      return 'Getting started is the hardest part. Keep going!';
    } else if (rate < 70) {
      return 'You\'re building a great routine. Stay consistent!';
    } else {
      return 'Excellent dedication! Your beard will thank you!';
    }
  }
}
