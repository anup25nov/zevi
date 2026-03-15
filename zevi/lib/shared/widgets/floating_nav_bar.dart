import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/theme/app_colors.dart';

class FloatingNavBar extends StatelessWidget {
  final int activeIndex;
  final Function(int) onTabSelected;

  const FloatingNavBar({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceHighest,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNavItem(
                index: 0,
                icon: Symbols.chat_bubble,
                isActive: activeIndex == 0,
              ),
              const SizedBox(width: 8),
              _buildNavItem(
                index: 1,
                icon: Symbols.sunny,
                isActive: activeIndex == 1,
              ),
              const SizedBox(width: 8),
              _buildNavItem(
                index: 2,
                icon: Symbols.settings,
                isActive: activeIndex == 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required bool isActive,
  }) {
    return Material(
      color: isActive ? AppColors.violet : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => onTabSelected(index),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(
            icon,
            fill: isActive ? 1.0 : 0.0,
            color: isActive ? AppColors.white : AppColors.onSurfaceVariant,
            size: 24,
          ),
        ),
      ),
    );
  }
}
