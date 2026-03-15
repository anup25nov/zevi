import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/voice_service.dart';

class VoiceState {
  final bool isRecording;
  final bool isTranscribing;
  final String transcript;
  final String? error;

  VoiceState({
    this.isRecording = false,
    this.isTranscribing = false,
    this.transcript = '',
    this.error,
  });

  VoiceState copyWith({
    bool? isRecording,
    bool? isTranscribing,
    String? transcript,
    String? error,
  }) {
    return VoiceState(
      isRecording: isRecording ?? this.isRecording,
      isTranscribing: isTranscribing ?? this.isTranscribing,
      transcript: transcript ?? this.transcript,
      error: error,
    );
  }
}

class VoiceNotifier extends StateNotifier<VoiceState> {
  final VoiceService _service = VoiceService();

  VoiceNotifier() : super(VoiceState());

  Future<void> toggleRecording() async {
    if (state.isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      await _service.startRecording();
      state = state.copyWith(isRecording: true, error: null, transcript: '');
    } catch (e) {
      state = state.copyWith(
        isRecording: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _stopRecording() async {
    state = state.copyWith(isRecording: false, isTranscribing: true);

    try {
      final transcript = await _service.stopAndTranscribe();
      state = state.copyWith(
        isTranscribing: false,
        transcript: transcript,
        error: transcript.isEmpty ? 'Could not transcribe audio' : null,
      );
    } catch (e) {
      state = state.copyWith(
        isTranscribing: false,
        error: e.toString(),
      );
    }
  }

  void clearTranscript() {
    state = state.copyWith(transcript: '');
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

final voiceProvider =
    StateNotifierProvider<VoiceNotifier, VoiceState>((ref) {
  return VoiceNotifier();
});
