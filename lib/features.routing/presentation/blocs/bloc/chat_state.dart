import 'package:equatable/equatable.dart';
import '../../../data/models/message.dart';
import '../../../data/models/attachment.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoaded extends ChatState {
  final List<Message> messages;
  final bool isAttachmentMenuVisible;
  final String? errorMessage;
  final List<Attachment> pendingAttachments;
  final bool isCallActive;

  const ChatLoaded({
    required this.messages,
    this.isAttachmentMenuVisible = false,
    this.errorMessage,
    this.pendingAttachments = const [],
    this.isCallActive = false,

  });

  ChatLoaded copyWith({
    List<Message>? messages,
    bool? isAttachmentMenuVisible,
    String? errorMessage,
    List<Attachment>? pendingAttachments,
    bool? isCallActive,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isAttachmentMenuVisible: isAttachmentMenuVisible ?? this.isAttachmentMenuVisible,
      errorMessage: errorMessage,
      pendingAttachments: pendingAttachments ?? this.pendingAttachments,
      isCallActive: isCallActive ?? this.isCallActive,
    );
  }

  @override
  List<Object?> get props => [messages, isAttachmentMenuVisible, errorMessage, pendingAttachments,isCallActive];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
