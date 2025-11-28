import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_page.dart';
import '../../../blocs/bloc/chat_bloc.dart';
import '../../../blocs/chats/chats_event.dart';
import '../../../blocs/chats/chats_state.dart';
import '../repositories/file_repository.dart';
import '../../../../../../core/mock/mock_chats_bloc.dart';
import '../../../../../../core/theme/app_colors.dart';


class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

// Обертка с BlocProvider для MockChatsBloc
class MessagesScreenWithBloc extends StatelessWidget {
  const MessagesScreenWithBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MockChatsBloc(),
      child: const MessagesScreen(),
    );
  }
}

class MockChatsBloc {
}

class _MessagesScreenState extends State<MessagesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this); 
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<MockChatsBloc>().add(const LoadChats());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  BlocBuilder<MockChatsBloc, ChatsState>(
            builder: (context, state) {
              if (state is ChatsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ChatsError) {
                return Center(child: Text('Ошибка: ${state.message}'));
              } else if (state is ChatsLoaded) {
                final chats = state.chats;
                return chats.isEmpty
                    ? const Center(child: Text('Нет активных чатов.'))
                    : ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 1),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: const Color(0xFF7465FF),
                              child: chat.photo != null
                                  ? ClipOval(
                                      child: Image.network(
                                        chat.photo!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.person, color: Colors.white, size: 28);
                                        },
                                      ),
                                    )
                                  : const Icon(Icons.person, color: Colors.white, size: 28),
                            ),
                            // Индикатор онлайн статуса
                            if (chat.isOnline)
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                chat.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              chat.lastMessageTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: chat.unreadCount > 0 
                                    ? const Color(0xFF7465FF) 
                                    : (Theme.of(context).brightness == Brightness.dark 
                                        ? AppColors.darkTextHint 
                                        : Colors.grey[600]),
                                fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                chat.lastMessageText,
                                style: TextStyle(
                                  fontWeight: chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (chat.unreadCount > 0)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7465FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  chat.unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          context.read<MockChatsBloc>().add(MarkChatAsRead(chat.id));
                          final chatsBloc = context.read<MockChatsBloc>();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MultiBlocProvider(
                                providers: [
                                  BlocProvider(
                                    create: (context) => ChatBloc(
                                      fileRepository: FileRepository(),
                                    ),
                                  ),
                                  BlocProvider.value(
                                    value: chatsBloc,
                                  ),
                                ],
                                child: ChatPage(
                                  contactName: chat.name,
                                  contactPhoto: chat.photo,
                                  chatId: chat.id,

                                ),
                              ),
                            ),
                          ).then((_) {
                            chatsBloc.add(const LoadChats());
                          });
                        },
                      ),
                    );
                  },
                );
              } else {
                return const Center(child: Text('Нет активных чатов.'));
              }
            },
          ),
        
    );
  }
}