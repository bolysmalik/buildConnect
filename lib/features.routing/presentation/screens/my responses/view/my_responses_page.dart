import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/app.dart';
import 'package:flutter_valhalla/core/mock/mock_services.dart';
import 'package:flutter_valhalla/core/utils/registration_role_extension.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/my%20responses/repositoryes/requests_repository.dart';
import 'package:flutter_valhalla/features/routing/presentation/widgets/request_card.dart';
import 'package:flutter_valhalla/features/routing/presentation/widgets/request_details_sheet.dart'; // ✅ добавь импорт
import '../../chats/pages/chat_page.dart';
import '../../../blocs/bloc/chat_bloc.dart';
import '../../../blocs/bloc/chat_event.dart';
import '../../chats/repositories/file_repository.dart';

class MyResponsesPage extends StatefulWidget {
  final bool showAppBar;
  final bool showRefreshAction;
  final UserRole userRole;

  const MyResponsesPage({
    super.key,
    this.showAppBar = true,
    this.showRefreshAction = true,
    required this.userRole,
  });

  @override
  State<MyResponsesPage> createState() => _PerformerRequestsScreenState();
}

class _PerformerRequestsScreenState extends State<MyResponsesPage> {
  final MockServiceManager _serviceManager = MockServiceManager();
  final RequestsRepository _repository = RequestsRepository(); 
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'all';
  StreamSubscription? _newRequestSubscription;
  late UserRole activeRole;

  @override
  void initState() {
    super.initState();
    final authService = MockAuthService();

    activeRole = widget.userRole != UserRole.unauthorized
        ? widget.userRole
        : authService.getActiveRole()?.toUserRole() ?? UserRole.unauthorized;
    _loadRequests();
    _subscribeToNewRequests();
  }

  @override
  void dispose() {
    _newRequestSubscription?.cancel();
    super.dispose();
  }

  Future<void> _subscribeToNewRequests() async {
    try {
      await _serviceManager.initialize();

      _newRequestSubscription = _serviceManager.newRequestStream.listen(
        (requestType) {
          if (mounted) {
            _loadRequests();

            String requestTypeName = 'Новая заявка';
            switch (requestType) {
              case 'material':
                requestTypeName = 'Новая заявка на материалы';
                break;
              case 'foreman':
                requestTypeName = 'Новая заявка для бригадира';
                break;
              case 'courier':
                requestTypeName = 'Новая заявка для курьера';
                break;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(requestTypeName),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'Посмотреть',
                  textColor: Colors.white,
                  onPressed: () {
                    setState(() {
                      _selectedFilter = 'all';
                    });
                  },
                ),
              ),
            );
          }
        },
        onError: (error) {
          print('Ошибка при подписке на новые заявки: $error');
        },
      );
    } catch (e) {
      print('Ошибка инициализации подписки на новые заявки: $e');
    }
  }

  // ✅ УПРОЩЁННЫЙ _loadRequests
  Future<void> _loadRequests() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final requests = await _repository.loadResponsesForUser(activeRole);
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Ошибка загрузки заявок: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredRequests {
    if (_selectedFilter == 'all') return _requests;
    return _requests
        .where((request) => request['type'] == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Мои отклики'),
              elevation: 1,
              actions: [
                if (widget.showRefreshAction)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadRequests,
                  ),
              ],
            )
          : null,
      body: Column(
        children: [
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text('Загрузка заявок...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRequests,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Повторить', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final filteredRequests = _filteredRequests;

    if (filteredRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Пока нет новых заявок'),
            SizedBox(height: 8),
            Text('Новые заявки появятся здесь'),
            SizedBox(height: 24),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      color: Colors.green,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredRequests.length,
        itemBuilder: (context, index) {
          final request = filteredRequests[index];
          return RequestCard(
            request: request,
            userRole: activeRole,
            onDetails: (req) => _showRequestDetails(req),
            showRespondButton: false,
            showStatus: true,
            showBudgetAlways: true,
          );
        },
      ),
    );
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RequestDetailsSheet(
        request: request,
        onOpenChat: _openChatWithCustomer,
      ),
    );
  }

  Future<void> _openChatWithCustomer(Map<String, dynamic> request) async {
    try {
      final currentUser = _serviceManager.authService.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка: пользователь не авторизован'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final customerId = request['customerId'];
      if (customerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка: не удалось найти заказчика'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text('Открываем чат...'),
              ],
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }

      final chatResult = await _serviceManager.chatService.getOrCreateChat(
        currentUser['id'],
        customerId,
      );

      if (chatResult['success'] && chatResult['chat'] != null) {
        final chat = chatResult['chat'];
        final customerInfo = await _serviceManager.authService.getUserById(
          customerId,
        );
        final customerName = customerInfo?['name'] ?? 'Заказчик';

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) =>
                    ChatBloc(fileRepository: FileRepository())
                      ..add(InitializeChat(chat['id'])),
                child: ChatPage(
                  chatId: chat['id'],
                  contactName: customerName,
                  contactPhoto: customerInfo?['photo'],
                ),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ошибка при создании чата'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
