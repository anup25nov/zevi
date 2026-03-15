import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/voice_provider.dart';

class ChatInputBar extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final ValueChanged<String>? onChanged;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.onChanged,
  });

  @override
  ConsumerState<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends ConsumerState<ChatInputBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _pulseScale = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceProvider);

    // When a transcript arrives, fill the text field
    ref.listen(voiceProvider, (prev, next) {
      if (next.transcript.isNotEmpty &&
          (prev?.transcript ?? '') != next.transcript) {
        widget.controller.text = next.transcript;
        widget.controller.selection = TextSelection.fromPosition(
          TextPosition(offset: next.transcript.length),
        );
        _focusNode.requestFocus();
        ref.read(voiceProvider.notifier).clearTranscript();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Review and press send',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.white),
            ),
            backgroundColor: AppColors.surface,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      if (next.error != null && (prev?.error ?? '') != (next.error ?? '')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.error!,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.white),
            ),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: AppColors.inkBg,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.inkDeep,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // User avatar placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Symbols.person, color: AppColors.outline, size: 20),
            ),
            const SizedBox(width: 12),

            // Text input
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                onChanged: widget.onChanged,
                onSubmitted: (_) => widget.onSend(),
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.white),
                decoration: InputDecoration(
                  hintText: 'Ask Zevi anything...',
                  hintStyle: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: AppColors.outline,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),

            // Attach file
            IconButton(
              onPressed: () {},
              icon: const Icon(Symbols.attach_file, color: AppColors.outline, size: 22),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),

            // Mic button with animated states
            _buildMicButton(voiceState),
            const SizedBox(width: 4),

            // Send button
            GestureDetector(
              onTap: widget.onSend,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.violet,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Symbols.send, color: AppColors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicButton(VoiceState voiceState) {
    if (voiceState.isTranscribing) {
      // Transcribing state — spinner
      return const SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.violet,
            ),
          ),
        ),
      );
    }

    if (voiceState.isRecording) {
      // Recording state — stop icon with pulsing ring
      return SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing ring
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseScale.value,
                  child: Opacity(
                    opacity: _pulseOpacity.value,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.violet,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Stop button
            GestureDetector(
              onTap: () => ref.read(voiceProvider.notifier).toggleRecording(),
              child: const Icon(
                Symbols.stop_circle,
                color: AppColors.violet,
                size: 22,
                fill: 1,
              ),
            ),
          ],
        ),
      );
    }

    // Idle state — mic icon
    return IconButton(
      onPressed: () => ref.read(voiceProvider.notifier).toggleRecording(),
      icon: const Icon(Symbols.mic, color: AppColors.outline, size: 22),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}
