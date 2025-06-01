import 'package:flutter/material.dart';
import 'package:beardO/core/theme/app_colors.dart';

/// A beautiful animated gradient background for pages
class BackgroundGradient extends StatelessWidget {
  final Widget child;
  final bool animate;
  final List<Color>? colors;

  const BackgroundGradient({
    Key? key,
    required this.child,
    this.animate = true,
    this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default colors based on theme
    final defaultColors = isDark
        ? [
            AppColors.backgroundDark,
            Color.lerp(AppColors.backgroundDark, AppColors.primary, 0.05) ??
                AppColors.backgroundDark,
            AppColors.backgroundDark,
          ]
        : [
            AppColors.background,
            Color.lerp(AppColors.background, AppColors.primary, 0.03) ??
                AppColors.background,
            AppColors.background,
          ];

    final gradientColors = colors ?? defaultColors;

    return Stack(
      children: [
        // Animated background
        Positioned.fill(
          child: animate
              ? _AnimatedGradientBackground(colors: gradientColors)
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: gradientColors,
                    ),
                  ),
                ),
        ),
        // Patterns overlay with low opacity
        Positioned.fill(
          child: _BackgroundPattern(isDark: isDark),
        ),
        // Content
        child,
      ],
    );
  }
}

class _AnimatedGradientBackground extends StatefulWidget {
  final List<Color> colors;

  const _AnimatedGradientBackground({required this.colors});

  @override
  _AnimatedGradientBackgroundState createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<_AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.colors,
              stops: [
                0.0,
                _controller.value,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BackgroundPattern extends StatelessWidget {
  final bool isDark;

  const _BackgroundPattern({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDark ? 0.03 : 0.02,
      child: CustomPaint(
        painter: _PatternPainter(
          color: isDark ? Colors.white : Colors.black,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const double gap = 20;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw a grid pattern
    for (double i = 0; i < size.width; i += gap) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += gap) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Draw some circles for extra visual interest
    final int numCircles = 10;
    final circleRadius = size.width / 10;
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;

    for (int i = 0; i < numCircles; i++) {
      final double x =
          (i * size.width / numCircles) + (size.width / (numCircles * 2));
      final double y = (i % 3 + 1) * size.height / 4;
      canvas.drawCircle(Offset(x, y), circleRadius, circlePaint);
    }
  }

  @override
  bool shouldRepaint(_PatternPainter oldDelegate) => false;
}
