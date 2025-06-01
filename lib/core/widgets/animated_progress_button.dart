import 'package:flutter/material.dart';
import 'package:beardO/core/theme/app_colors.dart';

/// A beautiful animated button that shows progress and completion states
class AnimatedProgressButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isCompleted;
  final Color? backgroundColor;
  final Color? textColor;

  const AnimatedProgressButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.isCompleted = false,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  State<AnimatedProgressButton> createState() => _AnimatedProgressButtonState();
}

class _AnimatedProgressButtonState extends State<AnimatedProgressButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.backgroundColor ?? theme.colorScheme.primary;
    final textColor = widget.textColor ?? Colors.white;

    return GestureDetector(
      onTapDown: (_) {
        _animationController.forward();
      },
      onTapUp: (_) {
        _animationController.reverse();
        if (!widget.isLoading) widget.onPressed();
      },
      onTapCancel: () {
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 56,
          decoration: BoxDecoration(
            color: widget.isCompleted
                ? AppColors.success
                : (widget.isLoading
                    ? primaryColor.withOpacity(0.8)
                    : primaryColor),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            gradient: widget.isCompleted
                ? null
                : LinearGradient(
                    colors: [
                      primaryColor,
                      HSLColor.fromColor(primaryColor)
                          .withLightness(
                              HSLColor.fromColor(primaryColor).lightness * 0.8)
                          .toColor(),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              else if (widget.isCompleted)
                Icon(
                  Icons.check_circle,
                  color: textColor,
                  size: 24,
                )
              else
                Icon(
                  widget.icon,
                  color: textColor,
                  size: 24,
                ),
              if (!widget.isLoading && !widget.isCompleted)
                const SizedBox(width: 12),
              if (!widget.isLoading)
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  child: Text(
                    widget.isCompleted ? 'Completed' : widget.text,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
