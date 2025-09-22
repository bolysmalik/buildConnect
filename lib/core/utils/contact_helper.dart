import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/chats/pages/chat_page.dart';
import '../../features/routing/presentation/blocs/bloc/chat_bloc.dart';
import '../../features/routing/presentation/screens/login & reg/login/view/login_page.dart';
import '../../features/routing/presentation/screens/chats/repositories/file_repository.dart';
import '../mock/mock_auth_service.dart';
import '../mock/mock_database.dart';
class ContactHelper {
  static Future<void> openChat(BuildContext context, Map<String, dynamic> service) async {
    try {
      final authService = MockAuthService();
      final db = MockDatabase();
      final currentUser = authService.currentUser;

      // 🔹 Проверка авторизации
      if (currentUser == null) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AccountPage()),
        );
        return;
      }

      final providerId = service['providerId'] ?? service['id'] ?? service['userId'];
      final contactName = service['providerName'] ?? service['name'] ?? 'Исполнитель';
      final contactPhoto = service['providerPhoto'];

      if (providerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка: не найден ID исполнителя'), backgroundColor: Colors.red),
        );
        return;
      }

      // Проверяем чаты между текущим пользователем и провайдером
      String? chatId;
      final userChats = db.getChatsByUserId(currentUser['id']);
      for (final chat in userChats) {
        final participants = List<String>.from(chat['participants'] ?? []);
        if (participants.contains(providerId) && participants.contains(currentUser['id'])) {
          chatId = chat['id'];
          break;
        }
      }

      // Если чата нет — создаём
      chatId ??= db.createChat([currentUser['id'], providerId]);

      void handleChatClosure(String closedChatId) {
        final chatData = MockDatabase().getChatById(closedChatId);
        final messages = chatData?['messages'] as List? ?? [];

        if (messages.isEmpty) {
          MockDatabase().removeChat(closedChatId);
          print('Пустой чат $closedChatId удален.');
        }
      }

      // Открываем страницу чата
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ChatBloc(fileRepository: FileRepository()),
            child: ChatPage(
              contactName: contactName,
              contactPhoto: contactPhoto,
              chatId: chatId,
              request: service,
              onChatClosed: handleChatClosure,
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
