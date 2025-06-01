import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:beardO/core/theme/app_colors.dart';
import 'package:beardO/core/widgets/animated_fade_in.dart';
import 'package:beardO/core/widgets/app_card.dart';
import 'package:beardO/core/widgets/photo_viewer.dart';
import 'package:beardO/features/tracker/domain/entities/progress_entry.dart';
import 'package:beardO/features/tracker/presentation/bloc/progress_bloc.dart';
import 'package:beardO/features/tracker/presentation/bloc/progress_event.dart';
import 'package:beardO/features/tracker/presentation/bloc/progress_state.dart';

/// A beautiful animated card to display progress entry information with editing capabilities
class ProgressEntryCard extends StatefulWidget {
  final ProgressEntry entry;
  final VoidCallback? onTap;
  final Animation<double>? animation;

  const ProgressEntryCard({
    Key? key,
    required this.entry,
    this.onTap,
    this.animation,
  }) : super(key: key);

  @override
  State<ProgressEntryCard> createState() => _ProgressEntryCardState();
}

class _ProgressEntryCardState extends State<ProgressEntryCard> {
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    if (_notesController.text.isEmpty) {
      _notesController.text = widget.entry.notes ?? '';
    }
    _loadImage();
  }

  void _loadImage() {
    final hasPhoto =
        widget.entry.photoPath != null && widget.entry.photoPath!.isNotEmpty;
    if (hasPhoto) {
      setState(() {
        _imageFile = File(widget.entry.photoPath!);
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _toggleMorningApplication() {
    // Get the current entry from the bloc state if available
    ProgressEntry entryToUse = widget.entry;
    if (context.read<ProgressBloc>().state is MorningApplicationToggled) {
      final state =
          context.read<ProgressBloc>().state as MorningApplicationToggled;
      if (state.entry.id == widget.entry.id) {
        entryToUse = state.entry;
      }
    } else if (context.read<ProgressBloc>().state
        is EveningApplicationToggled) {
      final state =
          context.read<ProgressBloc>().state as EveningApplicationToggled;
      if (state.entry.id == widget.entry.id) {
        entryToUse = state.entry;
      }
    }

    context.read<ProgressBloc>().add(
          ToggleMorningApplicationEvent(entry: entryToUse),
        );

    // Force UI update by triggering a setState
    setState(() {});
  }

  void _toggleEveningApplication() {
    // Get the current entry from the bloc state if available
    ProgressEntry entryToUse = widget.entry;
    if (context.read<ProgressBloc>().state is MorningApplicationToggled) {
      final state =
          context.read<ProgressBloc>().state as MorningApplicationToggled;
      if (state.entry.id == widget.entry.id) {
        entryToUse = state.entry;
      }
    } else if (context.read<ProgressBloc>().state
        is EveningApplicationToggled) {
      final state =
          context.read<ProgressBloc>().state as EveningApplicationToggled;
      if (state.entry.id == widget.entry.id) {
        entryToUse = state.entry;
      }
    }

    context.read<ProgressBloc>().add(
          ToggleEveningApplicationEvent(entry: entryToUse),
        );

    // Force UI update by triggering a setState
    setState(() {});
  }

  void _updateNotes() {
    if (_formKey.currentState!.validate()) {
      // Get the current entry from the bloc state if available
      ProgressEntry entryToUse = widget.entry;
      if (context.read<ProgressBloc>().state is MorningApplicationToggled) {
        final state =
            context.read<ProgressBloc>().state as MorningApplicationToggled;
        if (state.entry.id == widget.entry.id) {
          entryToUse = state.entry;
        }
      } else if (context.read<ProgressBloc>().state
          is EveningApplicationToggled) {
        final state =
            context.read<ProgressBloc>().state as EveningApplicationToggled;
        if (state.entry.id == widget.entry.id) {
          entryToUse = state.entry;
        }
      } else if (context.read<ProgressBloc>().state is NoteUpdated) {
        final state = context.read<ProgressBloc>().state as NoteUpdated;
        if (state.entry.id == widget.entry.id) {
          entryToUse = state.entry;
        }
      }

      // Update notes via bloc
      context.read<ProgressBloc>().add(
            UpdateNotesEvent(
              entry: entryToUse,
              notes: _notesController.text,
            ),
          );

      // UI feedback
      FocusScope.of(context).unfocus();
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Notes updated'),
            ],
          ),
          backgroundColor: theme.colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Force UI update
      setState(() {});
    }
  }

  Future<void> _takePicture() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      if (!mounted) return;

      context.read<ProgressBloc>().add(
            SaveProgressPhotoEvent(
              entryId: widget.entry.id,
              photo: File(pickedFile.path),
            ),
          );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      if (!mounted) return;

      context.read<ProgressBloc>().add(
            SaveProgressPhotoEvent(
              entryId: widget.entry.id,
              photo: File(pickedFile.path),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get the current entry data that might have been updated via the bloc
    // This makes the UI reactive to changes in the entry
    ProgressEntry currentEntry = widget.entry;
    if (context.read<ProgressBloc>().state is MorningApplicationToggled) {
      final state =
          context.read<ProgressBloc>().state as MorningApplicationToggled;
      if (state.entry.id == widget.entry.id) {
        currentEntry = state.entry;
      }
    } else if (context.read<ProgressBloc>().state
        is EveningApplicationToggled) {
      final state =
          context.read<ProgressBloc>().state as EveningApplicationToggled;
      if (state.entry.id == widget.entry.id) {
        currentEntry = state.entry;
      }
    } else if (context.read<ProgressBloc>().state is NoteUpdated) {
      final state = context.read<ProgressBloc>().state as NoteUpdated;
      if (state.entry.id == widget.entry.id) {
        currentEntry = state.entry;
      }
    }

    return BlocListener<ProgressBloc, ProgressState>(
      listenWhen: (previous, current) {
        return (current is MorningApplicationToggled &&
                current.entry.id == widget.entry.id) ||
            (current is EveningApplicationToggled &&
                current.entry.id == widget.entry.id) ||
            (current is NoteUpdated && current.entry.id == widget.entry.id) ||
            (current is PhotoSaved && current.entryId == widget.entry.id) ||
            current is ProgressError;
      },
      listener: (context, state) {
        if (state is PhotoSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Photo saved successfully'),
                ],
              ),
              backgroundColor: theme.colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else if (state is ProgressError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Error: ${state.message}'),
                ],
              ),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: BlocBuilder<ProgressBloc, ProgressState>(
        buildWhen: (previous, current) {
          return (current is MorningApplicationToggled &&
                  current.entry.id == widget.entry.id) ||
              (current is EveningApplicationToggled &&
                  current.entry.id == widget.entry.id) ||
              (current is NoteUpdated && current.entry.id == widget.entry.id);
        },
        builder: (context, state) {
          // Get the latest entry state when a toggle or update happens
          ProgressEntry entryToUse = currentEntry;
          if (state is MorningApplicationToggled &&
              state.entry.id == widget.entry.id) {
            entryToUse = state.entry;
          } else if (state is EveningApplicationToggled &&
              state.entry.id == widget.entry.id) {
            entryToUse = state.entry;
          } else if (state is NoteUpdated &&
              state.entry.id == widget.entry.id) {
            entryToUse = state.entry;
            _notesController.text = entryToUse.notes ?? '';
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: _buildCardContent(context, theme, isDark, entryToUse),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardContent(
      BuildContext context, ThemeData theme, bool isDark, ProgressEntry entry) {
    final Widget card = AppCard(
      onTap: widget.onTap,
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header with gradient
          _buildDateHeader(context, entry),

          // Content section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Application status with interactive toggle
                _buildApplicationStatus(context, entry),

                // Notes section with editing capabilities
                const SizedBox(height: 20),
                _buildNotesEditorSection(context, entry),

                // Photo section with camera/gallery options
                const SizedBox(height: 20),
                _buildPhotoSection(context, entry),
              ],
            ),
          ),
        ],
      ),
    );

    // Apply animation if provided
    if (widget.animation != null) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: widget.animation!,
          curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: widget.animation!,
            curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
          )),
          child: card,
        ),
      );
    }

    return card;
  }

  Widget _buildDateHeader(BuildContext context, ProgressEntry entry) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            HSLColor.fromColor(primaryColor)
                .withLightness(
                    HSLColor.fromColor(primaryColor).lightness * 0.85)
                .toColor(),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Date info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(entry.date),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat.EEEE().format(entry.date),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Day indicator
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                entry.date.day.toString(),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationStatus(BuildContext context, ProgressEntry entry) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Application Status',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _toggleMorningApplication();
                },
                child: _buildApplicationIndicator(
                  context,
                  'Morning',
                  entry.morningApplicationDone,
                  Icons.wb_sunny,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _toggleEveningApplication();
                },
                child: _buildApplicationIndicator(
                  context,
                  'Evening',
                  entry.eveningApplicationDone,
                  Icons.nightlight_round,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApplicationIndicator(
      BuildContext context, String title, bool isDone, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedFadeIn(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isDone
              ? (isDark
                  ? theme.colorScheme.primary.withOpacity(0.2)
                  : theme.colorScheme.primary.withOpacity(0.1))
              : (isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariant),
          borderRadius: BorderRadius.circular(10),
          border: isDone
              ? Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                  width: 1.5,
                )
              : Border.all(
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                  width: 1,
                ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDone
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.5),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDone
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDone ? 'Applied' : 'Skipped',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDone
                          ? theme.colorScheme.primary.withOpacity(0.8)
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: isDone ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isDone
                  ? Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 22,
                    )
                  : Icon(
                      Icons.circle_outlined,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                      size: 22,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Notes editor section with text field and save button
  Widget _buildNotesEditorSection(BuildContext context, ProgressEntry entry) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.notes,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Notes',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add notes about your application...',
            fillColor: isDark
                ? AppColors.surfaceVariantDark
                : AppColors.surfaceVariant,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.divider,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.divider,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          style: theme.textTheme.bodyMedium,
          onEditingComplete: _updateNotes,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _updateNotes,
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Save Notes'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  // Photo section with thumbnail and camera/gallery buttons
  Widget _buildPhotoSection(BuildContext context, ProgressEntry entry) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.photo,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Photo',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_imageFile != null ||
            (widget.entry.photoPath != null &&
                widget.entry.photoPath!.isNotEmpty)) ...[
          // Using the new PhotoViewer widget
          PhotoViewer(
            imageFile: _imageFile,
            photoPath: widget.entry.photoPath,
            height: 160,
            compact: false,
            showTitle: false, // We already show the title above
          ),
        ] else ...[
          // Placeholder with buttons when no photo
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.divider,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  color: theme.colorScheme.primary.withOpacity(0.6),
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'No progress photo yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Photo action buttons
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _takePicture,
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text('Camera'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library, size: 18),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
