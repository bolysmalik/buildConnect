import 'package:bloc/bloc.dart';
import 'dart:async';
import '../../../data/models/message.dart';
import '../../../data/models/attachment.dart';
import '../../screens/chats/repositories/file_repository.dart';
import '../../../../../core/mock/mock_services.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FileRepository _fileRepository;
  final MockServiceManager _serviceManager = MockServiceManager();
  String? _currentChatId;
  StreamSubscription? _messageSubscription;

  ChatBloc({required FileRepository fileRepository})
      : _fileRepository = fileRepository,
        super(const ChatInitial()) {
    
    on<InitializeChat>(_onInitializeChat);
    on<LoadChatMessages>(_onLoadChatMessages);
    on<SendMessageToMock>(_onSendMessageToMock);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
    on<SendMessage>(_onSendMessage);
    on<OpenCamera>(_onOpenCamera);
    on<OpenGallery>(_onOpenGallery);
    on<OpenFilePicker>(_onOpenFilePicker);
    on<ToggleAttachmentMenu>(_onToggleAttachmentMenu);
    on<AddAttachment>(_onAddAttachment);
    on<AddPendingAttachment>(_onAddPendingAttachment);
    on<RemovePendingAttachment>(_onRemovePendingAttachment);
    on<ClearPendingAttachments>(_onClearPendingAttachments);
    on<ViewAttachment>(_onViewAttachment);
    on<DownloadFile>(_onDownloadFile);
    on<ClearError>(_onClearError);
    on<UpdateMessageStatus>(_onUpdateMessageStatus);
    on<UpdateCallStatus>(_onUpdateCallStatus);
    // Инициализируем без тестовых сообщений
    emit(const ChatLoaded(messages: []));
  }


  // ✅ ИСПРАВЛЕННЫЙ МЕТОД: _onSendMessage
  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is ChatLoaded) {
      try {
        // ✅ ПЕРЕНЕСЕННАЯ ПРОВЕРКА: Если нет текста И нет вложений, ничего не делаем.
        if (event.text.trim().isEmpty && currentState.pendingAttachments.isEmpty) {
          return;
        }
        
        List<Message> newMessages = [];

        // Если есть текст, создаем текстовое сообщение
        if (event.text.trim().isNotEmpty) {
          final textMessage = Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: event.text.trim(),
            isMe: true,
            timestamp: DateTime.now(),
            status: MessageStatus.sending,
          );
          newMessages.add(textMessage);
        }

        // Создаем сообщения для каждого вложения
        for (int i = 0; i < currentState.pendingAttachments.length; i++) {
          final attachment = currentState.pendingAttachments[i];
          final attachmentMessage = Message(
            id: '${DateTime.now().millisecondsSinceEpoch}_${attachment.id}_$i',
            text: '',
            isMe: true,
            timestamp: DateTime.now().add(Duration(milliseconds: i)),
            attachmentType: attachment.type,
            attachmentPath: attachment.path,
            status: MessageStatus.sending,
          );
          newMessages.add(attachmentMessage);
        }

        final updatedMessages = List<Message>.from(currentState.messages)
          ..addAll(newMessages);

        // Очищаем pending attachments и обновляем сообщения
        emit(currentState.copyWith(
          messages: updatedMessages,
          pendingAttachments: [],
          errorMessage: null,
        ));

        // Запускаем симуляцию изменения статусов для новых сообщений
        _simulateMessageStatuses(newMessages, emit);

        // Симуляция ответа только для текстовых сообщений
        if (event.text.trim().isNotEmpty) {
          await _simulateResponse(emit);
        }
      } catch (e) {
        emit(currentState.copyWith(
          errorMessage: 'Ошибка при отправке сообщения: $e',
        ));
      }
    }
  }

  // ... остальной код Bloc

    void _onToggleAttachmentMenu(ToggleAttachmentMenu event, Emitter<ChatState> emit) {
      final currentState = state;
      if (currentState is ChatLoaded) {
        emit(currentState.copyWith(
          isAttachmentMenuVisible: !currentState.isAttachmentMenuVisible,
        ));
      }
    }

    Future<void> _onOpenCamera(OpenCamera event, Emitter<ChatState> emit) async {
      final currentState = state;
      if (currentState is ChatLoaded) {
        // Закрываем меню
        emit(currentState.copyWith(isAttachmentMenuVisible: false));

        try {
          final image = await _fileRepository.pickImageFromCamera();
          if (image != null) {
            add(AddPendingAttachment(
              type: 'image',
              path: image.path,
            ));
          }
        } catch (e) {
          emit(currentState.copyWith(
            errorMessage: 'Ошибка при открытии камеры: ${e.toString()}',
          ));
        }
      }
    }

    Future<void> _onOpenGallery(OpenGallery event, Emitter<ChatState> emit) async {
      final currentState = state;
      if (currentState is ChatLoaded) {
        // Закрываем меню
        emit(currentState.copyWith(isAttachmentMenuVisible: false));

        try {
          final image = await _fileRepository.pickImageFromGallery();
          if (image != null) {
            add(AddPendingAttachment(
              type: 'image',
              path: image.path,
            ));
          }
        } catch (e) {
          emit(currentState.copyWith(
            errorMessage: 'Ошибка при открытии галереи: ${e.toString()}',
          ));
        }
      }
    }

    Future<void> _onOpenFilePicker(OpenFilePicker event, Emitter<ChatState> emit) async {
      final currentState = state;
      if (currentState is ChatLoaded) {
        // Закрываем меню
        emit(currentState.copyWith(isAttachmentMenuVisible: false));

        try {
          final file = await _fileRepository.pickFile();
          if (file != null) {
            add(AddPendingAttachment(
              type: 'file',
              path: file.path!,
              name: file.name,
            ));
          }
        } catch (e) {
          emit(currentState.copyWith(
            errorMessage: 'Ошибка при выборе файла: ${e.toString()}',
          ));
        }
      }
    }

    void _onAddAttachment(AddAttachment event, Emitter<ChatState> emit) {
      final currentState = state;
      if (currentState is ChatLoaded) {
        final newMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: event.text,
          isMe: true,
          timestamp: DateTime.now(),
          attachmentType: event.attachmentType,
          attachmentPath: event.attachmentPath,
        );

        final updatedMessages = List<Message>.from(currentState.messages)
          ..add(newMessage);

        emit(currentState.copyWith(messages: updatedMessages));
      }
    }

  void _onUpdateCallStatus(UpdateCallStatus event, Emitter<ChatState> emit) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      emit(currentState.copyWith(isCallActive: event.isActive));
    }
  }
  
    void _onAddPendingAttachment(AddPendingAttachment event, Emitter<ChatState> emit) {
      final currentState = state;
      if (currentState is ChatLoaded) {
        final newAttachment = Attachment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: event.type,
          path: event.path,
          name: event.name,
        );

        final updatedAttachments = List<Attachment>.from(currentState.pendingAttachments)
          ..add(newAttachment);

        emit(currentState.copyWith(pendingAttachments: updatedAttachments));
      }
    }

    void _onRemovePendingAttachment(RemovePendingAttachment event, Emitter<ChatState> emit) {
      final currentState = state;
      if (currentState is ChatLoaded) {
        final updatedAttachments = currentState.pendingAttachments
            .where((attachment) => attachment.id != event.attachmentId)
            .toList();

        emit(currentState.copyWith(pendingAttachments: updatedAttachments));
      }
    }

    void _onClearPendingAttachments(ClearPendingAttachments event, Emitter<ChatState> emit) {
      final currentState = state;
      if (currentState is ChatLoaded) {
        emit(currentState.copyWith(pendingAttachments: []));
      }
    }

    void _onViewAttachment(ViewAttachment event, Emitter<ChatState> emit) {
      // Этот обработчик может быть использован для логирования или статистики
      // Основная логика открытия вложений будет в UI
    }

    void _onDownloadFile(DownloadFile event, Emitter<ChatState> emit) async {
      final currentState = state;
      if (currentState is ChatLoaded) {
        try {
          // Здесь можно добавить логику скачивания файла
          // Пока что просто показываем уведомление через SnackBar в UI
        } catch (e) {
          emit(currentState.copyWith(
            errorMessage: 'Ошибка при сохранении файла',
          ));
        }
      }
    }

    void _onUpdateMessageStatus(UpdateMessageStatus event, Emitter<ChatState> emit) {
      final currentState = state;
      if (currentState is ChatLoaded) {
        final updatedMessages = currentState.messages.map((message) {
          if (message.id == event.messageId) {
            return message.copyWith(status: event.status);
          }
          return message;
        }).toList();

        emit(currentState.copyWith(messages: updatedMessages));
      }
    }

    void _simulateMessageStatuses(List<Message> newMessages, Emitter<ChatState> emit) {
      // Симулируем изменение статусов сообщений
      for (final message in newMessages) {
        if (message.isMe) {
          // Через 500мс: отправлено (одна галочка)
          Future.delayed(Duration(milliseconds: 500), () {
            if (!isClosed) {
              add(UpdateMessageStatus(messageId: message.id, status: MessageStatus.sent));
            }
          });

          // Через 1.5с: доставлено (две галочки)
          Future.delayed(Duration(milliseconds: 1500), () {
            if (!isClosed) {
              add(UpdateMessageStatus(messageId: message.id, status: MessageStatus.delivered));
            }
          });

          // Через 3с: прочитано (две синие галочки)
          Future.delayed(Duration(milliseconds: 3000), () {
            if (!isClosed) {
              add(UpdateMessageStatus(messageId: message.id, status: MessageStatus.read));
            }
          });
        }
      }
    }

    void _onClearError(ClearError event, Emitter<ChatState> emit) {
      final currentState = state;
      if (currentState is ChatLoaded) {
        emit(currentState.copyWith(errorMessage: null));
      }
    }

    Future<void> _simulateResponse(Emitter<ChatState> emit) async {
      await Future.delayed(const Duration(seconds: 1));
      if (!isClosed && !emit.isDone) {
        final currentState = state;
        if (currentState is ChatLoaded) {
          final responseMessage = Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: 'Понял, обрабатываю ваш запрос...',
            isMe: false,
            timestamp: DateTime.now(),
          );

          final updatedMessages = List<Message>.from(currentState.messages)
            ..add(responseMessage);

          emit(currentState.copyWith(messages: updatedMessages));
        }
      }
    }

    Future<void> _onInitializeChat(InitializeChat event, Emitter<ChatState> emit) async {
      _currentChatId = event.chatId;
      await _serviceManager.initialize();
      
      // Подписываемся на уведомления о прочитанных сообщениях
      _messageSubscription = _serviceManager.chatService.messageStream.listen((messageData) {
        if (messageData['type'] == 'messages_read' && messageData['chatId'] == _currentChatId) {
          // Перезагружаем сообщения чтобы обновить статусы
          add(const LoadChatMessages());
        }
      });
      
      add(const LoadChatMessages());
      // Отмечаем сообщения как прочитанные при открытии чата
     add(MarkMessagesAsRead(event.chatId));
    }

    Future<void> _onLoadChatMessages(LoadChatMessages event, Emitter<ChatState> emit) async {
  if (_currentChatId == null) return;
  
  final currentState = state;
  if (currentState is ChatLoaded) {
    try {
      final mockMessages = await _serviceManager.chatService.getChatMessages(_currentChatId!);
      final currentUser = _serviceManager.authService.currentUser;
      
      final messages = mockMessages
          .where((mockMessage) => mockMessage['text'] != null && mockMessage['text'].toString().isNotEmpty)
          .map((mockMessage) {
            final isMe = mockMessage['senderId'] == currentUser?['id']; // ✅ isMe определена
            final isRead = mockMessage['isRead'] == true;
            
            // Определяем статус сообщения
            MessageStatus status; // ✅ status определен
            if (isMe) {
              // Мои сообщения: показываем статус доставки/прочтения
              status = isRead ? MessageStatus.read : MessageStatus.delivered;
            } else {
              // Сообщения от других: всегда "отправлено"
              status = MessageStatus.sent;
            }
            
            return Message(
              id: mockMessage['id'],
              text: mockMessage['text'],
              isMe: isMe,
              timestamp: DateTime.parse(mockMessage['timestamp']),
              status: status,
              attachmentType: mockMessage['attachmentType'] as String?,
              attachmentPath: mockMessage['attachmentPath'] as String?,
            );
        }).toList();

      emit(currentState.copyWith(messages: messages));
    } catch (e) {
      emit(currentState.copyWith(errorMessage: 'Ошибка загрузки сообщений: $e'));
    }
  }
}

    Future<void> _onSendMessageToMock(SendMessageToMock event, Emitter<ChatState> emit) async {
      if (_currentChatId == null) return;
      
      final currentState = state;
      if (currentState is ChatLoaded) {
        try {
          final currentUser = _serviceManager.authService.currentUser;
          if (currentUser == null) return;

          // Проверяем, есть ли текст или вложения
          final hasText = event.text.trim().isNotEmpty;
          final hasAttachments = currentState.pendingAttachments.isNotEmpty;

          if (!hasText && !hasAttachments) return;

          // Если есть текст, отправляем текстовое сообщение
          if (hasText) {
            await _serviceManager.chatService.sendMessage(
              chatId: _currentChatId!,
              senderId: currentUser['id'],
              text: event.text,
            );
          }

          // Обрабатываем вложения из pendingAttachments
          for (final attachment in currentState.pendingAttachments) {
            // Для файлов показываем название, для изображений - нет
            final textForAttachment = attachment.type == 'file' 
                ? (attachment.name ?? 'Документ')
                : '';
                
            await _serviceManager.chatService.sendMessage(
              chatId: _currentChatId!,
              senderId: currentUser['id'],
              text: textForAttachment,
              type: attachment.type,
              attachmentUrl: attachment.path,
            );
          }

          // Очищаем pendingAttachments
          if (hasAttachments) {
            emit(currentState.copyWith(pendingAttachments: []));
          }

          // Перезагружаем сообщения
          add(const LoadChatMessages());
        } catch (e) {
          emit(currentState.copyWith(errorMessage: 'Ошибка отправки сообщения: $e'));
        }
      }
    }

    Future<void> _onMarkMessagesAsRead(MarkMessagesAsRead event, Emitter<ChatState> emit) async {
      try {
        final currentUser = _serviceManager.authService.currentUser;
        if (currentUser == null) return;

        await _serviceManager.chatService.markMessagesAsRead(event.chatId, currentUser['id']);
        
        // Уведомляем о том, что чат обновился (счетчик непрочитанных изменился)
      _serviceManager.notifyChatUpdate(event.chatId);
        
        print('Сообщения отмечены как прочитанные для чата ${event.chatId}');
      } catch (e) {
        print('Ошибка отметки сообщений как прочитанных: $e');
      }
    }

    @override
    Future<void> close() {
      _messageSubscription?.cancel();
      return super.close();
    }
  }
