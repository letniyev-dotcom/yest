import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import '../theme/app_theme.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _icons = [
    SolarIconsBold.home2,
    SolarIconsBold.cupHot,
    SolarIconsBold.calendar,
    SolarIconsBold.graphUp,
    SolarIconsBold.user,
  ];

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: _NavBackground(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      _icons.length,
                      (i) => _NavItem(
                        icon: _icons[i],
                        isActive: currentIndex == i,
                        accent: lc.accent,
                        inactiveColor: lc.text2,
                        onTap: () => onTap(i),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBackground extends StatelessWidget {
  final Widget child;
  const _NavBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xE0161616)
            : Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.12),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color accent;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.accent,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 52,
        height: 52,
        child: Center(
          child: Icon(
            icon,
            size: 26,
            color: isActive ? accent : inactiveColor,
          ),
        ),
      ),
    );
  }
}
