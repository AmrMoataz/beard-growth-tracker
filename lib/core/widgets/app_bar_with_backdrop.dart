import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_tracker/core/theme/app_colors.dart';

/// A beautiful app bar with backdrop design and optional search functionality
class AppBarWithBackdrop extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool enableSearch;
  final TextEditingController? searchController;
  final void Function(String)? onSearchChanged;
  final VoidCallback? onSearchClosed;
  final String searchHintText;
  final Widget? leading;
  final double expandedHeight;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final Color? backgroundColor;
  final bool? hasBackButton;
  final bool showSettings;
  final VoidCallback? onSettingsTap;

  const AppBarWithBackdrop({
    Key? key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.enableSearch = false,
    this.searchController,
    this.onSearchChanged,
    this.onSearchClosed,
    this.searchHintText = 'Search...',
    this.leading,
    this.expandedHeight = 180.0,
    this.flexibleSpace,
    this.bottom,
    this.systemOverlayStyle,
    this.backgroundColor,
    this.hasBackButton,
    this.showSettings = false,
    this.onSettingsTap,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final useBackButton = hasBackButton ?? Navigator.of(context).canPop();

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: true,
      pinned: true,
      snap: false,
      centerTitle: centerTitle,
      leading: useBackButton && leading == null
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.pop(context),
            )
          : leading,
      title: enableSearch && searchController != null
          ? _SearchField(
              controller: searchController!,
              onChanged: onSearchChanged,
              onClosed: onSearchClosed,
              hintText: searchHintText,
            )
          : Text(title),
      actions: <Widget>[
        if (actions != null) ...(actions!),
        if (showSettings)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: onSettingsTap,
          ),
      ],
      backgroundColor: backgroundColor ??
          (isDark ? AppColors.surfaceDark : AppColors.surface),
      systemOverlayStyle: systemOverlayStyle ??
          (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark),
      elevation: 0,
      flexibleSpace: flexibleSpace ?? _buildDefaultFlexibleSpace(context),
      bottom: bottom,
    );
  }

  Widget _buildDefaultFlexibleSpace(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return FlexibleSpaceBar(
      background: Stack(
        children: [
          // Gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor,
                    HSLColor.fromColor(primaryColor)
                        .withLightness(
                            HSLColor.fromColor(primaryColor).lightness * 0.8)
                        .toColor(),
                  ],
                ),
              ),
            ),
          ),
          // Pattern overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(
                painter: _PatternPainter(),
              ),
            ),
          ),
          // Content with title and subtitle
          Positioned(
            left: 24,
            bottom: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!enableSearch) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Track your daily beard growth progress',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      collapseMode: CollapseMode.parallax,
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final VoidCallback? onClosed;
  final String hintText;

  const _SearchField({
    required this.controller,
    this.onChanged,
    this.onClosed,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.15)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark
                ? Colors.white.withOpacity(0.7)
                : AppColors.textSecondary,
            fontSize: 16,
          ),
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.white,
            size: 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    controller.clear();
                    if (onChanged != null) onChanged!('');
                    if (onClosed != null) onClosed!();
                  },
                )
              : null,
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw wavy lines
    final path = Path();
    final width = size.width;
    final height = size.height;

    for (var i = 0; i < 5; i++) {
      final startY = height * 0.2 + (i * height * 0.15);
      path.moveTo(0, startY);

      for (var x = 0.0; x < width; x += width / 20) {
        final waveHeight = height * 0.05;
        final y = startY + sin(x / 30) * waveHeight;
        path.lineTo(x, y);
      }
    }

    // Draw circles
    for (var i = 0; i < 10; i++) {
      final x = width * (i / 10) + (width / 20);
      final y = height * 0.85 - (i % 3) * (height * 0.1);
      final radius = (i % 3 + 1) * 10.0;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Helper function for sine calculation
double sin(double x) {
  return x - (2 * pi * (x / (2 * pi)).floor());
}

const double pi = 3.1415926535897932;
