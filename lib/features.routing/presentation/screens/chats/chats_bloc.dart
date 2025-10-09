import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/chat_service.dart';
import 'chats_event.dart';
import 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final ChatService _chatService;

  ChatsBloc({ChatService? chatService})
      : _chatService = chatService ?? ChatService(),
        super(const ChatsInitial()) {
    
    on<LoadChats>(_onLoadChats);
    on<UpdateChatWithMessage>(_onUpdateChatWithMessage);
    on<MarkChatAsRead>(_onMarkChatAsRead);
    on<UpdateOnlineStatus>(_onUpdateOnlineStatus);
  }

  void _onLoadChats(LoadChats event, Emitter<ChatsState> emit) {
    try {
      emit(const ChatsLoading());
      final chats = _chatService.getAllChats();
      emit(ChatsLoaded(chats: chats));
    } catch (e) {
      emit(ChatsError('Ошибка загрузки чатов: $e'));
    }
  }

  void _onUpdateChatWithMessage(UpdateChatWithMessage event, Emitter<ChatsState> emit) {
    final currentState = state;
    if (currentState is ChatsLoaded) {
      try {
        // Обновляем сообщение в сервисе
        _chatService.addMessageToChat(event.chatId, event.message);
        
        // Получаем обновленный список чатов
        final updatedChats = _chatService.getAllChats();
        
        // Сортируем чаты по времени последнего сообщения (самые новые сверху)
        updatedChats.sort((a, b) {
          final aTime = a.lastMessage?.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.lastMessage?.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });
        
        emit(ChatsLoaded(chats: updatedChats));
      } catch (e) {
        emit(ChatsError('Ошибка обновления чата: $e'));
      }
    }
  }

  void _onMarkChatAsRead(MarkChatAsRead event, Emitter<ChatsState> emit) {
    final currentState = state;
    if (currentState is ChatsLoaded) {
      try {
        _chatService.markChatAsRead(event.chatId);
        final updatedChats = _chatService.getAllChats();
        emit(ChatsLoaded(chats: updatedChats));
      } catch (e) {
        emit(ChatsError('Ошибка отметки как прочитанное: $e'));
      }
    }
  }

  void _onUpdateOnlineStatus(UpdateOnlineStatus event, Emitter<ChatsState> emit) {
    final currentState = state;
    if (currentState is ChatsLoaded) {
      try {
        _chatService.updateOnlineStatus(event.chatId, event.isOnline);
        final updatedChats = _chatService.getAllChats();
        emit(ChatsLoaded(chats: updatedChats));
      } catch (e) {
        emit(ChatsError('Ошибка обновления статуса: $e'));
      }
    }
  }
}
