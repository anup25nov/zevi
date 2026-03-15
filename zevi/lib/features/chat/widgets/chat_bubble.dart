import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/message_model.dart';
import 'disambiguation_picker.dart';
import 'email_preview_card.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final void Function(String action, Map<String, dynamic> data)? onAction;

  const ChatBubble({super.key, required this.message, this.onAction});

  @override
  Widget build(BuildContext context) {
    if (message.role == MessageRole.user) {
      return _UserBubble(message: message);
    }
    return _AiBubble(message: message, onAction: onAction);
  }
}

class _UserBubble extends StatelessWidget {
  final MessageModel message;
  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.80,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.violet,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              message.text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.white,
                height: 1.55,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AiBubble extends StatelessWidget {
  final MessageModel message;
  final void Function(String action, Map<String, dynamic> data)? onAction;
  const _AiBubble({required this.message, this.onAction});

  @override
  Widget build(BuildContext context) {
    final isStreaming =
        message.status == MessageStatus.streaming && message.text.isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accent line
          Container(
            width: 3,
            constraints: const BoxConstraints(minHeight: 40),
            decoration: BoxDecoration(
              color: AppColors.violet,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI avatar + label
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.violet,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          'Z',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Zevi',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: AppColors.outline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Bubble
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85,
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(
                        color: AppColors.violet.withOpacity(0.25),
                        width: 0.5,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isStreaming)
                          const _TypingDots()
                        else
                          Text(
                            message.text,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: message.isActionComplete
                                  ? AppColors.success
                                  : const Color(0xFFE8E3FF),
                              height: 1.55,
                            ),
                          ),

                        // Inline disambiguation picker
                        if (message.intent == 'disambiguation' &&
                            message.extraData != null)
                          _buildDisambiguation(),

                        // Inline email preview
                        if (message.intent == 'email_preview' &&
                            message.extraData != null)
                          _buildEmailPreview(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Timestamp
                Text(
                  _formatTime(message.timestamp),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.white.withOpacity(0.25),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisambiguation() {
    final contactsList = message.extraData!['contacts'] as List<dynamic>;
    final options = contactsList.map((c) {
      final map = c as Map<String, dynamic>;
      return ContactOption(
        name: map['name'] as String,
        email: map['email'] as String,
        label: map['label'] as String,
      );
    }).toList();

    return DisambiguationPicker(
      options: options,
      onSelected: (contact) {
        onAction?.call('contact_selected', {
          'name': contact.name,
          'email': contact.email,
        });
      },
    );
  }

  Widget _buildEmailPreview() {
    final data = message.extraData!;
    return EmailPreviewCard(
      to: data['to'] as String? ?? '',
      subject: data['subject'] as String? ?? '',
      body: data['body'] as String? ?? '',
      onSend: () {
        onAction?.call('email_send', data);
      },
      onEdit: () {
        onAction?.call('email_edit', data);
      },
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $amPm';
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final t = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity = 0.3 + 0.7 * (0.5 + 0.5 * _sin(t * 2 * 3.14159));
            return Container(
              margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }

  double _sin(double x) => (x - x * x * x / 6).clamp(-1.0, 1.0);
}
