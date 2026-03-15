import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../core/theme/app_colors.dart';

class ContactOption {
  final String name;
  final String email;
  final String label;

  const ContactOption({
    required this.name,
    required this.email,
    required this.label,
  });
}

class DisambiguationPicker extends StatefulWidget {
  final List<ContactOption> options;
  final ValueChanged<ContactOption> onSelected;

  const DisambiguationPicker({
    super.key,
    required this.options,
    required this.onSelected,
  });

  @override
  State<DisambiguationPicker> createState() => _DisambiguationPickerState();
}

class _DisambiguationPickerState extends State<DisambiguationPicker> {
  int? _selectedIndex;
  bool _hasSelected = false;

  void _onTap(int index) {
    if (_hasSelected) return;
    setState(() {
      _selectedIndex = index;
      _hasSelected = true;
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      widget.onSelected(widget.options[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final showCount = widget.options.length > 4 ? 4 : widget.options.length;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(showCount, (i) {
            final isSelected = _selectedIndex == i;
            return Padding(
              padding: EdgeInsets.only(bottom: i < showCount - 1 ? 6 : 0),
              child: _ContactCard(
                option: widget.options[i],
                isSelected: isSelected,
                onTap: () => _onTap(i),
              ),
            );
          }),
          if (widget.options.length > 4)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  'See all contacts →',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.violet,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final ContactOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _ContactCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.violet.withValues(alpha: 0.15)
              : const Color(0xFF1C1B22),
          border: Border.all(
            color: isSelected
                ? AppColors.violet
                : AppColors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 0.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${option.email} · ${option.label}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isSelected
                          ? AppColors.white.withValues(alpha: 0.45)
                          : AppColors.white.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Symbols.check_circle,
                  color: AppColors.violet,
                  size: 16,
                  fill: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
