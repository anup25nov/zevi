import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/morning_briefing_card.dart';

class MorningBriefingScreen extends ConsumerStatefulWidget {
  const MorningBriefingScreen({super.key});

  @override
  ConsumerState<MorningBriefingScreen> createState() =>
      _MorningBriefingScreenState();
}

class _MorningBriefingScreenState
    extends ConsumerState<MorningBriefingScreen> {
  final TextEditingController _textController = TextEditingController();

  void _handleChip(String chip) {
    ref.read(chatProvider.notifier).sendMessage(chip);
    context.go('/chat');
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    ref.read(chatProvider.notifier).sendMessage(text);
    context.go('/chat');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.inkBg,
      body: Stack(
        children: [
          Column(
            children: [
              _GlassAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                  child: MorningBriefingCard(
                    userName: 'Rahul',
                    bentoItems: const [
                      BentoItem(
                        icon: Symbols.calendar_today,
                        label: 'Schedule',
                        value: '3 meetings today',
                      ),
                      BentoItem(
                        icon: Symbols.mail,
                        label: 'Inbox',
                        value: '12 unread emails',
                      ),
                      BentoItem(
                        icon: Symbols.notifications,
                        label: 'Tasks',
                        value: '2 reminders',
                      ),
                    ],
                    chips: const ['Open calendar', 'Check emails', 'Start my day'],
                    onChipTap: _handleChip,
                  ),
                ),
              ),
              ChatInputBar(
                controller: _textController,
                onSend: _handleSend,
                onChanged: (text) =>
                    ref.read(chatProvider.notifier).updateInput(text),
              ),
            ],
          ),

          // Floating nav bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomNav(activeIndex: 1, onTabSelected: (i) {
              if (i == 0) context.go('/chat');
              if (i == 2) context.go('/settings');
            }),
          ),
        ],
      ),
    );
  }
}

class _GlassAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 56 + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 16,
            right: 16,
          ),
          color: AppColors.inkBg.withValues(alpha: 0.8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.go('/chat'),
                child: const Icon(Symbols.arrow_back,
                    color: AppColors.onSurface, size: 22),
              ),
              const SizedBox(width: 12),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Ze',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    TextSpan(
                      text: 'vi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.violet,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Symbols.account_circle,
                  color: AppColors.onSurface, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int activeIndex;
  final Function(int) onTabSelected;
  const _BottomNav(
      {required this.activeIndex, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (Symbols.chat_bubble, 'Chat'),
      (Symbols.sunny, 'Routine'),
      (Symbols.settings, 'Settings'),
    ];

    return Container(
      color: AppColors.surfaceLow,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.white.withValues(alpha: 0.05),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: tabs.asMap().entries.map((e) {
              final idx = e.key;
              final (icon, label) = e.value;
              final isActive = activeIndex == idx;
              return GestureDetector(
                onTap: () => onTabSelected(idx),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        fill: isActive ? 1.0 : 0.0,
                        color: isActive
                            ? AppColors.violet
                            : AppColors.outline,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isActive
                              ? AppColors.violet
                              : AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
