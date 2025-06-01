import 'dart:ui';
import 'package:flutter/material.dart';

/// A beautiful glassmorphic container with blur effect
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color borderColor;
  final double borderWidth;
  final double blur;
  final Color? backgroundColor;
  final double backgroundOpacity;
  final VoidCallback? onTap;
  
  const GlassmorphicContainer({
    Key? key,
    required this.child,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.borderColor = Colors.white,
    this.borderWidth = 1.5,
    this.blur = 10.0,
    this.backgroundColor,
    this.backgroundOpacity = 0.2,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = backgroundColor ?? 
        (isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6));
    
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              splashColor: onTap != null ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
              highlightColor: onTap != null ? theme.colorScheme.primary.withOpacity(0.05) : Colors.transparent,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: bgColor.withOpacity(backgroundOpacity),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: borderColor.withOpacity(isDark ? 0.2 : 0.4),
                    width: borderWidth,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
