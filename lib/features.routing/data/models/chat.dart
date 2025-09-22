import 'package:equatable/equatable.dart';
import 'message.dart';

class Chat extends Equatable {
  final String id;
  final String name;
  final String? photo;
  final List<Message> messages;
  final bool isOnline;
  final int unreadCount;

  const Chat({
    required this.id,
    required this.name,
    this.photo,
    this.messages = const [],
    this.isOnline = false,
    this.unreadCount = 0,
  });

  // Получить последнее сообщение
  Message? get lastMessage {
    if (messages.isEmpty) return null;
    return messages.last;
  }

  // Получить время последнего сообщения в формате строки
  String get lastMessageTime {
    final lastMsg = lastMessage;
    if (lastMsg == null) return '';
    
    final now = DateTime.now();
    final msgTime = lastMsg.timestamp;
    final difference = now.difference(msgTime);

    if (difference.inDays > 1) {
      return '${difference.inDays} дн. назад';
    } else if (difference.inDays == 1) {
      return 'Вчера';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ч. назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} мин. назад';
    } else {
      return 'Сейчас';
    }
  }

  // Получить текст последнего сообщения
  String get lastMessageText {
    final lastMsg = lastMessage;
    if (lastMsg == null) return 'Нет сообщений';
    
    if (lastMsg.attachmentType != null) {
      switch (lastMsg.attachmentType) {
        case 'image':
          return '📷 Фото';
        case 'file':
          return '📎 Файл';
        default:
          return lastMsg.text.isNotEmpty ? lastMsg.text : '📎 Вложение';
      }
    }
    
    return lastMsg.text;
  }

  Chat copyWith({
    String? id,
    String? name,
    String? photo,
    List<Message>? messages,
    bool? isOnline,
    int? unreadCount,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      messages: messages ?? this.messages,
      isOnline: isOnline ?? this.isOnline,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [id, name, photo, messages, isOnline, unreadCount,];
}
