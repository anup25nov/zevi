import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/message_model.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/suggestion_chips.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    _textController.clear();
    ref.read(chatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final messages = chatState.messages;
    final isEmpty = messages.isEmpty;

    // Auto-scroll when new messages arrive
    ref.listen(chatProvider, (prev, next) {
      if ((prev?.messages.length ?? 0) != next.messages.length ||
          next.messages.isNotEmpty && next.messages.last.role == MessageRole.ai) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.inkBg,
      body: Column(
        children: [
          // Glass App Bar
          _GlassAppBar(),

          // Chat area
          Expanded(
            child: isEmpty
                ? _EmptyState(
                    onChipTap: (text) {
                      _textController.text = text;
                      _sendMessage();
                    },
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: messages.length + (chatState.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && chatState.isLoading) {
                        // Typing indicator
                        return ChatBubble(
                          message: MessageModel(
                            id: 'typing',
                            text: '',
                            role: MessageRole.ai,
                            status: MessageStatus.streaming,
                            timestamp: DateTime.now(),
                          ),
                        );
                      }
                      return ChatBubble(
                        message: messages[index],
                        onAction: (action, data) {
                          ref.read(chatProvider.notifier).handleAction(action, data);
                        },
                      );
                    },
                  ),
          ),

          // Input bar
          ChatInputBar(
            controller: _textController,
            onSend: _sendMessage,
            onChanged: (text) => ref.read(chatProvider.notifier).updateInput(text),
          ),
        ],
      ),
    );
  }
}

// =========================================
// Glass App Bar
// =========================================
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
          color: AppColors.inkBg.withOpacity(0.8),
          child: Row(
            children: [
              const Icon(Symbols.arrow_back, color: AppColors.onSurface, size: 22),
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
              const Icon(Symbols.account_circle, color: AppColors.onSurface, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================
// Empty State (Morning Briefing)
// =========================================
class _EmptyState extends StatelessWidget {
  final ValueChanged<String> onChipTap;
  const _EmptyState({required this.onChipTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accent line
          Container(
            width: 3,
            constraints: const BoxConstraints(minHeight: 400),
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
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.violet,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Symbols.sunny, color: AppColors.white, size: 20,
                          fill: 1),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Good morning, Rahul',
                      style: AppTextStyles.headline(20, color: AppColors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Body text
                Text(
                  "I've summarized your day. You have a busy morning ahead, but the afternoon looks clear for deep work.",
                  style: AppTextStyles.body(16, color: AppColors.onSurface).copyWith(height: 1.6),
                ),
                const SizedBox(height: 24),

                // Bento grid
                _BentoGrid(),
                const SizedBox(height: 16),

                // Pulsing heartbeat
                _PulseHeartbeat(),
                const SizedBox(height: 24),

                // Suggestion chips
                SuggestionChips(onChipTap: onChipTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================
// Bento Grid
// =========================================
class _BentoGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 600;

    final cards = [
      _BentoCard(icon: Symbols.calendar_today, label: 'SCHEDULE', value: '3 meetings today'),
      _BentoCard(icon: Symbols.mail, label: 'INBOX', value: '12 unread emails'),
      _BentoCard(icon: Symbols.notifications, label: 'TASKS', value: '2 reminders'),
    ];

    if (isWide) {
      return Row(
        children: cards
            .map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c)))
            .toList(),
      );
    }

    return Column(
      children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList(),
    );
  }
}

class _BentoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _BentoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.inkDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white.withOpacity(0.05), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.violetDim, size: 22),
          const SizedBox(height: 16),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              color: AppColors.outline,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
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

// =========================================
// Pulse Heartbeat
// =========================================
class _PulseHeartbeat extends StatefulWidget {
  @override
  State<_PulseHeartbeat> createState() => _PulseHeartbeatState();
}

class _PulseHeartbeatState extends State<_PulseHeartbeat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
