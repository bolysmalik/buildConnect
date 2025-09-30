import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/core/mock/mock_services.dart';
import 'package:flutter_valhalla/core/mock/mock_database.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/chats/pages/chat_page.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/bloc/chat_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/chats/repositories/file_repository.dart';
import 'package:flutter_valhalla/features/routing/presentation/utils/performer_utils.dart';

class ResponsesListPage extends StatefulWidget {
  final Map<String, dynamic> request;
  final MockServiceManager serviceManager;

  const ResponsesListPage({
    super.key,
    required this.request,
    required this.serviceManager,
  });

  @override
  State<ResponsesListPage> createState() => _ResponsesListPageState();
}

class _ResponsesListPageState extends State<ResponsesListPage> {
  List<Map<String, dynamic>> _responses = [];
  final _db = MockDatabase();

  @override
  void initState() {
    super.initState();
    _loadResponses();
  }

  void _loadResponses() {
    setState(() {
      _responses = _db.getResponsesForRequest(widget.request['id']);
    });
  }

  Future<void> _acceptResponse(String responseId) async {
    try {
      final result = await widget.serviceManager.requestsService.acceptResponse(
        responseId,
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        _loadResponses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при принятии отклика: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Отклики на "${widget.request['title'] ?? 'Заявка'}"'),
      ),
      body: _responses.isEmpty
          ? const Center(child: Text('Нет откликов на эту заявку.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _responses.length,
              itemBuilder: (context, index) {
                final response = _responses[index];
                final isAccepted = response['status'] == 'accepted';
                final isRejected = response['status'] == 'rejected';
                return _buildResponseCard(
                  context,
                  response,
                  isAccepted,
                  isRejected,
                );
              },
            ),
    );
  }

  Widget _buildResponseCard(
    BuildContext context,
    Map<String, dynamic> response,
    bool isAccepted,
    bool isRejected,
  ) {
    final user = _db.getUserById(response['responderId']);
    final performerName = user != null
        ? user['name']
        : response['responderId'] ?? 'Исполнитель';
    final performerType = user != null ? user['role'] : 'unknown';
    String performerDescription = 'Краткая информация отсутствует.';
    if (user != null) {
      if (user['role'] == 'foreman') {
        if (user['specialization'] != null && user['experience'] != null) {
          performerDescription =
              'Специализация: ${user['specialization']}, опыт: ${user['experience']}';
        } else if (user['specialization'] != null) {
          performerDescription = 'Специализация: ${user['specialization']}';
        } else {
          performerDescription = 'Бригадир';
        }
      } else if (user['role'] == 'supplier') {
        if (user['companyName'] != null && user['address'] != null) {
          performerDescription =
              'Компания: ${user['companyName']}, адрес: ${user['address']}';
        } else if (user['companyName'] != null) {
          performerDescription = 'Компания: ${user['companyName']}';
        } else {
          performerDescription = 'Поставщик';
        }
      } else if (user['role'] == 'courier') {
        if (user['vehicleType'] != null) {
          performerDescription = 'Транспорт: ${user['vehicleType']}';
        } else {
          performerDescription = 'Курьер';
        }
      } else {
        if (user['city'] != null) {
          performerDescription = 'Город: ${user['city']}';
        } else {
          performerDescription = 'Исполнитель';
        }
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isAccepted
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  getPerformerIcon(performerType),
                  color: getPerformerColor(performerType),
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        performerName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        getPerformerTypeName(performerType),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAccepted)
                  const Icon(Icons.check_circle, color: Colors.green),
                if (isRejected) const Icon(Icons.cancel, color: Colors.red),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              performerDescription,
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    // ✅ Убираем условие isAccepted || isRejected
                    onPressed: () {
                      final db = MockDatabase();
                      final authService = MockAuthService();
                      final currentUser = authService.currentUser;
                      final responderId = response['responderId'];

                      if (currentUser == null || responderId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Ошибка: не удалось определить пользователей для чата',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      
                      String? chatId;
                      final userChats = db.getChatsByUserId(
                        currentUser['id'],
                      );

                      for (final chat in userChats) {
                        final participants = List<String>.from(
                          chat['participants'] ?? [],
                        );
                        if (participants.contains(responderId) &&
                            participants.contains(currentUser['id'])) {
                          chatId = chat['id'];
                          break;
                        }
                      }
                      
                      chatId ??= db.createChat([
                        currentUser['id'],
                        responderId,
                      ]);

                      final user = db.getUserById(response['responderId']);
                      final contactName = user != null
                          ? user['name']
                          : response['responderId'] ?? 'Исполнитель';
                      final contactPhoto = user != null ? user['photo'] : null;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => ChatBloc(
                              fileRepository: FileRepository(),
                            ),
                            child: ChatPage(
                              contactName: contactName,
                              contactPhoto: contactPhoto,
                              chatId: chatId,
                              request: widget.request,
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Написать'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isAccepted || isRejected
                        ? null
                        : () async {
                            await _acceptResponse(response['id']);
                            
                            final notif = {
                                'id':
                                    'notif_${DateTime.now().millisecondsSinceEpoch}',
                                'userId': response['responderId'],
                                'title': 'Заказчик принял ваш отклик',
                                'body':
                                    'Ваше предложение по заявке "${widget.request['title']}" принято заказчиком.',
                                'type': 'response',
                                'createdAt': DateTime.now().toIso8601String(),
                                'isRead': false,
                            };
                            _db.addNotification(notif);
                          },
                    icon: const Icon(Icons.done),
                    label: const Text('Принять'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAccepted
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}