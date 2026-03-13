/// Chat Provider - manages messages and chatbot state

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}

class Conversation {
  final int otherUserId;
  final String otherUserName;
  final String otherUserUsername;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isLastMine;

  Conversation({
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserUsername,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isLastMine,
  });

  factory Conversation.fromJson(Map<String, dynamic> j) => Conversation(
        otherUserId: j['other_user_id'],
        otherUserName: j['other_user_name'] ?? '',
        otherUserUsername: j['other_user_username'] ?? '',
        lastMessage: j['last_message'] ?? '',
        lastMessageTime: DateTime.parse(j['last_message_time']).toLocal(),
        unreadCount: j['unread_count'] ?? 0,
        isLastMine: j['is_last_mine'] ?? false,
      );
}

class DirectMessage {
  final int id;
  final int senderId;
  final String senderName;
  final String senderUsername;
  final int receiverId;
  final String receiverName;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final int? petId;
  final String? petName;

  DirectMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderUsername,
    required this.receiverId,
    required this.receiverName,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.petId,
    this.petName,
  });

  factory DirectMessage.fromJson(Map<String, dynamic> j) => DirectMessage(
        id: j['id'],
        senderId: j['sender_id'],
        senderName: j['sender_name'] ?? '',
        senderUsername: j['sender_username'] ?? '',
        receiverId: j['receiver_id'],
        receiverName: j['receiver_name'] ?? '',
        content: j['content'] ?? '',
        isRead: j['is_read'] ?? false,
        createdAt: DateTime.parse(j['created_at']).toLocal(),
        petId: j['pet'],
        petName: j['pet_name'],
      );
}

class ChatProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // Conversations list
  List<Conversation> _conversations = [];
  bool _conversationsLoading = false;
  int _totalUnread = 0;

  // Active chat
  List<DirectMessage> _messages = [];
  bool _messagesLoading = false;

  // AI Chatbot
  List<ChatMessage> _chatbotMessages = [];
  bool _chatbotLoading = false;

  List<Conversation> get conversations => _conversations;
  bool get conversationsLoading => _conversationsLoading;
  int get totalUnread => _totalUnread;

  List<DirectMessage> get messages => _messages;
  bool get messagesLoading => _messagesLoading;

  List<ChatMessage> get chatbotMessages => _chatbotMessages;
  bool get chatbotLoading => _chatbotLoading;

  // ── Conversations ──────────────────────────────────────────────────────────

  Future<void> fetchConversations() async {
    _conversationsLoading = true;
    notifyListeners();
    try {
      final data = await _api.get('${ApiConstants.messages}conversations/');
      final list = data as List;
      _conversations = list.map((e) => Conversation.fromJson(e)).toList();
      _totalUnread = _conversations.fold(0, (sum, c) => sum + c.unreadCount);
    } catch (_) {
      _conversations = [];
    }
    _conversationsLoading = false;
    notifyListeners();
  }

  Future<void> fetchUnreadCount() async {
    try {
      final data = await _api.get('${ApiConstants.messages}unread_count/');
      _totalUnread = data['unread_count'] ?? 0;
      notifyListeners();
    } catch (_) {}
  }

  // ── Direct Messages ────────────────────────────────────────────────────────

  Future<void> fetchMessages(int withUserId) async {
    _messagesLoading = true;
    notifyListeners();
    try {
      final data = await _api.get('${ApiConstants.messages}?with=$withUserId');
      final list = (data is List) ? data : (data['results'] as List? ?? []);
      _messages = list.map((e) => DirectMessage.fromJson(e)).toList();
      // Update unread in conversations
      _conversations = _conversations.map((c) {
        if (c.otherUserId == withUserId) {
          return Conversation(
            otherUserId: c.otherUserId,
            otherUserName: c.otherUserName,
            otherUserUsername: c.otherUserUsername,
            lastMessage: c.lastMessage,
            lastMessageTime: c.lastMessageTime,
            unreadCount: 0,
            isLastMine: c.isLastMine,
          );
        }
        return c;
      }).toList();
      _totalUnread = _conversations.fold(0, (sum, c) => sum + c.unreadCount);
    } catch (_) {
      _messages = [];
    }
    _messagesLoading = false;
    notifyListeners();
  }

  Future<bool> sendMessage(int receiverId, String content, {int? petId}) async {
    try {
      final body = <String, dynamic>{
        'receiver': receiverId,
        'content': content,
        if (petId != null) 'pet': petId,
      };
      final data = await _api.post(ApiConstants.messages, body);
      final msg = DirectMessage.fromJson(data);
      _messages = [..._messages, msg];
      // Refresh conversations
      await fetchConversations();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }

  // ── AI Chatbot ─────────────────────────────────────────────────────────────

  Future<void> sendChatbotMessage(String question) async {
    _chatbotMessages = [
      ..._chatbotMessages,
      ChatMessage(text: question, isUser: true, time: DateTime.now()),
    ];
    _chatbotLoading = true;
    notifyListeners();

    try {
      final data = await _api.post(ApiConstants.chatbot, {'question': question});
      final answer = data['answer'] ?? 'Sorry, I could not get a response.';
      _chatbotMessages = [
        ..._chatbotMessages,
        ChatMessage(text: answer, isUser: false, time: DateTime.now()),
      ];
    } catch (_) {
      _chatbotMessages = [
        ..._chatbotMessages,
        ChatMessage(
          text: 'Connection error. Please try again.',
          isUser: false,
          time: DateTime.now(),
        ),
      ];
    }
    _chatbotLoading = false;
    notifyListeners();
  }

  void clearChatbot() {
    _chatbotMessages = [];
    notifyListeners();
  }
}
