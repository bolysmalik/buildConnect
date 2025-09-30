import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_valhalla/core/mock/mock_services.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/my%20request/view/edit_request_page.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/my%20request/widgets/show_request_details.dart';
import 'package:flutter_valhalla/features/routing/presentation/utils/date_formatter.dart';
import 'package:flutter_valhalla/features/routing/presentation/utils/performer_utils.dart';
import '../../../../../../core/theme/app_colors.dart';
import 'responses_list_page.dart';

class MyRequestPage extends StatefulWidget {
  const MyRequestPage({super.key});

  @override
  State<MyRequestPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyRequestPage> {
  final MockServiceManager _serviceManager = MockServiceManager();
  List<Map<String, dynamic>> _customerRequests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCustomerRequests();
  }

  Future<void> _loadCustomerRequests() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _serviceManager.initialize();

     final currentUser = _serviceManager.authService.getUserByActiveRole();
      if (currentUser == null) {
        setState(() {
          _errorMessage = 'Пользователь не авторизован';
          _isLoading = false;
        });
        return;
      }

      if (currentUser['role'] != 'customer') {
        setState(() {
          _errorMessage = 'Эта страница доступна только для заказчиков';
          _isLoading = false;
        });
        return;
      }

      final allUserRequests = await _serviceManager.requestsService
          .getAllUserRequests(currentUser['id']);

      final responses = await _serviceManager.requestsService
          .getResponsesForCustomer(currentUser['id']);

      List<Map<String, dynamic>> allRequests = [];

      allUserRequests['materials']?.forEach((request) {
        request['type'] = 'material';
        allRequests.add(request);
      });

      allUserRequests['foremen']?.forEach((request) {
        request['type'] = 'foreman';
        allRequests.add(request);
      });

      allUserRequests['couriers']?.forEach((request) {
        request['type'] = 'courier';
        allRequests.add(request);
      });

      Map<String, List<Map<String, dynamic>>> responsesByRequest = {};
      for (final response in responses) {
        final requestId = response['requestId'];
        if (!responsesByRequest.containsKey(requestId)) {
          responsesByRequest[requestId] = [];
        }
        responsesByRequest[requestId]!.add(response);
      }

      for (final request in allRequests) {
        final requestId = request['id'];
        final requestResponses = responsesByRequest[requestId] ?? [];
        request['hasResponses'] = requestResponses.isNotEmpty;
        request['responsesCount'] = requestResponses.length;
        request['responses'] = requestResponses;
        
      }

      allRequests.sort((a, b) {
        final dateA = DateTime.parse(a['createdAt'] ?? '2024-01-01T00:00:00Z');
        final dateB = DateTime.parse(b['createdAt'] ?? '2024-01-01T00:00:00Z');
        return dateB.compareTo(dateA);
      });

      if (mounted) {
        setState(() {
          _customerRequests = allRequests;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои заявки'),
        actions: [
          IconButton(
            onPressed: _loadCustomerRequests,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCustomerRequests,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (_customerRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'У вас пока нет заявок',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Создайте первую заявку, чтобы найти исполнителей',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCustomerRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _customerRequests.length,
        itemBuilder: (context, index) {
          final request = _customerRequests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final type = request['type'] ?? 'unknown';
    final hasResponses = request['hasResponses'] ?? false;
    final responsesCount = request['responsesCount'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleRequestTap(request),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: getPerformerColor(type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      getPerformerIcon(type),
                      color: getPerformerColor(type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request['title'] ?? 'Заявка без названия',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          getPerformerTypeName(type),
                          style: TextStyle(
                            fontSize: 12,
                            color: getPerformerColor(type),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: hasResponses
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hasResponses ? 'АКТИВНАЯ' : 'НОВАЯ',
                      style: TextStyle(
                        fontSize: 10,
                        color: hasResponses
                            ? Colors.green.shade700
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (request['description'] != null)
                Text(
                  request['description'],
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              else if (request['material_list'] != null &&
                  request['material_list'].toString().isNotEmpty)
                Text(
                  request['material_list'].toString(),
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      Icons.location_on,
                      request['city'] ?? 'Не указан',
                    ),
                  ),
                  if (request['budget'] != null)
                    Text(
                      '${request['budget']} ₸',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.success,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      Icons.access_time,
                      formatDate(request['createdAt'] ?? ''),
                    ),
                  ),
                  if (hasResponses)
                    Expanded(
                      child: _buildDetailItem(
                        Icons.people,
                        '$responsesCount ${_getResponsesText(responsesCount)}',
                      ),
                    ),
                ],
              ),
              if (hasResponses) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: 16,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'На вашу заявку есть отклики! Нажмите, чтобы открыть',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: (request['responses'] as List<Map<String, dynamic>>).take(3).map((response) {
                    return _buildPerformerAvatar(response);
                  }).toList(),
                ),
                if (responsesCount > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'и еще ${responsesCount - 3}...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformerAvatar(Map<String, dynamic> response) {
    final performerName = response['performerName'] ?? 'Исполнитель';
    final performerType = response['performerType'] ?? 'unknown';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getPerformerColor(performerType).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getPerformerIcon(performerType),
            size: 12,
            color: getPerformerColor(performerType),
          ),
          const SizedBox(width: 4),
          Text(
            performerName,
            style: TextStyle(
              fontSize: 10,
              color: getPerformerColor(performerType),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }



  String _getResponsesText(int count) {
    if (count == 1) return 'отклик';
    if (count >= 2 && count <= 4) return 'отклика';
    return 'откликов';
  }

  Future<void> _handleRequestTap(Map<String, dynamic> request) async {
  final hasResponses = request['hasResponses'] ?? false;

  final currentUser = _serviceManager.authService.getUserByActiveRole();
  if (currentUser != null && !request.containsKey('customerName')) {
    request['customerName'] = currentUser['name'] ?? 'Вы';
  }

  if (!hasResponses || (request['responses'] as List<dynamic>).isEmpty) {
    await showRequestDetails(
      context: context,
      request: request,
      onDelete: _deleteRequest,
      onEdit: _editRequest,
    );
    return;
  }

  Navigator.of(context)
      .push(
        MaterialPageRoute(
          builder: (context) => ResponsesListPage(
            request: request,
            serviceManager: _serviceManager,
          ),
        ),
      )
      .then((_) => _loadCustomerRequests());
}


  Future<void> _editRequest(Map<String, dynamic> request) async {
    final updatedRequest = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditRequestPage(request: request),
      ),
    );
    if (updatedRequest != null) {
      final result = await _serviceManager.requestsService.updateRequest(
        requestId: updatedRequest['id'],
        requestType: updatedRequest['type'],
        updatedData: updatedRequest,
      );
      if (result['success'] == true) {
        setState(() {
          final idx = _customerRequests.indexWhere(
            (r) => r['id'] == updatedRequest['id'],
          );
          if (idx != -1) _customerRequests[idx] = updatedRequest;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Заявка обновлена')));
        _loadCustomerRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Ошибка при обновлении заявки'),
          ),
        );
      }
    }
  }

  Future<void> _deleteRequest(Map<String, dynamic> request) async {
    try {
      final result = await _serviceManager.requestsService.deleteRequest(
        request['id'],
      );
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Заявка удалена'),
            backgroundColor: Colors.red,
          ),
        );
        _loadCustomerRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Ошибка при удалении заявки'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
  }
}