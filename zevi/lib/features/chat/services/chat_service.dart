import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../models/message_model.dart';

class ChatService {
  final Dio _dio = apiServiceProvider.dio;

  /// Sends a message and returns a stream of tokens for SSE.
  Stream<String> sendMessage({
    required String message,
    List<MessageModel>? context,
    String? userId,
  }) async* {
    try {
      final response = await _dio.post(
        '/api/chat',
        data: {
          'message': message,
          'context': context?.map((m) => {'role': m.role.name, 'text': m.text}).toList(),
          'userId': userId,
        },
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data.stream as Stream<List<int>>;
      
      await for (final chunk in stream.transform(utf8.decoder)) {
        // Simple SSE parsing: assumes "data: {token}" format or just raw tokens
        // For Zevi, we'll assume the backend sends "data: token\n\n"
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            yield line.substring(6);
          } else if (line.isNotEmpty) {
            // Fallback for raw text streams
            yield line;
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<List<MessageModel>> getHistory() async {
    try {
      final response = await _dio.get('/api/chat/history');
      final List<dynamic> data = response.data;
      return data.map((json) => _parseMessage(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch chat history: $e');
    }
  }

  MessageModel _parseMessage(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      role: json['role'] == 'user' ? MessageRole.user : MessageRole.ai,
      status: MessageStatus.done,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}
