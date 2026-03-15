import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class SuggestionChips extends StatelessWidget {
  final ValueChanged<String> onChipTap;

  const SuggestionChips({super.key, required this.onChipTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _Chip(
          label: 'Open calendar',
          bg: AppColors.surfaceHigh,
          textColor: AppColors.onSurface,
          hasBorder: true,
          onTap: () => onChipTap('Open calendar'),
        ),
        _Chip(
          label: 'Check emails',
          bg: AppColors.surfaceHigh,
          textColor: AppColors.onSurface,
          hasBorder: true,
          onTap: () => onChipTap('Check emails'),
        ),
        _Chip(
          label: 'Start my day',
          bg: AppColors.violet,
          textColor: AppColors.white,
          hasBorder: false,
          isBold: true,
          onTap: () => onChipTap('Start my day'),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;
  final bool hasBorder;
  final bool isBold;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.bg,
    required this.textColor,
    required this.hasBorder,
    this.isBold = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: hasBorder
              ? Border.all(color: AppColors.white.withOpacity(0.05), width: 1)
              : null,
          boxShadow: !hasBorder
              ? [
                  BoxShadow(
                    color: AppColors.violet.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
