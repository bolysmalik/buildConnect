import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/widgets/service_details_sheet.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../blocs/bloc/chat_bloc.dart';
import '../../../blocs/bloc/chat_event.dart';
import '../../../blocs/bloc/chat_state.dart';
import '../../../blocs/chats/chats_bloc.dart';
import '../../../blocs/chats/chats_event.dart';
import '../../../../data/models/message.dart';
import '../../../../data/models/attachment.dart';
import '../../../../../../shared/widgets/image_viewer_page.dart';
import '../../../../../../shared/widgets/file_viewer_dialog.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../rtc_page.dart';

class ChatPage extends StatefulWidget {
  final String? contactName;
  final String? contactPhoto;
  final String? chatId;
  final Map<String, dynamic>? request;
  final Function(String chatId)? onChatClosed; 
  
  const ChatPage({
    super.key,
    this.contactName,
    this.contactPhoto,
    this.chatId,
    this.request,
    this.onChatClosed,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _messageController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'ru_RU';
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    
    // Слушаем изменения в поле ввода
    _messageController.addListener(_onTextChanged);
    // Инициализируем чат, если передан chatId
    if (widget.chatId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ChatBloc>().add(InitializeChat(widget.chatId!));
      });
    }
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _animationController.dispose();
    _messageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // ✅ Используем BlocConsumer для ChatBloc
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatLoaded) {
            if (state.isAttachmentMenuVisible) {
              _animationController.forward();
            } else {
              _animationController.reverse();
            }
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
              context.read<ChatBloc>().add(ClearError());
            }
          }
        },
        builder: (context, state) {
          if (state is ChatLoaded) {
            return Stack(
              children: [
                Column(
                  children: <Widget>[
                    Expanded(child: _buildChatBody(state.messages)),
                    _buildInputBar(state),
                  ],
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(
            Icons.arrow_back_ios,
        ),
        onPressed: () {
          if (widget.chatId != null) {
            widget.onChatClosed?.call(widget.chatId!);
          }
          Navigator.pop(context);
        },
      ),
      title: Text(
        widget.contactName ?? 'Чат',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: false,
      elevation: 1,
      actions: [
        BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatLoaded) {
              return IconButton(
                icon: const Icon(Icons.videocam),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RtcPage()),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildChatBody(List<Message> messages) {
    final request = widget.request;

    return Column(
      children: [
        // Заявка на услуги (отдельный элемент, не сообщение)
        if (request != null)
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return ServiceDetailsSheet(
                    showContactButton: false,
                    service: request,
                    onContact: () {
                      // Здесь можно реализовать нужную логику, например, отправку сообщения или переход
                    },
                  );
                },
              );
            },
            child: _buildApplicationCard(
              title: request['title'] ?? 'Название не указано',
              description: request['description'] ?? 'Описание не указано',
            ),
          ),
        SizedBox(height: 8),
      // Список сообщений
      Expanded(
        child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _getMessagesWithDateHeaders(messages).length,
            itemBuilder: (context, index) {
              final item = _getMessagesWithDateHeaders(messages)[index];
              if (item is String) {
                return _buildDateHeader(item);
              } else if (item is Message) {
                return _buildMessageBubble(item);
              }
              return Container();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationCard({
  required String title,
  required String description,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.0),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 5.0, spreadRadius: 1.0),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(Icons.list_alt, color: Color(0xFF7465FF)),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, // Используем параметр title
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description, // Используем параметр description
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildMessageBubble(Message message) {
    // Для сообщений только с вложениями используем компактный стиль
    final bool hasValidAttachment = message.attachmentType != null && 
                                   message.attachmentType!.isNotEmpty &&
                                   (message.attachmentType == 'image' || message.attachmentType == 'file');
    // Для изображений без текста используем компактный стиль, для файлов - обычный (чтобы показать название)
    final bool isAttachmentOnly = hasValidAttachment && 
                                 message.attachmentType == 'image' && 
                                 message.text.isEmpty;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isAttachmentOnly ? 1.0 : 2.0, horizontal: 12.0),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Основное содержимое сообщения без аватарок
          isAttachmentOnly
            ? // Для вложений без текста используем компактный режим
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: GestureDetector(
                  onTap: () => _handleAttachmentTap(message),
                  child: _buildAttachmentPreview(message),
                ),
              )
            : // Для обычных сообщений и сообщений с текстом
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: GestureDetector(
                  onTap: hasValidAttachment ? () => _handleAttachmentTap(message) : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasValidAttachment) ...[
                          _buildAttachmentPreview(message),
                          if (message.text.isNotEmpty) SizedBox(height: 8),
                        ],
                        if (message.text.isNotEmpty || !hasValidAttachment)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (message.text.isNotEmpty)

                              SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatMessageTime(message.timestamp),
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  // Показываем статус только для своих сообщений
                                  if (message.isMe)
                                    _buildMessageStatus(message.status),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildMessageStatus(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Container(
          width: 12,
          height: 12,
          margin: EdgeInsets.only(left: 4),
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withValues(alpha: 0.7),
            ),
          ),
        );
      case MessageStatus.sent:
        return Padding(
          padding: EdgeInsets.only(left: 4),
          child: Icon(
            Icons.check,
            size: 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        );
      case MessageStatus.delivered:
        return Padding(
          padding: EdgeInsets.only(left: 4),
          child: SizedBox(
            width: 18,
            height: 14,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                Positioned(
                  left: 6,
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      case MessageStatus.read:
        return Padding(
          padding: EdgeInsets.only(left: 4),
          child: SizedBox(
            width: 18,
            height: 14,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: Color(0xFF00BCD4), // Синий цвет для прочитанных
                  ),
                ),
                Positioned(
                  left: 6,
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: Color(0xFF00BCD4), // Синий цвет для прочитанных
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildFileMessageStatus(MessageStatus status, bool isMe) {
    Color iconColor = isMe 
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.grey[500]!;
    Color readColor = Color(0xFF7465FF);

    switch (status) {
      case MessageStatus.sending:
        return Container(
          width: 12,
          height: 12,
          margin: EdgeInsets.only(left: 4),
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(iconColor),
          ),
        );
      case MessageStatus.sent:
        return Padding(
          padding: EdgeInsets.only(left: 4),
          child: Icon(
            Icons.check,
            size: 14,
            color: iconColor,
          ),
        );
      case MessageStatus.delivered:
        return Padding(
          padding: EdgeInsets.only(left: 4),
          child: SizedBox(
            width: 18,
            height: 14,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: iconColor,
                  ),
                ),
                Positioned(
                  left: 6,
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
        );
      case MessageStatus.read:
        return Padding(
          padding: EdgeInsets.only(left: 4),
          child: SizedBox(
            width: 18,
            height: 14,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: readColor,
                  ),
                ),
                Positioned(
                  left: 6,
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: readColor,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildAttachmentMessageStatus(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Container(
          width: 12,
          height: 12,
          margin: EdgeInsets.only(left: 4),
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      case MessageStatus.sent:
        return Padding(
          padding: EdgeInsets.only(left: 4),
          child: Icon(
            Icons.check,
            size: 14,
            color: Colors.white,
          ),
        );
      case MessageStatus.delivered:
        return Padding(
          padding: EdgeInsets.only(left: 4),
          child: SizedBox(
            width: 18,
            height: 14,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  left: 6,
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      case MessageStatus.read:
        return Padding(
          padding: EdgeInsets.only(left: 4),
          child: SizedBox(
            width: 18,
            height: 14,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: Color(0xFF00BCD4), // Синий цвет для прочитанных
                  ),
                ),
                Positioned(
                  left: 6,
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: Color(0xFF00BCD4), // Синий цвет для прочитанных
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildInputBar(ChatLoaded state) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark 
          ? AppColors.darkSurface 
          : Colors.white,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            // Показать pending attachments, если они есть
            if (state.pendingAttachments.isNotEmpty)
              _buildPendingAttachments(state.pendingAttachments),
            
            // Анимированное меню вложений
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: state.isAttachmentMenuVisible ? 50 : 0,
              child: ClipRect(
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 250),
                  opacity: state.isAttachmentMenuVisible ? 1.0 : 0.0,
                  child: _buildAttachmentMenu(state.isAttachmentMenuVisible),
                ),
              ),
            ),
            // Основная строка ввода
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Row(
                children: <Widget>[
                  AnimatedRotation(
                    turns: state.isAttachmentMenuVisible ? 0.125 : 0.0, // поворот на 45 градусов
                    duration: Duration(milliseconds: 300),
                    child: IconButton(
                      icon: Icon(Icons.add, color: Color(0xFF007AFF), size: 28),
                      onPressed: () {
                        context.read<ChatBloc>().add(const ToggleAttachmentMenu());
                      },
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: 40,
                        maxHeight: 120, // Максимальная высота как в Telegram
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? AppColors.darkCard 
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: null, // Разрешаем неограниченное количество строк
                        minLines: 1,    // Минимум 1 строка
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline, // Enter создает новую строку
                        decoration: InputDecoration(
                          hintText: 'Написать сообщение...',
                          hintStyle: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? AppColors.darkTextHint 
                                : Colors.grey[600]
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          isDense: true,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.2, // Междустрочный интервал
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? AppColors.darkTextPrimary 
                              : Colors.black,
                        ),
                        onSubmitted: (text) {
                          // В многострочном режиме Enter не отправляет сообщение
                          // Но мы можем добавить поддержку Ctrl+Enter
                        },
                        onChanged: (text) {
                          // Дополнительная проверка на изменение текста
                          _onTextChanged();
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      final hasAttachments = state is ChatLoaded && state.pendingAttachments.isNotEmpty;
                      final canSend = _hasText || hasAttachments;
                      
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: canSend ? Color(0xFF7465FF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: canSend ? _sendMessage : null,
                          icon: Transform.rotate(
                            angle: -45 * 3.14159265359 / 180,
                            child: Icon(
                              Icons.send, 
                              color: canSend ? Colors.white : Color(0xFF7465FF), 
                              size: 22,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentMenu(bool isMenuVisible) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            transform: Matrix4.translationValues(
              0, isMenuVisible ? 0 : 20, 0
            ),
            child: _buildAttachmentIcon(
              Icons.camera_alt_outlined,
              () => context.read<ChatBloc>().add(const OpenCamera()),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 350),
            curve: Curves.elasticOut,
            transform: Matrix4.translationValues(
              0, isMenuVisible ? 0 : 20, 0
            ),
            child: _buildAttachmentIcon(
              Icons.image_outlined,
              () => context.read<ChatBloc>().add(const OpenGallery()),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            transform: Matrix4.translationValues(
              0, isMenuVisible ? 0 : 20, 0
            ),
            child: _buildAttachmentIcon(
              Icons.file_copy_outlined,
              () => context.read<ChatBloc>().add(const OpenFilePicker()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentIcon(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Icon(
            icon, 
            size: 28, 
            color: Color(0xFF007AFF),
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    final currentState = context.read<ChatBloc>().state;
    if (currentState is ChatLoaded) {
      // Отправляем если есть текст или вложения
      if (_messageController.text.trim().isNotEmpty || currentState.pendingAttachments.isNotEmpty) {
        final messageText = _messageController.text;
        
        // Отправляем сообщение в ChatBloc
        context.read<ChatBloc>().add(SendMessageToMock(messageText));
        
        // Если есть chatId, обновляем также ChatsBloc
        if (widget.chatId != null) {
          final newMessage = Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: messageText,
            isMe: true,
            timestamp: DateTime.now(),
            status: MessageStatus.sending,
          );
          
          // Проверяем, доступен ли ChatsBloc
          try {
            context.read<ChatsBloc>().add(UpdateChatWithMessage(
              chatId: widget.chatId!,
              message: newMessage,
            ));
          } catch (e) {
            // ChatsBloc может быть недоступен, игнорируем ошибку
            print('ChatsBloc не доступен: $e');
          }
        }
        
        _messageController.clear();
        // _hasText обновится автоматически через _onTextChanged listener
      }
    }
  }

  Widget _buildAttachmentPreview(Message message) {
    if (message.attachmentType == null) return Container();
    
    final isImage = message.attachmentType == 'image';
    
    if (isImage && message.attachmentPath != null) {
      // Для изображений показываем компактный thumbnail
      final imageFile = File(message.attachmentPath!);
      
      return Container(
        constraints: BoxConstraints(
          maxWidth: 250,  // Увеличили максимальную ширину
          maxHeight: 300, // Увеличили максимальную высоту
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),  // Уменьшили радиус
              child: imageFile.existsSync() 
                ? Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image,
                          color: Colors.grey[400],
                          size: 40,
                        ),
                      );
                    },
                  )
                : Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.grey[400],
                          size: 30,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Файл не найден',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
            // Время в правом нижнем углу изображения (как в WhatsApp)
            if (message.text.isEmpty)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatMessageTime(message.timestamp),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Показываем статус для своих сообщений
                      if (message.isMe)
                        _buildAttachmentMessageStatus(message.status),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    } else if (message.attachmentType == 'file' && message.attachmentPath != null) {
      // Для файлов показываем компактный вид как в WhatsApp
      final bool showTimeInFile = message.text.isEmpty; // Показываем время в файле, если нет текста
      
      return Container(
        width: double.infinity, // Занимаем всю доступную ширину
        constraints: BoxConstraints(
          maxWidth: 280,
          minHeight: 60, // Минимальная высота для файла
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMe ? Color(0xFF7465FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: !message.isMe ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4.0,
              spreadRadius: 0.5,
            ),
          ] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: message.isMe ? Colors.white.withValues(alpha: 0.2) : Color(0xFF7465FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.description,
                    size: 20,
                    color: message.isMe ? Colors.white : Color(0xFF7465FF),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Документ',
                        style: TextStyle(
                          color: message.isMe ? Colors.white : Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.download_outlined,
                  size: 18,
                  color: message.isMe ? Colors.white.withValues(alpha: 0.8) : Colors.grey[600],
                ),
              ],
            ),
            // Показываем время внизу файла, если нет текста
            if (showTimeInFile) ...[
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatMessageTime(message.timestamp),
                      style: TextStyle(
                        color: message.isMe 
                          ? Colors.white.withValues(alpha: 0.7) 
                          : Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                    // Показываем статус для своих сообщений
                    if (message.isMe)
                      _buildFileMessageStatus(message.status, message.isMe),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }
    
    // Fallback для неизвестных типов вложений
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Неподдерживаемое вложение',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  void _handleAttachmentTap(Message message) {
    if (message.attachmentType == null || message.attachmentPath == null) {
      return;
    }

    // Отправляем событие в BLoC для логирования
    context.read<ChatBloc>().add(ViewAttachment(
      messageId: message.id,
      attachmentType: message.attachmentType!,
      attachmentPath: message.attachmentPath,
    ));

    // Открываем вложение в зависимости от типа
    if (message.attachmentType == 'image') {
      _openImageViewer(message.attachmentPath!);
    } else if (message.attachmentType == 'file') {
      _openFileViewer(message.attachmentPath!);
    }
  }

  void _openImageViewer(String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageViewerPage(imagePath: imagePath),
      ),
    );
  }

  void _openFileViewer(String filePath) {
    final fileName = filePath.split('/').last;
    showDialog(
      context: context,
      builder: (context) => FileViewerDialog(
        filePath: filePath,
        fileName: fileName,
      ),
    );
  }

  List<dynamic> _getMessagesWithDateHeaders(List<Message> messages) {
    List<dynamic> result = [];
    String? lastDate;

    for (Message message in messages) {
      String currentDate = _formatDateHeader(message.timestamp);
      
      if (lastDate == null || lastDate != currentDate) {
        result.add(currentDate);
        lastDate = currentDate;
      }
      
      result.add(message);
    }

    return result;
  }

  String _formatDateHeader(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return 'Сегодня';
    } else if (messageDate == yesterday) {
      return 'Вчера';
    } else {
      return DateFormat('d MMMM yyyy', 'ru').format(dateTime);
    }
  }

  String _formatMessageTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  Widget _buildDateHeader(String dateText) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? AppColors.darkCard 
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            dateText,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.darkTextSecondary 
                  : Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingAttachments(List<Attachment> attachments) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Готово к отправке:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: attachments.length,
              itemBuilder: (context, index) {
                final attachment = attachments[index];
                return _buildPendingAttachmentItem(attachment);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingAttachmentItem(Attachment attachment) {
    return Container(
      width: 70,
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: attachment.type == 'image' 
              ? () {
                  final imageFile = File(attachment.path);
                  return imageFile.existsSync()
                    ? Image.file(
                        imageFile,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey[200],
                            child: Icon(Icons.image, color: Colors.grey[400]),
                          );
                        },
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        color: Colors.red[100],
                        child: Icon(Icons.error, color: Colors.red[400]),
                      );
                }()
              : Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[50],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color(0xFF7465FF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(Icons.description, color: Color(0xFF7465FF), size: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        attachment.name?.split('.').last.toUpperCase() ?? 'DOC',
                        style: TextStyle(fontSize: 8, color: Colors.grey[600], fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                context.read<ChatBloc>().add(RemovePendingAttachment(attachment.id));
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
