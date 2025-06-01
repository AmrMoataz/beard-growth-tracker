import 'package:flutter/material.dart';
import 'package:beardO/core/theme/app_colors.dart';

class FancyBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final List<FancyBottomNavigationItem> items;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final double height;
  final double iconSize;
  final double fontSize;
  final Curve animationCurve;
  final Duration animationDuration;

  const FancyBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.height = 70.0,
    this.iconSize = 24.0,
    this.fontSize = 12.0,
    this.animationCurve = Curves.easeOutQuint,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<FancyBottomNavigation> createState() => _FancyBottomNavigationState();
}

class _FancyBottomNavigationState extends State<FancyBottomNavigation> {
  late List<GlobalKey> _navBarItemKeys;

  @override
  void initState() {
    super.initState();
    _navBarItemKeys =
        List.generate(widget.items.length, (index) => GlobalKey());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: widget.height,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            (isDark ? AppColors.surfaceDark : Colors.white),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black26 : Colors.black12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background indicator
          _buildIndicator(),
          // Nav items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(widget.items.length, (index) {
              return _buildNavItem(index);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    if (widget.currentIndex >= 0 &&
        widget.currentIndex < _navBarItemKeys.length) {
      final GlobalKey navBarItemKey = _navBarItemKeys[widget.currentIndex];
      final RenderBox? renderBox =
          navBarItemKey.currentContext?.findRenderObject() as RenderBox?;

      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final itemWidth = renderBox.size.width;
        final itemCenterX =
            position.dx + itemWidth / 2 - MediaQuery.of(context).padding.left;

        return Positioned(
          top: 10,
          left: itemCenterX - 30,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            curve: widget.animationCurve,
            duration: widget.animationDuration,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.9 + (0.1 * value),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: widget.activeColor ??
                          Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildNavItem(int index) {
    final bool isSelected = index == widget.currentIndex;
    final theme = Theme.of(context);
    final Color activeColor = widget.activeColor ?? theme.colorScheme.primary;
    final Color inactiveColor = widget.inactiveColor ??
        (theme.brightness == Brightness.dark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondary);

    return Expanded(
      key: _navBarItemKeys[index],
      child: InkWell(
        onTap: () => widget.onTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: widget.animationDuration,
          curve: widget.animationCurve,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with animation
              AnimatedContainer(
                duration: widget.animationDuration,
                curve: widget.animationCurve,
                transform: Matrix4.identity()
                  ..translate(0.0, isSelected ? -4.0 : 0.0),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.8, end: isSelected ? 1.0 : 0.8),
                  curve: widget.animationCurve,
                  duration: widget.animationDuration,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Icon(
                        isSelected
                            ? widget.items[index].activeIcon
                            : widget.items[index].icon,
                        color: isSelected ? activeColor : inactiveColor,
                        size: widget.iconSize,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
              // Label with animation
              AnimatedDefaultTextStyle(
                duration: widget.animationDuration,
                curve: widget.animationCurve,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? activeColor : inactiveColor,
                ),
                child: Text(widget.items[index].title),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FancyBottomNavigationItem {
  final String title;
  final IconData icon;
  final IconData activeIcon;

  const FancyBottomNavigationItem({
    required this.title,
    required this.icon,
    required this.activeIcon,
  });
}
