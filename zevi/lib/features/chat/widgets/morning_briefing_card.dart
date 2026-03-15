import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../core/theme/app_colors.dart';

class BentoItem {
  final IconData icon;
  final String label;
  final String value;

  const BentoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class MorningBriefingCard extends StatelessWidget {
  final String userName;
  final List<BentoItem> bentoItems;
  final List<String> chips;
  final ValueChanged<String>? onChipTap;

  const MorningBriefingCard({
    super.key,
    required this.userName,
    required this.bentoItems,
    this.chips = const ['Open calendar', 'Check emails', 'Start my day'],
    this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left violet accent line
        Container(
          width: 3,
          constraints: const BoxConstraints(minHeight: 360),
          decoration: BoxDecoration(
            color: AppColors.violet,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Bubble Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.violet,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Symbols.sunny,
                      color: AppColors.white,
                      size: 22,
                      fill: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Good morning, $userName',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Summary text
              Text(
                "I've summarized your day. You have a busy morning ahead, but the afternoon looks clear for deep work.",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.onSurface,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),

              // Bento Grid
              _BentoGrid(items: bentoItems),
              const SizedBox(height: 16),

              // Heartbeat pulse
              const _PulseHeartbeat(),
              const SizedBox(height: 24),

              // Quick reply chips
              if (onChipTap != null) _QuickChips(chips: chips, onTap: onChipTap!),
            ],
          ),
        ),
      ],
    );
  }
}

class _BentoGrid extends StatelessWidget {
  final List<BentoItem> items;
  const _BentoGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 500;

    final cards = items
        .map((item) => _BentoCard(item: item))
        .toList();

    if (isWide) {
      return Row(
        children: cards.asMap().entries.map((e) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: e.key < cards.length - 1 ? 10 : 0),
              child: e.value,
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: cards
          .map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: c,
              ))
          .toList(),
    );
  }
}

class _BentoCard extends StatelessWidget {
  final BentoItem item;
  const _BentoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.inkDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, color: AppColors.violetDim, size: 22),
          const SizedBox(height: 16),
          Text(
            item.label.toUpperCase(),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              color: AppColors.outline,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseHeartbeat extends StatefulWidget {
  const _PulseHeartbeat();

  @override
  State<_PulseHeartbeat> createState() => _PulseHeartbeatState();
}

class _PulseHeartbeatState extends State<_PulseHeartbeat>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FadeTransition(
          opacity: _opacity,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.violet,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'SYSTEM READY',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            color: AppColors.violet,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}

class _QuickChips extends StatelessWidget {
  final List<String> chips;
  final ValueChanged<String> onTap;
  const _QuickChips({required this.chips, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const specialChip = 'Start my day';
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: chips.map((label) {
        final isPrimary = label == specialChip;
        return _ChipButton(
          label: label,
          isPrimary: isPrimary,
          onTap: () => onTap(label),
        );
      }).toList(),
    );
  }
}

class _ChipButton extends StatefulWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;
  const _ChipButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_ChipButton> createState() => _ChipButtonState();
}

class _ChipButtonState extends State<_ChipButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        _ctrl.forward();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        _ctrl.reverse();
        setState(() => _pressed = false);
      },
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? AppColors.violet
                : _pressed
                    ? AppColors.surfaceHighest
                    : AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(12),
            border: !widget.isPrimary
                ? Border.all(
                    color: AppColors.white.withOpacity(0.05), width: 1)
                : null,
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.violet.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight:
                  widget.isPrimary ? FontWeight.w600 : FontWeight.w500,
              color: widget.isPrimary ? AppColors.white : AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
