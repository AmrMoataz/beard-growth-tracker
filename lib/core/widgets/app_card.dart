import 'package:flutter/material.dart';
import 'package:progress_tracker/core/theme/app_colors.dart';

enum CardVariant {
  primary,
  secondary,
  accent,
  neutral,
}

/// A beautifully styled card with multiple variants
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final double borderRadius;
  final CardVariant variant;
  final VoidCallback? onTap;
  final bool hasHoverEffect;
  final Color? backgroundColor;
  final Color? shadowColor;
  final BorderSide? borderSide;
  final Gradient? gradient;

  const AppCard({
    Key? key,
    required this.child,
    this.padding,
    this.elevation,
    this.borderRadius = 16,
    this.variant = CardVariant.neutral,
    this.onTap,
    this.hasHoverEffect = true,
    this.backgroundColor,
    this.shadowColor,
    this.borderSide,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine card background color based on variant
    final Color bgColor = backgroundColor ?? _getBackgroundColor(theme, isDark);
    final Color shadow = shadowColor ?? _getShadowColor(theme, isDark);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: elevation == 0
            ? []
            : [
                BoxShadow(
                  color: shadow.withValues(alpha: isDark ? 0.5 : 0.15),
                  blurRadius: (elevation ?? 4) * 2,
                  offset: Offset(0, (elevation ?? 4) * 0.5),
                ),
              ],
        gradient: gradient,
        border: borderSide != null
            ? Border.fromBorderSide(borderSide!)
            : _getBorder(theme, isDark),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: onTap != null
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          highlightColor: onTap != null
              ? theme.colorScheme.primary.withValues(alpha: 0.05)
              : Colors.transparent,
          hoverColor: (onTap != null && hasHoverEffect)
              ? theme.colorScheme.primary.withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(ThemeData theme, bool isDark) {
    switch (variant) {
      case CardVariant.primary:
        return theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1);
      case CardVariant.secondary:
        return theme.colorScheme.secondary.withOpacity(isDark ? 0.2 : 0.1);
      case CardVariant.accent:
        return AppColors.accent.withOpacity(isDark ? 0.2 : 0.1);
      case CardVariant.neutral:
      default:
        return isDark ? AppColors.surfaceDark : AppColors.surface;
    }
  }

  Color _getShadowColor(ThemeData theme, bool isDark) {
    switch (variant) {
      case CardVariant.primary:
        return theme.colorScheme.primary;
      case CardVariant.secondary:
        return theme.colorScheme.secondary;
      case CardVariant.accent:
        return AppColors.accent;
      case CardVariant.neutral:
      default:
        return isDark ? AppColors.shadowDark : AppColors.shadow;
    }
  }

  Border? _getBorder(ThemeData theme, bool isDark) {
    // Only add borders in specific cases for better design
    if (variant == CardVariant.neutral && isDark) {
      return Border.all(
        color: AppColors.dividerDark,
        width: 1.0,
      );
    }

    if (variant != CardVariant.neutral) {
      Color borderColor;
      switch (variant) {
        case CardVariant.primary:
          borderColor = theme.colorScheme.primary;
          break;
        case CardVariant.secondary:
          borderColor = theme.colorScheme.secondary;
          break;
        case CardVariant.accent:
          borderColor = AppColors.accent;
          break;
        default:
          borderColor = Colors.transparent;
      }

      return Border.all(
        color: borderColor.withOpacity(0.3),
        width: 1.0,
      );
    }

    return null;
  }
}
