import 'package:flutter/material.dart';
import 'package:flutter_valhalla/app.dart';
import 'package:flutter_valhalla/core/mock/mock_services.dart';
import 'package:flutter_valhalla/core/utils/registration_role_extension.dart';
import 'package:flutter_valhalla/features/routing/presentation/widgets/service_details_sheet.dart';
import 'package:flutter_valhalla/features/routing/presentation/widgets/request_card.dart';
import 'edit_service_page.dart';

class MyServicesPage extends StatefulWidget {
  final bool showAppBar;
  final bool showRefreshAction;
  final UserRole userRole;

  const MyServicesPage({
    super.key,
    this.showAppBar = true,
    this.showRefreshAction = true,
    required this.userRole,
  });

  @override
  State<MyServicesPage> createState() => _MyServicesPageState();
}

class _MyServicesPageState extends State<MyServicesPage> {
  final MockServiceManager _serviceManager = MockServiceManager();
  List<Map<String, dynamic>> _myServices = [];
  bool _isLoading = true;
  String? _errorMessage;
  late UserRole activeRole;

  @override
  void initState() {
    super.initState();
    final authService = MockAuthService();
    activeRole = widget.userRole != UserRole.unauthorized
        ? widget.userRole
        : authService.getActiveRole()?.toUserRole() ?? UserRole.unauthorized;
    _loadMyServices();
  }

  Future<void> _loadMyServices() async {
  try {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _serviceManager.initialize();
    final currentUser = _serviceManager.authService.currentUser;
    if (currentUser == null) {
      setState(() {
        _errorMessage = 'Пользователь не авторизован';
        _isLoading = false;
      });
      return;
    }

    final userId = currentUser['id'];
    final myServices = MockDatabase().getServicesByUser(userId, activeRole.name);

    final enriched = myServices.map((s) {
      return {
        ...s,
        'customerName': s['providerName'] ?? currentUser['name'] ?? 'Вы',
        'city': s['city'] ?? 'Алматы',
      };
    }).toList();

    setState(() {
      _myServices = enriched;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _errorMessage = 'Ошибка загрузки услуг: $e';
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text('Мои услуги (${activeRole.name})'),
              actions: [
                if (widget.showRefreshAction)
                  IconButton(
                    onPressed: _loadMyServices,
                    icon: const Icon(Icons.refresh),
                  ),
              ],
            )
          : null,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    if (_myServices.isEmpty) {
      return const Center(child: Text('У вас пока нет опубликованных услуг'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myServices.length,
      itemBuilder: (context, index) {
        final service = _myServices[index];
        return RequestCard(
          request: service,
          userRole: activeRole,
          onDetails: _onServiceTap,
          showRespondButton: false,
          showStatus: false,       
          showBudgetAlways: true,  
        );
      },
    );
  }

  void _onServiceTap(Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceDetailsSheet(
        service: service,
        showContactButton: false,
        showEditButton: true,
        onEdit: () => _editService(service),
        onDelete: () async {
          await _loadMyServices();
          setState(() {});
        },
      ),
    );
  }

  void _editService(Map<String, dynamic> service) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditServicePage(
          service: service,
          onSave: (updatedService) {
            setState(() {
              final idx = _myServices.indexWhere((s) => s['id'] == updatedService['id']);
              if (idx != -1) _myServices[idx] = updatedService;

              final all = _serviceManager.database.getServices();
              final dbIdx = all.indexWhere((s) => s['id'] == updatedService['id']);
              if (dbIdx != -1) all[dbIdx] = updatedService;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Услуга обновлена')),
            );
          },
        ),
      ),
    );
  }
}
