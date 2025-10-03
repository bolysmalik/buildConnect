// requests_repository.dart
import 'package:flutter_valhalla/app.dart';
import 'package:flutter_valhalla/core/mock/mock_service_manager.dart';
import 'package:flutter_valhalla/features/routing/presentation/utils/performer_utils.dart';

class RequestsRepository {
  final MockServiceManager _manager = MockServiceManager();

  Future<List<Map<String, dynamic>>> loadResponsesForUser(UserRole role) async {
    await _manager.initialize();
    final user = _manager.auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');

    final responses = _manager.db.getResponsesByResponder(user['id']);
    final type = getRequestTypeForRole(role);

    final filtered = responses.where((r) => r['requestType'] == type);
    final List<Map<String, dynamic>> requests = [];

    for (final r in filtered) {
      final req = _manager.db.getRequestByTypeAndId(r['requestType'], r['requestId']);
      if (req != null) {
        final customer = _manager.db.getUserById(req['customerId']);
        requests.add({
          ...req,
          'customerName': customer?['name'] ?? 'Неизвестный заказчик',
          'customerPhone': customer?['phone'] ?? '',
          'myResponseStatus': r['status'],
          'type': r['requestType'],
        });
      }
    }

    requests.sort((a, b) {
      final da = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(2024);
      final db = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(2024);
      return db.compareTo(da);
    });

    return requests;
  }
}
