import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatState {
  final List<MessageModel> messages;
  final bool isLoading;
  final String inputText;

  ChatState({
    required this.messages,
    this.isLoading = false,
    this.inputText = '',
  });

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    String? inputText,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      inputText: inputText ?? this.inputText,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _chatService;
  ChatNotifier(this._chatService) : super(ChatState(messages: []));

  // Predefined AI responses for demo/fallback
  static const _demoResponses = [
    'Done! I\'ve scheduled that for you. Your calendar has been updated with the new event.',
    'I found 12 unread emails in your inbox. 3 are marked as important — would you like me to summarize them?',
    'Reminder set! I\'ll notify you 15 minutes before. Is there anything else you need?',
    'Your afternoon is clear for deep work. I\'ve blocked 2pm–5pm on your calendar. No meetings will be scheduled during that time.',
  ];

  void updateInput(String text) {
    state = state.copyWith(inputText: text);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final lowerText = text.trim().toLowerCase();

    final userMsg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      role: MessageRole.user,
      status: MessageStatus.done,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      inputText: '',
    );

    // AI Thinking Delay
    await Future.delayed(const Duration(milliseconds: 1200));

    // Handle Local Demo Intents first (priority for prototyping)
    if (lowerText.contains('rahul') && !lowerText.contains('at ')) {
      await _sendDisambiguationResponse();
      return;
    }

    if (lowerText.contains('email') || lowerText.contains('draft')) {
      await _sendEmailPreviewResponse();
      return;
    }

    // Attempt real API streaming if URL is provided
    final apiUrl = dotenv.env['API_URL'];
    if (apiUrl != null && apiUrl.isNotEmpty) {
      await _sendRealMessage(text);
    } else {
      // Fallback to demo local streaming
      await _streamResponse(
        _demoResponses[Random().nextInt(_demoResponses.length)],
      );
    }
  }

  Future<void> _sendRealMessage(String text) async {
    final aiMsgId = (DateTime.now().millisecondsSinceEpoch + 1).toString();
    final aiMsg = MessageModel(
      id: aiMsgId,
      text: '',
      role: MessageRole.ai,
      status: MessageStatus.streaming,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      isLoading: false,
    );

    try {
      String accumulated = '';
      await for (final token in _chatService.sendMessage(
        message: text,
        context: state.messages.sublist(max(0, state.messages.length - 11)),
      )) {
        accumulated += token;
        _updateMessageText(aiMsgId, accumulated);
      }

      _updateMessageStatus(aiMsgId, MessageStatus.done);
    } catch (e) {
      _updateMessageStatus(aiMsgId, MessageStatus.error);
      // In a real app, you'd show a SnackBar via a ref or secondary provider
      _updateMessageText(aiMsgId, 'Error connecting to Zevi. Please check your connection.');
    }
  }

  void _updateMessageText(String id, String text) {
    state = state.copyWith(
      messages: state.messages.map((m) {
        if (m.id == id) return m.copyWith(text: text);
        return m;
      }).toList(),
    );
  }

  void _updateMessageStatus(String id, MessageStatus status) {
    state = state.copyWith(
      messages: state.messages.map((m) {
        if (m.id == id) return m.copyWith(status: status);
        return m;
      }).toList(),
    );
  }

  Future<void> _sendDisambiguationResponse() async {
    final aiMsgId = (DateTime.now().millisecondsSinceEpoch + 1).toString();
    const responseText = 'Found 3 contacts named Rahul. Which one?';

    final aiMsg = MessageModel(
      id: aiMsgId,
      text: '',
      role: MessageRole.ai,
      status: MessageStatus.streaming,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      isLoading: false,
    );

    // Stream the text first
    await _streamTextForId(aiMsgId, responseText);

    // Then set intent + extraData
    final finalMessages = state.messages.map((m) {
      if (m.id == aiMsgId) {
        return m.copyWith(
          status: MessageStatus.done,
          intent: 'disambiguation',
          extraData: {
            'contacts': [
              {
                'name': 'Rahul Sharma',
                'email': 'rahul.sharma@company.com',
                'label': 'Work'
              },
              {
                'name': 'Rahul Verma',
                'email': 'rahul.v@gmail.com',
                'label': 'Friend'
              },
              {
                'name': 'Rahul Kapoor',
                'email': 'r.kapoor@client.io',
                'label': 'Client'
              },
            ],
          },
        );
      }
      return m;
    }).toList();
    state = state.copyWith(messages: finalMessages);
  }

  Future<void> _sendEmailPreviewResponse() async {
    final aiMsgId = (DateTime.now().millisecondsSinceEpoch + 1).toString();
    const responseText = "Here's your email draft — send it?";

    final aiMsg = MessageModel(
      id: aiMsgId,
      text: '',
      role: MessageRole.ai,
      status: MessageStatus.streaming,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      isLoading: false,
    );

    // Stream the text first
    await _streamTextForId(aiMsgId, responseText);

    // Then set intent + extraData
    final finalMessages = state.messages.map((m) {
      if (m.id == aiMsgId) {
        return m.copyWith(
          status: MessageStatus.done,
          intent: 'email_preview',
          extraData: {
            'to': 'rahul.sharma@company.com',
            'subject': 'Project Update — Q1 Review',
            'body':
                'Hi Rahul,\n\nJust wanted to follow up on our discussion from yesterday. I\'ve compiled the Q1 metrics and the projections are looking strong. Revenue is up 23% quarter-over-quarter, and customer acquisition costs have dropped by 15%.\n\nLet me know if you\'d like to review the full report before the board meeting on Friday.',
          },
        );
      }
      return m;
    }).toList();
    state = state.copyWith(messages: finalMessages);
  }

  Future<void> _streamResponse(String fullResponse) async {
    final aiMsgId = (DateTime.now().millisecondsSinceEpoch + 1).toString();

    final aiMsg = MessageModel(
      id: aiMsgId,
      text: '',
      role: MessageRole.ai,
      status: MessageStatus.streaming,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      isLoading: false,
    );

    await _streamTextForId(aiMsgId, fullResponse);

    // Mark done
    final finalMessages = state.messages.map((m) {
      if (m.id == aiMsgId) {
        return m.copyWith(status: MessageStatus.done);
      }
      return m;
    }).toList();
    state = state.copyWith(messages: finalMessages);
  }

  Future<void> _streamTextForId(String msgId, String fullText) async {
    String accumulated = '';
    for (int i = 0; i < fullText.length; i++) {
      accumulated += fullText[i];
      final updated = state.messages.map((m) {
        if (m.id == msgId) {
          return m.copyWith(text: accumulated);
        }
        return m;
      }).toList();
      state = state.copyWith(messages: updated);
      await Future.delayed(const Duration(milliseconds: 18));
    }
  }

  /// Handle inline widget actions (contact selection, email send/edit)
  void handleAction(String action, Map<String, dynamic> data) {
    if (action == 'contact_selected') {
      final name = data['name'] as String;
      final email = data['email'] as String;
      sendMessage('$name at $email');
    } else if (action == 'email_send') {
      sendMessage('Send the email');
    } else if (action == 'email_edit') {
      sendMessage('Let me edit the email first');
    }
  }

  void clearChat() {
    state = ChatState(messages: []);
  }
}

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final service = ref.watch(chatServiceProvider);
  return ChatNotifier(service);
});
