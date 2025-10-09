import 'package:equatable/equatable.dart';
import '../../../data/models/chat.dart';

abstract class ChatsState extends Equatable {
  const ChatsState();

  @override
  List<Object?> get props => [];
}

class ChatsInitial extends ChatsState {
  const ChatsInitial();
}

class ChatsLoading extends ChatsState {
  const ChatsLoading();
}

class ChatsLoaded extends ChatsState {
  final List<Chat> chats;

  const ChatsLoaded({required this.chats});

  ChatsLoaded copyWith({
    List<Chat>? chats,
  }) {
    return ChatsLoaded(
      chats: chats ?? this.chats,
    );
  }

  @override
  List<Object?> get props => [chats];
}

class ChatsError extends ChatsState {
  final String message;

  const ChatsError(this.message);

  @override
  List<Object?> get props => [message];
}
