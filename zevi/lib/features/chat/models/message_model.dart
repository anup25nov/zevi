enum MessageRole { user, ai }

enum MessageStatus { sending, streaming, done, error }

class MessageModel {
  final String id;
  final String text;
  final MessageRole role;
  final MessageStatus status;
  final DateTime timestamp;
  final String? intent;
  final bool isActionComplete;
  final Map<String, dynamic>? extraData;

  MessageModel({
    required this.id,
    required this.text,
    required this.role,
    required this.status,
    required this.timestamp,
    this.intent,
    this.isActionComplete = false,
    this.extraData,
  });

  MessageModel copyWith({
    String? id,
    String? text,
    MessageRole? role,
    MessageStatus? status,
    DateTime? timestamp,
    String? intent,
    bool? isActionComplete,
    Map<String, dynamic>? extraData,
  }) {
    return MessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      role: role ?? this.role,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      intent: intent ?? this.intent,
      isActionComplete: isActionComplete ?? this.isActionComplete,
      extraData: extraData ?? this.extraData,
    );
  }
}
