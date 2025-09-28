// mock_requests_service.dart
// Сервис для работы с заявками (материалы, бригадиры, курьеры)

import 'dart:async';
import 'mock_database.dart';

class MockRequestsService {
  late final MockDatabase _db;

  // === конструктор через который мы теперь передаем общую базу ===
  MockRequestsService([MockDatabase? sharedDb]) {
    _db = sharedDb ?? MockDatabase();
  }

  // Callback для уведомлений о новых заявках
  Function(String)? _onNewRequestCallback;

  // Установить callback для уведомлений
  void setNewRequestCallback(Function(String) callback) {
    _onNewRequestCallback = callback;
  }

  // ================== ЗАЯВКИ НА МАТЕРИАЛЫ ==================
  Future<List<Map<String, dynamic>>> getMaterialRequests({
    String? customerId,
    String? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _db.getMaterialRequests(customerId: customerId, status: status);
  }

  Future<Map<String, dynamic>> createMaterialRequest({
    required String customerId,
    required Map<String, dynamic> requestData,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final enrichedData = {
      ...requestData,
      'customerId': customerId,
      'type': 'material',
    };

    final requestId = _db.addMaterialRequest(enrichedData);
    _onNewRequestCallback?.call('material');

    return {
      'success': true,
      'requestId': requestId,
      'message': 'Заявка на материалы создана успешно',
    };
  }

  Future<Map<String, dynamic>?> getMaterialRequestById(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final requests = _db.getMaterialRequests();
    try {
      return requests.firstWhere((req) => req['id'] == requestId);
    } catch (e) {
      return null;
    }
  }

  // ================== ЗАЯВКИ НА БРИГАДИРОВ ==================
  Future<List<Map<String, dynamic>>> getForemanRequests({
    String? customerId,
    String? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _db.getForemanRequests(customerId: customerId, status: status);
  }

  Future<Map<String, dynamic>> createForemanRequest({
    required String customerId,
    required Map<String, dynamic> requestData,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final enrichedData = {
      ...requestData,
      'customerId': customerId,
      'type': 'foreman',
    };

    final requestId = _db.addForemanRequest(enrichedData);
    _onNewRequestCallback?.call('foreman');

    return {
      'success': true,
      'requestId': requestId,
      'message': 'Заявка на бригадира создана успешно',
    };
  }

  Future<Map<String, dynamic>?> getForemanRequestById(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final requests = _db.getForemanRequests();
    try {
      return requests.firstWhere((req) => req['id'] == requestId);
    } catch (e) {
      return null;
    }
  }

  // ================== ЗАЯВКИ НА КУРЬЕРОВ ==================
  Future<List<Map<String, dynamic>>> getCourierRequests({
    String? customerId,
    String? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _db.getCourierRequests(customerId: customerId, status: status);
  }

  Future<Map<String, dynamic>> createCourierRequest({
    required String customerId,
    required Map<String, dynamic> requestData,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final enrichedData = {
      ...requestData,
      'customerId': customerId,
      'type': 'courier',
    };

    final requestId = _db.addCourierRequest(enrichedData);
    _onNewRequestCallback?.call('courier');

    return {
      'success': true,
      'requestId': requestId,
      'message': 'Заявка на курьера создана успешно',
    };
  }

  Future<Map<String, dynamic>?> getCourierRequestById(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final requests = _db.getCourierRequests();
    try {
      return requests.firstWhere((req) => req['id'] == requestId);
    } catch (e) {
      return null;
    }
  }

      // ============= ОБЩИЕ МЕТОДЫ =============

      // Получить все заявки пользователя (любого типа)
      Future<Map<String, List<Map<String, dynamic>>>> getAllUserRequests(String customerId) async {
        await Future.delayed(const Duration(milliseconds: 100));

        final materialRequests = await getMaterialRequests(customerId: customerId);
        final foremanRequests = await getForemanRequests(customerId: customerId);
        final courierRequests = await getCourierRequests(customerId: customerId);

        return {
          'materials': materialRequests,
          'foremen': foremanRequests,
          'couriers': courierRequests,
        };
      }
      

      // Получить активные заявки для исполнителей (бригадиры, поставщики, курьеры)
      Future<List<Map<String, dynamic>>> getActiveRequestsForPerformers(String performerRole) async {
        await Future.delayed(const Duration(milliseconds: 600));

        List<Map<String, dynamic>> requests = [];

        switch (performerRole) {
          case 'supplier':
            requests = _db.getMaterialRequests(status: 'active');
            break;
          case 'foreman':
            requests = _db.getForemanRequests(status: 'active');
            break;
          case 'courier':
            requests = _db.getCourierRequests(status: 'active');
            break;
        }

        return requests;
      }

      // Обновить статус заявки
      Future<Map<String, dynamic>> updateRequestStatus({
        required String requestId,
        required String requestType, // 'material', 'foreman', 'courier'
        required String newStatus,
      }) async {
        await Future.delayed(const Duration(milliseconds: 500));

        List<Map<String, dynamic>> requests;

        switch (requestType) {
          case 'material':
            requests = _db.getMaterialRequests();
            break;
          case 'foreman':
            requests = _db.getForemanRequests();
            break;
          case 'courier':
            requests = _db.getCourierRequests();
            break;
          default:
            throw Exception('Неизвестный тип заявки: $requestType');
        }

        final requestIndex = requests.indexWhere((req) => req['id'] == requestId);
        if (requestIndex != -1) {
          requests[requestIndex]['status'] = newStatus;
          requests[requestIndex]['updatedAt'] = DateTime.now().toIso8601String();

          return {
            'success': true,
            'message': 'Статус заявки обновлен',
          };
        } else {
          return {
            'success': false,
            'message': 'Заявка не найдена',
          };
        }
      }

      // Обновить заявку по id и типу
      Future<Map<String, dynamic>> updateRequest({
        required String requestId,
        required String requestType, // 'material', 'foreman', 'courier'
        required Map<String, dynamic> updatedData,
      }) async {
        await Future.delayed(const Duration(milliseconds: 500));
        List<Map<String, dynamic>> requests;
        switch (requestType) {
          case 'material':
            requests = _db.getMaterialRequests();
            break;
          case 'foreman':
            requests = _db.getForemanRequests();
            break;
          case 'courier':
            requests = _db.getCourierRequests();
            break;
          default:
            throw Exception('Неизвестный тип заявки: $requestType');
        }
        final requestIndex = requests.indexWhere((req) => req['id'] == requestId);
        if (requestIndex != -1) {
          requests[requestIndex].addAll(updatedData);
          requests[requestIndex]['updatedAt'] = DateTime.now().toIso8601String();
          return {'success': true, 'message': 'Заявка обновлена'};
        } else {
          return {'success': false, 'message': 'Заявка не найдена'};
        }
      }

      // Добавить отклик на заявку (для исполнителей)
      Future<Map<String, dynamic>> addResponseToRequest({
        required String requestId,
        required String requestType,
        required String performerId,
        required Map<String, dynamic> responseData,
      }) async {
        await Future.delayed(const Duration(milliseconds: 700));

        List<Map<String, dynamic>> requests;

        switch (requestType) {
          case 'material':
            requests = _db.getMaterialRequests();
            break;
          case 'foreman':
            requests = _db.getForemanRequests();
            break;
          case 'courier':
            requests = _db.getCourierRequests();
            break;
          default:
            throw Exception('Неизвестный тип заявки: $requestType');
        }

        final requestIndex = requests.indexWhere((req) => req['id'] == requestId);
        if (requestIndex != -1) {
          final response = {
            'id': 'resp_${DateTime.now().millisecondsSinceEpoch}',
            'performerId': performerId,
            'createdAt': DateTime.now().toIso8601String(),
            ...responseData,
          };

          (requests[requestIndex]['responses'] as List).add(response);

          return {
            'success': true,
            'responseId': response['id'],
            'message': 'Отклик добавлен успешно',
          };
        } else {
          return {
            'success': false,
            'message': 'Заявка не найдена',
          };
        }
      }

      // Получить статистику заявок
      Future<Map<String, int>> getRequestsStatistics({String? userId}) async {
        await Future.delayed(const Duration(milliseconds: 400));

        if (userId != null) {
          // Статистика для конкретного пользователя
          final userRequests = await getAllUserRequests(userId);

          return {
            'totalRequests': userRequests['materials']!.length +
                userRequests['foremen']!.length +
                userRequests['couriers']!.length,
            'materialRequests': userRequests['materials']!.length,
            'foremanRequests': userRequests['foremen']!.length,
            'courierRequests': userRequests['couriers']!.length,
            'activeRequests': userRequests['materials']!.where((r) => r['status'] == 'active').length +
                userRequests['foremen']!.where((r) => r['status'] == 'active').length +
                userRequests['couriers']!.where((r) => r['status'] == 'active').length,
          };
        } else {
          // Общая статистика
          return {
            'totalMaterialRequests': _db.getMaterialRequests().length,
            'totalForemanRequests': _db.getForemanRequests().length,
            'totalCourierRequests': _db.getCourierRequests().length,
            'activeMaterialRequests': _db.getMaterialRequests(status: 'active').length,
            'activeForemanRequests': _db.getForemanRequests(status: 'active').length,
            'activeCourierRequests': _db.getCourierRequests(status: 'active').length,
          };
        }
      }

      // ============= ОТКЛИКИ =============

      // Откликнуться на заявку
      Future<Map<String, dynamic>> respondToRequest({
        required String requestId,
        required String requestType,
        required String responderId,
        required String responderRole,
        String? message,
      }) async {
        await Future.delayed(const Duration(milliseconds: 300));
        print('=== RESPOND TO REQUEST DEBUG ===');
        print('responderId: $responderId');
        print('responderRole: $responderRole');
        print('requestId: $requestId');
        print('requestType: $requestType');

        try {
          // Проверяем есть ли уже отклик от этого пользователя
          if (_db.hasUserRespondedToRequest(requestId, responderId)) {
            return {
              'success': false,
              'message': 'Вы уже откликнулись на эту заявку',
            };
          }
          

          // Получаем заявку чтобы найти ID заказчика
          Map<String, dynamic>? request;
          String customerId;

          switch (requestType) {
            case 'material':
              request = _db.getMaterialRequests().firstWhere((r) => r['id'] == requestId);
              break;
            case 'foreman':
              request = _db.getForemanRequests().firstWhere((r) => r['id'] == requestId);
              break;
            case 'courier':
              request = _db.getCourierRequests().firstWhere((r) => r['id'] == requestId);
              break;
            default:
              return {
                'success': false,
                'message': 'Неизвестный тип заявки',
              };
          }

          customerId = request['customerId'];
          // 🔧 фикс: если по ошибке в customerId лежит 'foreman' или null — берем правильный id
          if (customerId == null || customerId == 'foreman' || !customerId.toString().startsWith('user_')) {
            customerId = request['customer']?['id'] ?? request['createdBy'] ?? '';
            print('⚠️ customerId был некорректным, заменили на: $customerId');
          }

          // Создаем отклик
          final responseId = _db.createResponse(
            requestId,
            requestType,
            responderId,
            customerId,
            responderRole,
            message: message,
          );
          print('response created: $responseId for customerId=$customerId');

          return {
            'success': true,
            'responseId': responseId,
            'message': 'Отклик успешно отправлен',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Ошибка при отправке отклика: $e',
          };
        }
      }


      // Получить отклики конкретного исполнителя
      Future<List<Map<String, dynamic>>> getResponsesByResponder(
        String responderId, {
        String? role,
      }) async {
        await Future.delayed(const Duration(milliseconds: 400));
        return _db.getResponsesByResponder(responderId, role: role);
      }

      // Получить отклики на заявки заказчика
      Future<List<Map<String, dynamic>>> getResponsesForCustomer(String customerId) async {
        await Future.delayed(const Duration(milliseconds: 400));
        return _db.getResponsesForCustomer(customerId);
      }

      // Получить заявки с откликами для заказчика (обогащенные данными)
      Future<List<Map<String, dynamic>>> getRequestsWithResponses(String customerId) async {
        await Future.delayed(const Duration(milliseconds: 600));
        print('=== GET REQUESTS WITH RESPONSES DEBUG ===');
        print('customerId: $customerId');   

        final allRequests = <Map<String, dynamic>>[];

        // Получаем все заявки заказчика
        final materialRequests = _db.getMaterialRequests(customerId: customerId);
        final foremanRequests = _db.getForemanRequests(customerId: customerId);
        final courierRequests = _db.getCourierRequests(customerId: customerId);
        print('materialRequests count: ${materialRequests.length}');
        print('foremanRequests count: ${foremanRequests.length}');
        print('courierRequests count: ${courierRequests.length}');

        // Обогащаем каждую заявку информацией об откликах
        for (final request in materialRequests) {
          final responses = _db.getResponsesForRequest(request['id']);
          allRequests.add({
            ...request,
            'type': 'material',
            'responses': responses,
            'hasResponses': responses.isNotEmpty,
          });
        }

        for (final request in foremanRequests) {
          final responses = _db.getResponsesForRequest(request['id']);
          allRequests.add({
            ...request,
            'type': 'foreman',
            'responses': responses,
            'hasResponses': responses.isNotEmpty,
          });
        }

        for (final request in courierRequests) {
          final responses = _db.getResponsesForRequest(request['id']);
          allRequests.add({
            ...request,
            'type': 'courier',
            'responses': responses,
            'hasResponses': responses.isNotEmpty,
          });
        }

        // Сортируем по дате создания (новые сначала)
        allRequests.sort((a, b) {
          final dateA = DateTime.parse(a['createdAt']);
          final dateB = DateTime.parse(b['createdAt']);
          return dateB.compareTo(dateA);
        });

        return allRequests;
      }

      /// Принять отклик от исполнителя.
      /// Обновляет статус соответствующей заявки и отклоняет остальные отклики.
      Future<Map<String, dynamic>> acceptResponse(String responseId) async {
        await Future.delayed(const Duration(seconds: 1));
        try {
          final response = _db.getResponseById(responseId);
          if (response == null) {
            return {
              'success': false,
              'message': 'Отклик не найден',
            };
          }

          final requestId = response['requestId'];
          final requestType = response['requestType'];

          // Обновляем статус заявки на 'accepted'
          await updateRequestStatus(
            requestId: requestId,
            requestType: requestType,
            newStatus: 'accepted',
          );

          // Обновляем статус самого отклика на 'accepted'
          _db.updateResponseStatus(responseId, 'accepted');

          // Отклоняем все остальные отклики для этой же заявки
          _db.rejectOtherResponses(requestId, responseId);

          return {
            'success': true,
            'message': 'Отклик успешно принят. Заявка закрыта.',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Ошибка при принятии отклика: $e',
          };
        }
      }

      // Удалить заявку по id и типу
      Future<Map<String, dynamic>> deleteRequest(String requestId) async {
        await Future.delayed(const Duration(milliseconds: 500));
        print('[MockRequestsService] Попытка удалить заявку с id: $requestId');
        print('Материалы:');
        for (var r in _db.getMaterialRequests()) {
          print('  ${r['id']}');
        }
        print('Бригадиры:');
        for (var r in _db.getForemanRequests()) {
          print('  ${r['id']}');
        }
        print('Курьеры:');
        for (var r in _db.getCourierRequests()) {
          print('  ${r['id']}');
        }
        int removed = 0;
        removed += _db.removeMaterialRequest(requestId);
        removed += _db.removeForemanRequest(requestId);
        removed += _db.removeCourierRequest(requestId);
        if (removed > 0) {
          print('[MockRequestsService] Заявка $requestId успешно удалена');
          return {'success': true, 'message': 'Заявка удалена'};
        } else {
          print('[MockRequestsService] Заявка $requestId не найдена ни в одном списке');
          return {'success': false, 'message': 'Заявка не найдена'};
        }
      }
    }
