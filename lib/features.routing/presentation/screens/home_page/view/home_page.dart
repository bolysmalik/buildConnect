import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/core/utils/registration_role_extension.dart';
import 'package:flutter_valhalla/features/routing/presentation/widgets/create_requests&services_bottom_sheet.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/login/view/login_page.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/home_page/widgets/customer_services_view.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/home_page/widgets/notifications_list.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/home_page/widgets/performers_requests_view.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/home_page/widgets/service_card.dart';
import 'package:flutter_valhalla/features/routing/presentation/widgets/service_details_sheet.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/home_page/widgets/services_states.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/home_page/view/service_requests_screen.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/home_page/widgets/favorites_screen.dart';
import 'package:flutter_valhalla/app.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/my%20responses/view/my_responses_page.dart';
import 'package:flutter_valhalla/core/theme/app_colors.dart';
import 'package:flutter_valhalla/core/mock/mock_auth_service.dart';
import 'package:flutter_valhalla/core/mock/mock_services.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/chats/pages/messages_screen.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/chats/pages/chat_page.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/bloc/chat_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/favorites/favorite_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/chats/repositories/file_repository.dart';
import '../../../../../../core/utils/contact_helper.dart';
import '../../../blocs/favorites/favorite_state.dart';
import '../../app drawer/app_drawer.dart';
import '../../../widgets/request_details_sheet.dart';
import '../../../blocs/favorites/favorite_event.dart';


class HomePage extends StatefulWidget {
  final UserRole userRole;

  const HomePage({super.key, required this.userRole});


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final MockServiceManager _serviceManager = MockServiceManager();
  List<Map<String, dynamic>> _foremanRequests = [];
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = false;
  String _selectedFilter = 'all';
  String? _errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    if (widget.userRole == UserRole.foreman ||
        widget.userRole == UserRole.courier ||
        widget.userRole == UserRole.supplier) {
      _loadForemanRequests();

    } else if (widget.userRole == UserRole.customer) {
      _loadServices();
    } else if (widget.userRole == UserRole.unauthorized) {
      _loadForemanRequests();

      _loadServices();
    }
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadForemanRequests() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _serviceManager.initialize();


      List<Map<String, dynamic>> requests = [];
      List<String> requestTypesToFetch = [];

      if (widget.userRole == UserRole.foreman) {
        requestTypesToFetch.add('foreman');
      } else if (widget.userRole == UserRole.courier) {
        requestTypesToFetch.add('courier');
      } else if (widget.userRole == UserRole.supplier) {
        requestTypesToFetch.add('supplier');
      } else if (widget.userRole == UserRole.unauthorized) {
        // ✅ Исправлено: Загружаем все типы заявок для неавторизованного пользователя
        requestTypesToFetch.addAll(['foreman', 'courier', 'supplier',]);
      } else {
        requestTypesToFetch = [];
      }

      print('🔍 Загружаем заявки для роли: ${widget.userRole}, типы: $requestTypesToFetch');

      for (String type in requestTypesToFetch) {
        List<Map<String, dynamic>> fetchedRequests =
        await _serviceManager.requests.getActiveRequestsForPerformers(type);
        requests.addAll(fetchedRequests);
        print('📋 Найдено заявок типа "$type": ${fetchedRequests.length}');
      }


      for (var request in requests) {
        final customer = _serviceManager.db.getUserById(request['customerId']);
        request['customerName'] = customer?['name'] ?? 'Неизвестный заказчик';
        request['customerPhone'] = customer?['phone'] ?? '';

        request['displayType'] = request['type'];
        print('👤 Заказчик для заявки ${request['id']}: ${request['customerName']}');
      }

      requests.sort((a, b) {
        final dateA = DateTime.parse(a['createdAt'] ?? '2024-01-01T00:00:00Z');
        final dateB = DateTime.parse(b['createdAt'] ?? '2024-01-01T00:00:00Z');
        return dateB.compareTo(dateA);
      });

      if (mounted) {
        setState(() {
          _foremanRequests = requests;
          _isLoading = false;
        });
        print('✅ Заявки успешно загружены и установлены в state: ${_foremanRequests.length}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('❌ Ошибка загрузки заявок: $e');
        print('❌ Stack trace: ${StackTrace.current}');
      }
    }
  }

  Future<void> _loadServices() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _serviceManager.initialize();
      final services = _serviceManager.db.getServices();

      for (var service in services) {
        final provider = _serviceManager.db.getUserById(service['providerId']);
        service['providerName'] = provider?['name'] ?? 'Неизвестный исполнитель';
      }

      if (mounted) {
        setState(() {
          _services = services;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Не удалось загрузить услуги: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredRequests() {
    if (_selectedFilter == 'all') {
      return _foremanRequests;
    } else if (_selectedFilter == 'new') {
      return _foremanRequests.where((request) => request['status'] == 'active').toList();
    } else if (_selectedFilter == 'in_progress') {
      return _foremanRequests.where((request) => request['status'] == 'in_progress').toList();
    } else if (_selectedFilter == 'urgent') {
      return _foremanRequests.where((request) {
        final budget = int.tryParse(request['budget']?.toString() ?? '0') ?? 0;
        return budget > 400000;
      }).toList();
    }
    return _foremanRequests;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      if (ModalRoute.of(context)?.settings.name != '/') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => HomePage(userRole: widget.userRole),
            settings: const RouteSettings(name: '/'),
          ),
          (route) => false,
        );
      }
    }
  }


  List<Widget> _buildContentBasedOnRole() {
    switch (widget.userRole) {
      case UserRole.customer:
        return [
          _buildSectionTitle('Для Заказчика'),
          const SizedBox(height: 16),
          const Text(
            'Используйте кнопку "Создать" для размещения новых заявок, а кнопку "Чаты" для общения с исполнителями.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            context,
            icon: Icons.business_center,
            label: 'Посмотреть услуги',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CustomerServicesScreen(),
                ),
              );
            },
          ),
        ];

      case UserRole.foreman:
      case UserRole.supplier:
      case UserRole.courier:
        return [
          _buildSectionTitle('Для Исполнителей'),
          const SizedBox(height: 16),
          _buildActionButton(
            context,
            icon: Icons.list_alt,
            label: 'Просмотреть новые заявки',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MyResponsesPage(userRole: MockAuthService().getActiveRole()?.toUserRole() ?? UserRole.unauthorized,),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            context,
            icon: Icons.assignment_turned_in,
            label: 'Мои заказы',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MyResponsesPage(userRole: MockAuthService().getActiveRole()?.toUserRole() ?? UserRole.unauthorized,),
                ),
              );
            },
          ),
        ];
      case UserRole.unauthorized:
        return [];
    }
  }

  String _getAppBarTitle() {
    if (_selectedIndex == 1) {
      return 'Market - Чаты';
    }
    switch (widget.userRole) {
      case UserRole.foreman:
        return 'Market - Бригадир';
      case UserRole.customer:
        return 'Market - Главная';
      case UserRole.supplier:
        return 'Market - Поставщик';
      case UserRole.courier:
        return 'Market - Курьер';
      case UserRole.unauthorized:
        return 'Market - Главная';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Список ролей, для которых кнопка должна быть скрыта
    final List<UserRole> hiddenRoles = [
      UserRole.foreman,
      UserRole.supplier,
      UserRole.courier,
    ];
    // Проверяем, должна ли кнопка отображаться
    final bool isButtonVisible = !hiddenRoles.contains(widget.userRole);
    if (widget.userRole == UserRole.unauthorized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Просмотр заявок'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Заказчик', icon: Icon(Icons.person)),
              Tab(text: 'Исполнитель', icon: Icon(Icons.work)),
            ],
          ),
        ),
        drawer: AppDrawer(userRole: widget.userRole),
        body: TabBarView(
          controller: _tabController,
          children: [
            CustomerServicesView(
              selectedFilter: _selectedFilter,
              buildServiceFilterChip: _buildServiceFilterChip,
              servicesList: _buildServicesList(),
              isDark: Theme.of(context).brightness == Brightness.dark,
            ),
            PerformersRequestsView(
              isLoading: _isLoading,
              requests: _getFilteredRequests(),
              userRole: widget.userRole,
              onRefresh: _loadForemanRequests,
              onDetails: _showRequestDetails,
              onRespond: _respondToRequest,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications, color: AppColors.iconPrimary),
                if (_hasUnreadNotifications())
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              _showNotificationsBottomSheet(context);
            },
            tooltip: 'Уведомления',
          ),

          if (isButtonVisible)
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.favorite, color: AppColors.iconPrimary),
              ],
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(),
                ),
              );
            },
            tooltip: 'Избранное',
          ),

        ],
      ),
      drawer: AppDrawer(userRole: widget.userRole),
      body: _selectedIndex == 0 ? _buildHomeContent() : _buildChatContent(),
      

       // ✅ Добавляем 3D FAB справа снизу
    floatingActionButton: FloatingActionButton(
     onPressed: () => showCreateMenu(context, widget.userRole),
      backgroundColor: _getFabColor(widget.userRole),
      shape: const CircleBorder(), // ✅ всегда круглая
      child: const Icon(Icons.add, size: 28, color: Colors.white),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.iconSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Чаты'),
        ],
      ),
    );
  }
    Color _getFabColor(UserRole role) {
    switch (role) {
      case UserRole.foreman:
        return Colors.orange;
      case UserRole.supplier:
        return Colors.blue;
      case UserRole.courier:
        return Colors.green;
      default:
        return AppColors.primary; // например, для unauthorized
    }
  }


  Widget _buildHomeContent() {
    if (widget.userRole == UserRole.foreman ||
        widget.userRole == UserRole.courier ||
        widget.userRole == UserRole.supplier) {
      return PerformersRequestsView(
        isLoading: _isLoading,
        requests: _getFilteredRequests(),
        userRole: widget.userRole,
        onRefresh: _loadForemanRequests,
        onDetails: _showRequestDetails,
        onRespond: _respondToRequest,
      );
    } else if (widget.userRole == UserRole.customer) {
      return CustomerServicesView(
        selectedFilter: _selectedFilter,
        buildServiceFilterChip: _buildServiceFilterChip,
        servicesList: _buildServicesList(),
        isDark: Theme.of(context).brightness == Brightness.dark,
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [..._buildContentBasedOnRole()],
      ),
    );
  }

  Widget _buildChatContent() {
    return MessagesScreenWithBloc();
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onPressed,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Row(
            children: [
              Icon(icon, size: 30, color: AppColors.iconPrimary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: AppColors.iconPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsBottomSheet(BuildContext context) async {
    final currentUserId = _serviceManager.auth.currentUser?['id'];
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Уведомления',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(child: NotificationsList(userId: currentUserId, db: _serviceManager.db)),

          ],
        ),
      ),
    );
    setState(() {});
  }


  Widget _buildServiceFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            switch (label) {
              case 'Все':
                _selectedFilter = 'all';
                break;
              case 'Материалы':
                _selectedFilter = 'material';
                break;
              case 'Услуги':
                _selectedFilter = 'foreman';
                break;
              case 'Доставка':
                _selectedFilter = 'courier';
                break;
            }
          });
        }
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : null,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
        onOpenChat: (request) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Открытие чата (в разработке)'),
              backgroundColor: Colors.blue,
            ),
          );
        },
        onRespond: _respondToRequest,
      ),
    );
  }

  Future<void> _respondToRequest(Map<String, dynamic> request) async {
    // ✅ Проверяем, если пользователь не авторизован
    if (widget.userRole == UserRole.unauthorized) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AccountPage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Для отклика на заявку необходимо войти в аккаунт.'),
          backgroundColor: Colors.orange,
        ),
      );
      return; // ⚠️ Выходим из функции, чтобы не выполнять остальной код
    }

    print('🔔 Попытка отклика на заявку: ${request['id']}, тип: ${request['type']}, роль: ${widget.userRole}');
    try {
      await _serviceManager.initialize();
      final currentUser = _serviceManager.auth.currentUser;
      if (currentUser == null) {
        print('❌ Пользователь не авторизован');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка: необходимо авторизоваться'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      print('👤 Текущий пользователь: ${currentUser['id']} (${currentUser['name']})');
      final hasResponded = _serviceManager.db.hasUserRespondedToRequest(
        request['id'],
        currentUser['id'],
      );
      if (hasResponded) {
        print('⚠️ Пользователь уже откликнулся на эту заявку');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Вы уже откликнулись на эту заявку'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      String requestType;
      switch (widget.userRole) {
        case UserRole.foreman:
          requestType = 'foreman';
          break;
        case UserRole.courier:
          requestType = 'courier';
          break;
        case UserRole.supplier:
          requestType = 'material';
          break;
        case UserRole.unauthorized:
          requestType = request['type'] ?? 'foreman';
          break;
        case UserRole.customer:
          requestType = '';
          break;
      }
      print('📝 Отправляем отклик с типом: $requestType для роли: ${widget.userRole}');
      final response = await _serviceManager.requests.respondToRequest(
        requestId: request['id'],
        requestType: requestType,
        responderId: currentUser['id'],
        message: 'Готов выполнить вашу заявку',
        responderRole: requestType
      );
      print('📨 Ответ сервера: $response');
      if (mounted) {
        if (response['success'] == true) {
          final customerId = request['customerId'];
          final providerName = currentUser['name'];
          final notif = {
            'id': 'notif_${DateTime.now().millisecondsSinceEpoch}',
            'userId': customerId,
            'title': 'Новый отклик на заявку',
            'body': 'Пользователь $providerName откликнулся на вашу заявку "${request['title']}"',
            'type': 'response',
            'createdAt': DateTime.now().toIso8601String(),
            'isRead': false,
          };
          _serviceManager.db.addNotification(notif);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Отклик на заявку "${request['title']}" отправлен!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadForemanRequests();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Ошибка при отправке отклика'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Ошибка при отклике: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при отправке отклика: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Widget _buildServicesList() {
    if (_isLoading) return const LoadingServicesView();
    if (_errorMessage != null) {
      return ErrorServicesView(
        errorMessage: _errorMessage!,
        onRetry: _loadServices,
      );
    }
    final filteredServices = _getFilteredServices();
    if (filteredServices.isEmpty) {
      return EmptyServicesView(
        isAll: _selectedFilter == 'all',
        onRetry: _loadServices,
      );
    }
    return RefreshIndicator(
      onRefresh: _loadServices,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredServices.length,
        itemBuilder: (context, index) {
          final service = filteredServices[index];
          final currentUserId = _serviceManager.auth.currentUser?['id'];
          return BlocBuilder<FavoriteBloc, FavoriteState>(
            builder: (context, state) {
              final userFavorites =
                  state.favoriteItemsByUser[currentUserId] ?? {};
              final isFavorite = userFavorites.any(
                (item) => item['id'] == service['id'],
              );
              return ServiceCard(
                service: service,
                onTap: () => _onServiceTap(service),
                onContact: () => ContactHelper.openChat(context, service),
                isFavorite: isFavorite,
                onFavoriteToggle: () {
                  context.read<FavoriteBloc>().add(
                    ToggleFavorite(service: service, userId: currentUserId),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredServices() {
    if (_selectedFilter == 'all') {
      return _services;
    }
    return _services.where((service) {
      if (_selectedFilter == 'material') {

        return service['userRole'] == 'material' || service['userRole'] == 'supplier';

      }
      return service['userRole'] == _selectedFilter;
    }).toList();
  }


  void _onServiceTap(Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceDetailsSheet(
        service: service,
        onContact: () => _contactProvider(service),
      ),
    );
  }

  void _contactProvider(Map<String, dynamic> service) async {
    try {
      final authService = MockAuthService();
      final db = MockDatabase();
      final currentUser = authService.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка: пользователь не авторизован'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final providerId = service['providerId'] ?? service['id'] ?? service['userId'];
      final contactName = service['providerName'] ?? service['name'] ?? 'Исполнитель';

      final contactPhoto = service['providerPhoto'];
      if (providerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка: не найден ID исполнителя'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      String? chatId;
      final userChats = db.getChatsByUserId(currentUser['id']);
      for (final chat in userChats) {
        final participants = List<String>.from(chat['participants'] ?? []);
        if (participants.contains(providerId) &&
            participants.contains(currentUser['id'])) {
          chatId = chat['id'];
          break;
        }
      }
      chatId ??= db.createChat([currentUser['id'], providerId]);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ChatBloc(fileRepository: FileRepository()),
            child: ChatPage(
              contactName: contactName,
              contactPhoto: contactPhoto,
              chatId: chatId,
              request: service,
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  bool _hasUnreadNotifications() {
    final currentUserId = _serviceManager.auth.currentUser?['id'];
    if (currentUserId == null) return false;
    final notifications = _serviceManager.db.getNotificationsForUser(
      currentUserId,
    );
    return notifications.any((n) => n['isRead'] == false);
  }
}