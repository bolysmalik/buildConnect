// mock_chat_service.dart
// Сервис для работы с чатами и сообщениями

import 'dart:async';
import 'mock_database.dart';

class MockChatService {
  static final MockChatService _instance = MockChatService._internal();
  factory MockChatService() => _instance;
  MockChatService._internal();

  MockDatabase? _db;
  
  // Метод для установки базы данных извне
  void setDatabase(MockDatabase database) {
    _db = database;
  }
  
  MockDatabase get database {
    if (_db == null) {
      throw Exception('Database not initialized. Call setDatabase() first.');
    }
    return _db!;
  }
  
  // Стрим для уведомлений о новых сообщениях
  final StreamController<Map<String, dynamic>> _messageController = 
    StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  // ============= ЧАТЫ =============

  // Получить все чаты пользователя
  Future<List<Map<String, dynamic>>> getUserChats(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final chats = database.getChatsByUserId(userId);
    
    // Обогащаем информацией о собеседниках и сообщениях
    final enrichedChats = <Map<String, dynamic>>[];
    
    for (final chat in chats) {
      final participants = List<String>.from(chat['participants']);
      final otherUserId = participants.firstWhere((id) => id != userId);
      final otherUser = database.getUserById(otherUserId);
      
      // Получаем сообщения чата
      final messages = database.getChatMessages(chat['id']);
      
      final enrichedChat = {
        ...chat,
        'otherUser': otherUser,
        'otherUserName': otherUser?['name'] ?? 'Неизвестный пользователь',
        'otherUserRole': otherUser?['role'] ?? 'unknown',
        'messages': messages,
      };
      
      enrichedChats.add(enrichedChat);
    }
    
    // Сортируем по времени последнего сообщения
    enrichedChats.sort((a, b) {
      final timeA = DateTime.parse(a['lastMessageTime'] ?? '2024-01-01T00:00:00Z');
      final timeB = DateTime.parse(b['lastMessageTime'] ?? '2024-01-01T00:00:00Z');
      return timeB.compareTo(timeA);
    });
    
    return enrichedChats;
  }

  // Получить конкретный чат
  Future<Map<String, dynamic>?> getChatById(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return database.getChatById(chatId);
  }

  // Создать новый чат или найти существующий
  Future<Map<String, dynamic>> getOrCreateChat(String userId1, String userId2) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Ищем существующий чат между этими пользователями
    final existingChats = database.getChatsByUserId(userId1);
    for (final chat in existingChats) {
      final participants = List<String>.from(chat['participants']);
      if (participants.contains(userId2)) {
        return {
          'success': true,
          'chat': chat,
          'isNew': false,
        };
      }
    }
    
    // Создаем новый чат
    final newChatId = database.createChat([userId1, userId2]);
    final newChat = database.getChatById(newChatId);
    
    return {
      'success': true,
      'chat': newChat,
      'isNew': true,
    };
  }

  // ============= СООБЩЕНИЯ =============

  // Получить сообщения чата
  Future<List<Map<String, dynamic>>> getChatMessages(String chatId, {
    int limit = 50,
    int offset = 0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    print('MockChatService: Getting messages for chatId: $chatId');
    
    // Используем прямой метод базы данных для получения сообщений
    final messages = database.getChatMessages(chatId);
    
    print('MockChatService: Retrieved ${messages.length} messages from database');
    
    if (messages.isEmpty) {
      print('MockChatService: No messages found for chat $chatId');
      return [];
    }
    
    print('MockChatService: Raw messages from DB: $messages');
    
    // Создаем копию списка для безопасности
    final messagesList = List<Map<String, dynamic>>.from(messages);
    
    // Сортируем по времени (старые сначала, новые последними)
    messagesList.sort((a, b) {
      final timeA = DateTime.parse(a['timestamp']);
      final timeB = DateTime.parse(b['timestamp']);
      return timeA.compareTo(timeB);
    });
    
    // Применяем пагинацию
    final start = offset;
    final end = (offset + limit).clamp(0, messagesList.length);
    
    if (start >= messagesList.length) {
      print('MockChatService: Offset $start exceeds message count ${messagesList.length}');
      return [];
    }
    
    final result = messagesList.sublist(start, end);
    print('MockChatService: Returning ${result.length} messages after pagination: $result');
    
    return result;
  }

  // Отправить сообщение
  Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String? type = 'text', // text, image, file
    String? attachmentUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    print('MockChatService: Sending message - chatId: $chatId, senderId: $senderId, text: "$text"');
    
    try {
      final messageId = database.addMessage(
        chatId, 
        senderId, 
        text,
        attachmentType: type,
        attachmentPath: attachmentUrl,
      );
      
      print('MockChatService: Message sent successfully with ID: $messageId');
      
      // Уведомляем подписчиков о новом сообщении
      _messageController.add({
        'chatId': chatId,
        'messageId': messageId,
        'senderId': senderId,
        'text': text,
        'type': type,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      return {
        'success': true,
        'messageId': messageId,
        'message': 'Сообщение отправлено',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Ошибка отправки сообщения: $e',
      };
    }
  }

  // Отметить сообщения как прочитанные
  Future<Map<String, dynamic>> markMessagesAsRead(String chatId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final chat = database.getChatById(chatId);
    if (chat == null) {
      return {
        'success': false,
        'message': 'Чат не найден',
      };
    }
    
    final messages = List<Map<String, dynamic>>.from(chat['messages']);
    int markedCount = 0;
    
    for (final message in messages) {
      if (message['senderId'] != userId && message['isRead'] == false) {
        message['isRead'] = true;
        markedCount++;
      }
    }
    
    // Обнуляем счетчик непрочитанных
    chat['unreadCount'] = 0;
    
    // Уведомляем подписчиков о том, что сообщения прочитаны
    if (markedCount > 0) {
      _messageController.add({
        'type': 'messages_read',
        'chatId': chatId,
        'userId': userId,
        'markedCount': markedCount,
      });
    }
    
    return {
      'success': true,
      'markedCount': markedCount,
      'message': 'Сообщения отмечены как прочитанные',
    };
  }

  // Получить количество непрочитанных сообщений для пользователя
  Future<int> getUnreadMessagesCount(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final userChats = database.getChatsByUserId(userId);
    int totalUnread = 0;
    
    for (final chat in userChats) {
      final messages = List<Map<String, dynamic>>.from(chat['messages']);
      for (final message in messages) {
        if (message['senderId'] != userId && message['isRead'] == false) {
          totalUnread++;
        }
      }
    }
    
    return totalUnread;
  }

  // ============= ПОИСК =============

  // Поиск чатов
  Future<List<Map<String, dynamic>>> searchChats(String userId, String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final userChats = await getUserChats(userId);
    
    if (query.isEmpty) return userChats;
    
    return userChats.where((chat) {
      final otherUserName = chat['otherUserName']?.toString().toLowerCase() ?? '';
      final lastMessage = chat['lastMessage']?.toString().toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();
      
      return otherUserName.contains(searchQuery) || lastMessage.contains(searchQuery);
    }).toList();
  }

  // Поиск сообщений в чате
  Future<List<Map<String, dynamic>>> searchMessagesInChat(String chatId, String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final messages = await getChatMessages(chatId, limit: 1000);
    
    if (query.isEmpty) return messages;
    
    return messages.where((message) {
      final text = message['text']?.toString().toLowerCase() ?? '';
      return text.contains(query.toLowerCase());
    }).toList();
  }

  // ============= УТИЛИТЫ =============

  // Удалить сообщение
  Future<Map<String, dynamic>> deleteMessage(String chatId, String messageId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final chat = database.getChatById(chatId);
    if (chat == null) {
      return {
        'success': false,
        'message': 'Чат не найден',
      };
    }
    
    final messages = List<Map<String, dynamic>>.from(chat['messages']);
    final messageIndex = messages.indexWhere((msg) => 
      msg['id'] == messageId && msg['senderId'] == userId
    );
    
    if (messageIndex != -1) {
      messages.removeAt(messageIndex);
      chat['messages'] = messages;
      
      // Обновляем последнее сообщение, если удаленное было последним
      if (messages.isNotEmpty) {
        final lastMessage = messages.last;
        chat['lastMessage'] = lastMessage['text'];
        chat['lastMessageTime'] = lastMessage['timestamp'];
      } else {
        chat['lastMessage'] = '';
        chat['lastMessageTime'] = DateTime.now().toIso8601String();
      }
      
      return {
        'success': true,
        'message': 'Сообщение удалено',
      };
    } else {
      return {
        'success': false,
        'message': 'Сообщение не найдено или нет прав на удаление',
      };
    }
  }

  // Получить информацию о чате
  Future<Map<String, dynamic>> getChatInfo(String chatId, String currentUserId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final chat = database.getChatById(chatId);
    if (chat == null) {
      return {
        'success': false,
        'message': 'Чат не найден',
      };
    }
    
    final participants = List<String>.from(chat['participants']);
    final otherUserId = participants.firstWhere((id) => id != currentUserId);
    final otherUser = database.getUserById(otherUserId);
    
    final messagesCount = (chat['messages'] as List).length;
    final unreadCount = await getUnreadMessagesCount(currentUserId);
    
    return {
      'success': true,
      'chat': chat,
      'otherUser': otherUser,
      'messagesCount': messagesCount,
      'unreadCount': unreadCount,
    };
  }

  // Освободить ресурсы
  void dispose() {
    _messageController.close();
  }
}
