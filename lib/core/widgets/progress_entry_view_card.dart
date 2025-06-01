import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:beardO/core/widgets/app_card.dart';
import 'package:beardO/features/tracker/domain/entities/progress_entry.dart';
import 'package:beardO/core/widgets/photo_viewer.dart';
import 'package:beardO/core/widgets/progress_entry_card.dart';
import 'package:beardO/features/tracker/presentation/bloc/progress_bloc.dart';

/// A simple read-only card to display progress entry information
/// Used for calendar view and history displays where editing is not required
class ProgressEntryViewCard extends StatelessWidget {
  final ProgressEntry entry;
  final VoidCallback? onTap;

  const ProgressEntryViewCard({
    Key? key,
    required this.entry,
    this.onTap,
  }) : super(key: key);

  void _openEditDialog(BuildContext context) {
    // Get the current ProgressBloc from the parent context
    final progressBloc = context.read<ProgressBloc>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            // Provide ProgressBloc to the dialog's widget tree
            child: BlocProvider.value(
              value: progressBloc,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Edit Entry'),
                  actions: [
                    // Add a save button to make it clear changes will be saved
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text(
                        'DONE',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ProgressEntryCard(entry: entry),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date header with gradient
          _buildDateHeader(context),

          // Content section
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 250),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Application status indicators
                  _buildApplicationStatus(context),

                  // Notes section (if any)
                  if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildNotesSection(context),
                  ],

                  // Photo thumbnail (if any)
                  if (entry.photoPath != null &&
                      entry.photoPath!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildPhotoThumbnail(context),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final isToday = DateUtils.isSameDay(today, entry.date);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.tertiary,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Date display
          Text(
            DateFormat.yMMMEd().format(entry.date),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          // Right side elements: TODAY badge and/or Edit button
          Row(
            children: [
              if (isToday)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'TODAY',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              // Edit button
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _openEditDialog(context),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationStatus(BuildContext context) {
    return Row(
      children: [
        _buildStatusIndicator(
          context: context,
          icon: Icons.wb_sunny,
          label: 'Morning',
          isDone: entry.morningApplicationDone,
          color: Colors.amber,
        ),
        const SizedBox(width: 12),
        _buildStatusIndicator(
          context: context,
          icon: Icons.nights_stay,
          label: 'Evening',
          isDone: entry.eveningApplicationDone,
          color: Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildStatusIndicator({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isDone,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDone
                ? color.withOpacity(0.2)
                : (isDark ? Colors.grey[800] : Colors.grey[200]),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 14,
            color:
                isDone ? color : (isDark ? Colors.grey[600] : Colors.grey[400]),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDone
                ? theme.colorScheme.onSurface
                : (isDark ? Colors.grey[400] : Colors.grey[600]),
            fontWeight: isDone ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.notes_rounded,
              size: 14,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Notes',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w100,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          entry.notes ?? '',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildPhotoThumbnail(BuildContext context) {
    return PhotoViewer(
      photoPath: entry.photoPath,
      compact: true,
    );
  }
}
