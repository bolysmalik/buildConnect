import 'package:equatable/equatable.dart';
import '../../../data/models/message.dart';

abstract class ChatsEvent extends Equatable {
  const ChatsEvent();

  @override
  List<Object?> get props => [];
}

class LoadChats extends ChatsEvent {
  const LoadChats();
}

class UpdateChatWithMessage extends ChatsEvent {
  final String chatId;
  final Message message;

  const UpdateChatWithMessage({
    required this.chatId,
    required this.message,
  });

  @override
  List<Object?> get props => [chatId, message];
}

class MarkChatAsRead extends ChatsEvent {
  final String chatId;

  const MarkChatAsRead(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class UpdateOnlineStatus extends ChatsEvent {
  final String chatId;
  final bool isOnline;

  const UpdateOnlineStatus({
    required this.chatId,
    required this.isOnline,
  });

  @override
  List<Object?> get props => [chatId, isOnline];
}
