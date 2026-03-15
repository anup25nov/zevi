import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class VoiceService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _recordingPath;

  String get _deepgramKey => dotenv.env['DEEPGRAM_KEY'] ?? '';

  /// Request microphone permission and start recording to a temp file.
  Future<void> startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw Exception('Microphone permission denied');
    }

    // Create temp file path
    final tempDir = Directory.systemTemp;
    _recordingPath =
        '${tempDir.path}/zevi_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: _recordingPath!,
    );
  }

  /// Stop recording and send to Deepgram for transcription.
  /// Returns the transcript string, or empty string on failure.
  Future<String> stopAndTranscribe() async {
    final path = await _recorder.stop();
    if (path == null || path.isEmpty) {
      return '';
    }

    try {
      final transcript = await _transcribeWithDeepgram(path);
      // Clean up temp file
      _cleanUpFile(path);
      return transcript;
    } catch (e) {
      _cleanUpFile(path);
      // Return empty on failure — caller should handle gracefully
      return '';
    }
  }

  Future<String> _transcribeWithDeepgram(String filePath) async {
    if (_deepgramKey.isEmpty) {
      throw Exception('DEEPGRAM_KEY not configured in .env');
    }

    final file = File(filePath);
    final bytes = await file.readAsBytes();

    final dio = Dio();
    final response = await dio.post<Map<String, dynamic>>(
      'https://api.deepgram.com/v1/listen?model=nova-2&language=en-IN',
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {
          'Authorization': 'Token $_deepgramKey',
          'Content-Type': 'audio/*',
        },
        responseType: ResponseType.json,
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      final results = response.data!['results'] as Map<String, dynamic>?;
      if (results != null) {
        final channels = results['channels'] as List?;
        if (channels != null && channels.isNotEmpty) {
          final alternatives =
              (channels[0] as Map<String, dynamic>)['alternatives'] as List?;
          if (alternatives != null && alternatives.isNotEmpty) {
            return (alternatives[0] as Map<String, dynamic>)['transcript']
                    as String? ??
                '';
          }
        }
      }
    }

    return '';
  }

  void _cleanUpFile(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {}
  }

  Future<void> dispose() async {
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    _recorder.dispose();
  }
}
