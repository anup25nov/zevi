import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/message_model.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/morning_briefing_card.dart';

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
          _GlassAppBar(onBriefingTap: () => context.go('/briefing')),

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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    itemCount: messages.length + (chatState.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && chatState.isLoading) {
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
                          ref
                              .read(chatProvider.notifier)
                              .handleAction(action, data);
                        },
                      );
                    },
                  ),
          ),

          // Input bar
          ChatInputBar(
            controller: _textController,
            onSend: _sendMessage,
            onChanged: (text) =>
                ref.read(chatProvider.notifier).updateInput(text),
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
  final VoidCallback? onBriefingTap;
  const _GlassAppBar({this.onBriefingTap});

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
              const Icon(Symbols.arrow_back,
                  color: AppColors.onSurface, size: 22),
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
              // Briefing shortcut
              GestureDetector(
                onTap: onBriefingTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.violet.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.violet.withOpacity(0.3), width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Symbols.sunny,
                          color: AppColors.violet, size: 14, fill: 1),
                      const SizedBox(width: 4),
                      Text(
                        'Briefing',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: AppColors.violet,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Symbols.account_circle,
                  color: AppColors.onSurface, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================
// Empty State — uses MorningBriefingCard
// =========================================
class _EmptyState extends StatelessWidget {
  final ValueChanged<String> onChipTap;
  const _EmptyState({required this.onChipTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
        onChipTap: onChipTap,
      ),
    );
  }
}
