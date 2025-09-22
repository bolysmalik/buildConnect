  // mock_database.dart
  // Имитация базы данных с помощью статических списков

  import 'dart:math';

  class MockDatabase {
    static final MockDatabase _instance = MockDatabase._internal();
    factory MockDatabase() => _instance;
    MockDatabase._internal();

    // Генератор ID
    String _generateId() => 'id_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';

    // ============= ПОЛЬЗОВАТЕЛИ =============
    final List<Map<String, dynamic>> _users = [
      {
        'id': 'user_001',
        'phone': '+77771234567',
        'roles': ['customer'],
        'name': 'Асылбек Нуржанов',
        'email': 'asylbek@email.com',
        'city': 'Алматы',
        'password': 'test123', // новый пароль
        'isVerified': true,
        'createdAt': '2024-01-15T10:00:00Z',
      },
      {
        'id': 'user_002',
        'phone': '+77779876543',
        'roles': ['foreman'],
        'name': 'Ерлан Казиев',
        'email': 'erlan@email.com',
        'city': 'Алматы',
        'specialization': 'Бетонные работы',
        'experience': '5 лет',
        'password': 'test123',
        'isVerified': true,
        'createdAt': '2024-01-10T09:00:00Z',
      },
      {
        'id': 'user_003',
        'phone': '+77775555555',
        'roles': ['supplier'],
        'name': 'ТОО "СтройМат"',
        'email': 'info@stroymat.kz',
        'city': 'Алматы',
        'password': 'test123',
        'companyName': 'СтройМат',
        'address': 'ул. Розыбакиева 247',
        'isVerified': true,
        'createdAt': '2024-01-05T08:00:00Z',
      },
      {
        'id': 'user_004',
        'phone': '+77778888888',
        'roles': ['courier'],
        'name': 'Данияр Жумабеков',
        'email': 'daniiar@email.com',
        'city': 'Алматы',
        'password': 'test123',
        'vehicleType': 'Легковой автомобиль',
        'isVerified': true,
        'createdAt': '2024-01-08T07:00:00Z',
      }
    ];

    // ============= ЗАЯВКИ НА МАТЕРИАЛЫ =============
    final List<Map<String, dynamic>> _materialRequests = [
      {
        'id': 'req_001',
        'customerId': 'user_001',
        'title': 'Цемент М400',
        'description': 'Нужен цемент для фундамента частного дома',
        'quantity': '20 мешков',
        'budget': '50000',
        'city': 'Алматы',
        'material_list': 'Цемент М500',
        'address': 'мкр. Самал-2, дом 58',
        'status': 'active', // active, in_progress, completed, cancelled
        'createdAt': '2024-12-10T14:30:00Z',
        'attachments': [],
        'responses': [],
        
      },
      {
        'id': 'req_002',
        'customerId': 'user_001',
        'title': 'Кирпич красный',
        'description': 'Для стройки дома, качественный кирпич',
        'quantity': '5000 штук',
        'budget': '200000',
        'city': 'Алматы',
        'material_list': 'Цемент М500',
        'address': 'пр. Достык 120',
        'status': 'completed',
        'createdAt': '2024-12-05T10:00:00Z',
        'attachments': [],
        'responses': [
          {
            'supplierId': 'user_003',
            'price': '180000',
            'comment': 'Качественный кирпич, доставка включена',
            'createdAt': '2024-12-05T11:00:00Z',
          }
        ],
      },
      {

        'id': 'req_003',
        'customerId': 'user_001',
        'title': 'Песок строительный',
        'description': 'Нужен песок для бетонных работ',
        'quantity': '10 кубов',
        'material_list': 'Цемент М500',
        'budget': '80000',
        'city': 'Алматы',
        'address': 'ул. Жандосова 140',
        'status': 'active',
        'createdAt': '2024-12-12T09:00:00Z',
        'attachments': [],
        'responses': [],
      },
      {
        'id': 'req_004',
        'customerId': 'user_001',
        'title': 'Арматура А500С',
        'description': 'Для армирования фундамента, диаметр 12мм',
        'quantity': '2 тонны',
        'budget': '400000',
        'material_list': 'Цемент М500',
        'city': 'Алматы',
        'address': 'пр. Райымбека 350',
        'status': 'active',
        'createdAt': '2024-12-13T15:20:00Z',
        'attachments': [],
        'responses': [],
      }
    ];

    // ============= ЗАЯВКИ НА БРИГАДИРОВ =============
    final List<Map<String, dynamic>> _foremanRequests = [
      {
        'id': 'freq_001',
        'customerId': 'user_001',
        'title': 'Заливка фундамента',
        'description': 'Нужна бригада для заливки ленточного фундамента',
        'workType': 'Бетонные работы',
        'budget': '300000',
        'city': 'Алматы',
        'address': 'ул. Жандосова 140',
        'startDate': '2024-12-20',
        'duration': '3 дня',
        'status': 'active',
        'createdAt': '2024-12-08T16:00:00Z',
        'attachments': [],
        'responses': [],
      },
      {
        'id': 'freq_002',
        'customerId': 'user_001',
        'title': 'Кладка кирпичной стены',
        'description': 'Строительство несущих стен из кирпича',
        'workType': 'Кладочные работы',
        'budget': '500000',
        'city': 'Алматы',
        'address': 'мкр. Самал-2, дом 58',
        'startDate': '2024-12-25',
        'duration': '7 дней',
        'status': 'active',
        'createdAt': '2024-12-11T12:30:00Z',
        'attachments': [],
        'responses': [],
      }
    ];

    // ============= ЗАЯВКИ НА КУРЬЕРОВ =============
    final List<Map<String, dynamic>> _courierRequests = [
      {
        'id': 'creq_001',
        'customerId': 'user_001',
        'title': 'Доставка кирпича',
        'description': 'Доставить кирпич с склада на объект',
        'fromAddress': 'ул. Розыбакиева 247',
        'toAddress': 'пр. Достык 120',
        'cargoType': 'Строительные материалы',
        'goods_list': '2000 кг',
        'budget': '15000',
        'city': 'Алматы',
        'pickupDate': '2024-12-15',
        'status': 'active',
        'createdAt': '2024-12-09T12:00:00Z',
        'attachments': [],
        'responses': [],
      },
      {
        'id': 'creq_002',
        'customerId': 'user_001',
        'title': 'Доставка цемента',
        'description': 'Доставка цемента М400 на стройплощадку',
        'fromAddress': 'Склад СтройМат, ул. Розыбакиева 247',
        'toAddress': 'мкр. Самал-2, дом 58',
        'cargoType': 'Цемент в мешках',
        'goods_list': '1000 кг',
        'budget': '12000',
        'city': 'Алматы',
        'pickupDate': '2024-12-16',
        'status': 'active',
        'createdAt': '2024-12-12T14:30:00Z',
        'attachments': [],
        'responses': [],
      }
    ];

    // ============= ЧАТЫ =============
    final List<Map<String, dynamic>> _chats = [
  ];
  int removeChat(String chatId) {
      final initialLength = _chats.length;
      _chats.removeWhere((chat) => chat['id'] == chatId);
      return initialLength - _chats.length;
    }

    

    // ============= ИЗБРАННОЕ =============
    final List<Map<String, dynamic>> _favorites = [
      {
        'id': 'fav_001',
        'userId': 'user_001',
        'itemType': 'supplier', // supplier, foreman, courier
        'itemId': 'user_003',
        'createdAt': '2024-12-01T10:00:00Z',
      }
    ];

    // ============= ОТКЛИКИ НА ЗАЯВКИ =============
    final List<Map<String, dynamic>> _responses = [
      // Пример: отклик бригадира на заявку customer_001
      // {
      //   'id': 'response_001',
      //   'requestId': 'foreman_req_001',
      //   'requestType': 'foreman', // material, foreman, courier
      //   'responderId': 'user_002', // ID того кто откликнулся (бригадир/курьер/поставщик)
      //   'customerId': 'user_001', // ID заказчика
      //   'status': 'pending', // pending, accepted, rejected
      //   'message': 'Готов выполнить вашу заявку',
      //   'createdAt': '2024-12-15T10:00:00Z',
      // }
    ];

    // ============= МЕТОДЫ ПОЛУЧЕНИЯ ДАННЫХ =============

    // Получить пользователя по ID
    Map<String, dynamic>? getUserById(String id) {
      try {
        return _users.firstWhere((user) => user['id'] == id);
      } catch (e) {
        return null;
      }
    }

    // Получить пользователя по телефону
    Map<String, dynamic>? getUserByPhone(String phone) {
      try {
        return _users.firstWhere((user) => user['phone'] == phone);
      } catch (e) {
        return null;
      }
    }

    // Получить всех пользователей по роли
    List<Map<String, dynamic>> getUsersByRole(String role) {
      return _users.where((user) => user['role'] == role).toList();
    }

    // Добавить нового пользователя
  String addUser(Map<String, dynamic> userData) {
    final newId = 'user_${Random().nextInt(10000)}';  final newUser = {
      ...userData,    'id': newId,
      'createdAt': DateTime.now().toIso8601String(),  };
    _users.add(newUser);  return newId;
  }

    // Обновить пользователя
    bool updateUser(String userId, Map<String, dynamic> updates) {
      final userIndex = _users.indexWhere((user) => user['id'] == userId);
      if (userIndex != -1) {
        _users[userIndex] = {
          ..._users[userIndex],
          ...updates,
          'updatedAt': DateTime.now().toIso8601String(),
        };
        return true;
      }
      return false;
    }

    // ============= ЗАЯВКИ НА МАТЕРИАЛЫ =============

    List<Map<String, dynamic>> getMaterialRequests({String? customerId, String? status}) {
      print('🔍 DEBUG: getMaterialRequests вызван с customerId: $customerId, status: $status');
      print('🔍 DEBUG: Всего заявок в _materialRequests: ${_materialRequests.length}');

      var requests = _materialRequests.toList();

      if (customerId != null) {
        requests = requests.where((req) => req['customerId'] == customerId).toList();
        print('🔍 DEBUG: После фильтрации по customerId: ${requests.length} заявок');
      }

      if (status != null) {
        requests = requests.where((req) => req['status'] == status).toList();
        print('🔍 DEBUG: После фильтрации по status: ${requests.length} заявок');
      }

      print('🔍 DEBUG: Возвращаем ${requests.length} заявок для customerId: $customerId');
      return requests;
    }

    String addMaterialRequest(Map<String, dynamic> requestData) {
      final id = _generateId();
      final request = {
        'id': id,
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'active',
        'responses': [],
        'attachments': [],
        ...requestData,
      };
      _materialRequests.add(request);
      print('🔍 DEBUG: Заявка добавлена в _materialRequests. Всего заявок: ${_materialRequests.length}');
      print('🔍 DEBUG: Новая заявка: $request');
      return id;
    }

    // Удалить заявку на материалы
    int removeMaterialRequest(String requestId) {
      final before = _materialRequests.length;
      _materialRequests.removeWhere((r) => r['id'] == requestId);
      return before - _materialRequests.length;
    }

    // ============= ЗАЯВКИ НА БРИГАДИРОВ =============

    List<Map<String, dynamic>> getForemanRequests({String? customerId, String? status}) {
      var requests = _foremanRequests.toList();

      if (customerId != null) {
        requests = requests.where((req) => req['customerId'] == customerId).toList();
      }

      if (status != null) {
        requests = requests.where((req) => req['status'] == status).toList();
      }

      return requests;
    }

    String addForemanRequest(Map<String, dynamic> requestData) {
      final id = _generateId();
      final request = {
        'id': id,
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'active',
        'responses': [],
        'attachments': [],
        ...requestData,
      };
      _foremanRequests.add(request);
      return id;
    }

    // Удалить заявку на бригадира
    int removeForemanRequest(String requestId) {
      final before = _foremanRequests.length;
      _foremanRequests.removeWhere((r) => r['id'] == requestId);
      return before - _foremanRequests.length;
    }

    // ============= ЗАЯВКИ НА КУРЬЕРОВ =============

    List<Map<String, dynamic>> getCourierRequests({String? customerId, String? status}) {
      var requests = _courierRequests.toList();

      if (customerId != null) {
        requests = requests.where((req) => req['customerId'] == customerId).toList();
      }

      if (status != null) {
        requests = requests.where((req) => req['status'] == status).toList();
      }

      return requests;
    }

    String addCourierRequest(Map<String, dynamic> requestData) {
      final id = _generateId();
      final request = {
        'id': id,
        'customerId': requestData['customerId'],
        'title': requestData['title'],
        'description': requestData['description'],
        'pickup_address': requestData['pickup_address'],
        'pickup_date': requestData['pickup_date'],
        'pickup_time': requestData['pickup_time'],
        'goods_list': requestData['goods_list'],
        'delivery_address': requestData['delivery_address'],
        'delivery_date': requestData['delivery_date'],
        'delivery_time': requestData['delivery_time'],
        'budget': requestData['budget'],
        'needs_loaders': requestData['needs_loaders'],
        'city': requestData['city'],
        'status': 'active',
        'createdAt': DateTime.now().toIso8601String(),
        'attachments': requestData['attachments'] ?? [],
        'responses': [],
      };
      _courierRequests.add(request);
      return id;
    }

    // Удалить заявку на курьера
    int removeCourierRequest(String requestId) {
      final before = _courierRequests.length;
      _courierRequests.removeWhere((r) => r['id'] == requestId);
      return before - _courierRequests.length;
    }
    // ============= ЧАТЫ =============

    List<Map<String, dynamic>> getChatsByUserId(String userId) {
      return _chats.where((chat) =>
          (chat['participants'] as List).contains(userId)
      ).toList();
    }

    Map<String, dynamic>? getChatById(String chatId) {
      try {
        return _chats.firstWhere((chat) => chat['id'] == chatId);
      } catch (e) {
        return null;
      }
    }

    String addMessage(String chatId, String senderId, String text, {
      String? attachmentType,
      String? attachmentPath,
    }) {
      print('MockDatabase: Adding message to chat $chatId from sender $senderId: "$text"');
      if (attachmentType != null) {
        print('MockDatabase: With attachment type: $attachmentType, path: $attachmentPath');
      }

      final chatIndex = _chats.indexWhere((chat) => chat['id'] == chatId);
      print('MockDatabase: Found chat at index: $chatIndex');

      if (chatIndex != -1) {
        final messageId = _generateId();
        final message = {
          'id': messageId,
          'senderId': senderId,
          'text': text,
          'timestamp': DateTime.now().toIso8601String(),
          'isRead': false,
        };

        // Добавляем информацию о вложении если есть
        if (attachmentType != null) {
          message['attachmentType'] = attachmentType;
        }
        if (attachmentPath != null) {
          message['attachmentPath'] = attachmentPath;
        }

        (_chats[chatIndex]['messages'] as List).add(message);

        // Устанавливаем lastMessage в зависимости от типа сообщения
        if (text.isNotEmpty) {
          _chats[chatIndex]['lastMessage'] = text;
          print('MockDatabase: Setting lastMessage to text: "$text"');
        } else if (attachmentType == 'image') {
          _chats[chatIndex]['lastMessage'] = '📷 Фото';
          print('MockDatabase: Setting lastMessage to "📷 Фото" for image attachment');
        } else if (attachmentType == 'file') {
          _chats[chatIndex]['lastMessage'] = '📎 Файл';
          print('MockDatabase: Setting lastMessage to "📎 Файл" for file attachment');
        } else {
          _chats[chatIndex]['lastMessage'] = '📎 Вложение';
          print('MockDatabase: Setting lastMessage to "📎 Вложение" for unknown attachment type: $attachmentType');
        }

        _chats[chatIndex]['lastMessageTime'] = message['timestamp'];

        // Увеличиваем счетчик непрочитанных для всех участников кроме отправителя
        final participants = List<String>.from(_chats[chatIndex]['participants']);
        for (final participantId in participants) {
          if (participantId != senderId) {
            // Увеличиваем счетчик для участника который не отправлял сообщение
            _chats[chatIndex]['unreadCount'] = (_chats[chatIndex]['unreadCount'] ?? 0) + 1;
            break; // Для простоты считаем что в чате только 2 участника
          }
        }

        print('MockDatabase: Message added successfully. Chat now has ${(_chats[chatIndex]['messages'] as List).length} messages');
        print('MockDatabase: Unread count updated to: ${_chats[chatIndex]['unreadCount']}');

        return messageId;
      }
      print('MockDatabase: Error - Chat not found!');
      throw Exception('Chat not found');
    }

    // Создать новый чат
    String createChat(List<String> participants) {
      final chatId = _generateId();
      final chat = {
        'id': chatId,
        'participants': participants,
        'lastMessage': '',
        'lastMessageTime': DateTime.now().toIso8601String(),
        'unreadCount': 0,
        'messages': [],
      };
      _chats.add(chat);
      return chatId;
    }

    // Получить сообщения чата
    List<Map<String, dynamic>> getChatMessages(String chatId) {
      final chat = getChatById(chatId);
      if (chat != null) {
        return List<Map<String, dynamic>>.from(chat['messages'] ?? []);
      }
      return [];
    }

    // ============= ИЗБРАННОЕ =============

    List<Map<String, dynamic>> getFavoritesByUserId(String userId) {
      return _favorites.where((fav) => fav['userId'] == userId).toList();
    }

    void addToFavorites(String userId, String itemType, String itemId) {
      final favorite = {
        'id': _generateId(),
        'userId': userId,
        'itemType': itemType,
        'itemId': itemId,
        'createdAt': DateTime.now().toIso8601String(),
      };
      _favorites.add(favorite);
    }

    void removeFromFavorites(String userId, String itemId) {
      _favorites.removeWhere((fav) =>
      fav['userId'] == userId && fav['itemId'] == itemId
      );
    }

    // ============= ОТКЛИКИ =============

    // Создать отклик на заявку
    String createResponse(String requestId, String requestType, String responderId, 
    String customerId, String? responderRole, {String? message}) {
      final responseId = _generateId();
      final response = {
        'id': responseId,
        'requestId': requestId,
        'requestType': requestType, // material, foreman, courier
        'responderId': responderId, // ID того кто откликнулся
        'customerId': customerId, // ID заказчика
        'status': 'pending', // pending, accepted, rejected
        'message': message ?? 'Готов выполнить вашу заявку',
        'createdAt': DateTime.now().toIso8601String(),
        'responderRole': responderRole, // <-- сохраняем роль
      };

      _responses.add(response);
      print('=== CREATE RESPONSE DEBUG ===');
      print('response: ${_responses.last}');
      return responseId;
    }

    // Получить отклики на заявку
    List<Map<String, dynamic>> getResponsesForRequest(String requestId) {
      return _responses.where((response) => response['requestId'] == requestId).toList();
    }

    // Получить отклики пользователя (кто откликался)
    List<Map<String, dynamic>> getResponsesByResponder(
      String responderId, {
      String? role, // <-- добавляем необязательный параметр
    }) {
      return _responses.where((r) {
        final sameUser = r['responderId'] == responderId;
        final sameRole = role == null || r['responderRole'] == role;
        return sameUser && sameRole;
      }).toList();
    }


    // Получить отклики для заказчика (на его заявки)
    List<Map<String, dynamic>> getResponsesForCustomer(String customerId) {
      return _responses.where((response) => response['customerId'] == customerId).toList();
    }

    // Обновить статус отклика
    // bool updateResponseStatus(String responseId, String status) {
    //   final responseIndex = _responses.indexWhere((response) => response['id'] == responseId);
    //   if (responseIndex != -1) {
    //     _responses[responseIndex]['status'] = status;
    //     return true;
    //   }
    //   return false;
    // }

    // Проверить есть ли отклик на заявку от пользователя
    bool hasUserRespondedToRequest(String requestId, String userId) {
      return _responses.any((response) =>
      response['requestId'] == requestId && response['responderId'] == userId);
    }
    // ✅ НОВЫЙ МЕТОД: Получение отклика по ID
    Map<String, dynamic>? getResponseById(String responseId) {
      try {
        return _responses.firstWhere((resp) => resp['id'] == responseId);
      } catch (e) {
        return null;
      }
    }

    // ✅ НОВЫЙ МЕТОД: Обновление статуса отклика
    void updateResponseStatus(String responseId, String newStatus) {
      final responseIndex = _responses.indexWhere((resp) => resp['id'] == responseId);
      if (responseIndex != -1) {
        _responses[responseIndex]['status'] = newStatus;
      }
    }

    // ✅ НОВЫЙ МЕТОД: Отклонение всех остальных откликов для одной заявки
    void rejectOtherResponses(String requestId, String acceptedResponseId) {
      _responses
          .where((resp) => resp['requestId'] == requestId && resp['id'] != acceptedResponseId)
          .forEach((resp) => resp['status'] = 'rejected');
    }
    // ============= УТИЛИТЫ =============

    // Очистить все данные (для тестирования)
    void clearAllData() {
      _users.clear();
      _materialRequests.clear();
      _foremanRequests.clear();
      _courierRequests.clear();
      _chats.clear();
      _favorites.clear();
      _responses.clear();
    }

    // Получить статистику
    Map<String, int> getStatistics() {
      return {
        'totalUsers': _users.length,
        'customers': _users.where((u) => u['role'] == 'customer').length,
        'foremen': _users.where((u) => u['role'] == 'foreman').length,
        'suppliers': _users.where((u) => u['role'] == 'supplier').length,
        'couriers': _users.where((u) => u['role'] == 'courier').length,
        'materialRequests': _materialRequests.length,
        'foremanRequests': _foremanRequests.length,
        'courierRequests': _courierRequests.length,
        'chats': _chats.length,
        'favorites': _favorites.length,
      };
    }
    static final List<Map<String, dynamic>> _services = [
      {
        'id': 'service_101',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'status': 'active',
        'title': 'Электромонтажные работы',
        'type': 'foreman', // Услуги бригадира
        'userRole': 'foreman',
        'description': 'Полный спектр услуг по электрике: от замены розеток до монтажа проводки в новостройках.',
        'city': 'Алматы',
        'service_location': 'Все районы города',
        'budget': '8000',
        'attachments': ['path/to/image1.jpg'],
        'providerId': 'user_002',
        'providerName': 'Ерлан Казиев',
        'rating': '4.8',
      },
      {
        'id': 'service_102',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'status': 'active',
        'title': 'Доставка стройматериалов',
        'type': 'courier', // Услуги курьера
        'userRole': 'courier',
        'description': 'Быстрая и надежная доставка стройматериалов по городу. Работаю с грузчиками.',
        'city': 'Алматы',
        'service_location': 'Бостандыкский район',
        'budget': '3000',
        'attachments': [],
        'providerId': 'user_004',
        'providerName': 'Данияр Жумабеков',
        'rating': '4.5',
      },
      {
        'id': 'service_103',
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'active',
        'title': 'Качественный цемент М500',
        'type': 'supplier', // Материалы от поставщика
        'userRole': 'supplier',
        'description': 'Высококачественный цемент прямо от производителя. Доставка по городу включена.',
        'city': 'Алматы',
        'service_location': 'Склад на Розыбакиева',
        'budget': '2500',
        'attachments': ['path/to/image2.jpg', 'path/to/video1.mp4'],
        'providerId': 'user_003',
        'providerName': 'ТОО "СтройМат"',
        'rating': '4.9',
      },
      {
        'id': 'service_104',
        'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        'status': 'active',
        'title': 'Сантехнические работы',
        'type': 'foreman', // Услуги бригадира
        'userRole': 'foreman',
        'description': 'Установка, ремонт и обслуживание сантехнического оборудования. Работаю быстро и качественно.',
        'city': 'Алматы',
        'service_location': 'Все районы',
        'budget': '5000',
        'attachments': [],
        'providerId': 'user_002',
        'providerName': 'Ерлан Казиев',
        'rating': '4.8',
      },
      {
        'id': 'service_105',
        'createdAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        'status': 'active',
        'title': 'Кирпич керамический',
        'type': 'supplier', // Материалы от поставщика
        'userRole': 'supplier',
        'description': 'Качественный керамический кирпич для строительства. Различные размеры в наличии.',
        'city': 'Алматы',
        'service_location': 'Склад',
        'budget': '150',
        'attachments': [],
        'providerId': 'user_003',
        'providerName': 'ТОО "СтройМат"',
        'rating': '4.9',
      },
      {
        'id': 'service_106',
        'createdAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'status': 'active',
        'title': 'Экспресс-доставка',
        'type': 'courier', // Услуги курьера
        'userRole': 'courier',
        'description': 'Срочная доставка небольших грузов в течение 1-2 часов по городу.',
        'city': 'Алматы',
        'service_location': 'Весь город',
        'budget': '2000',
        'attachments': [],
        'providerId': 'user_004',
        'providerName': 'Данияр Жумабеков',
        'rating': '4.5',
      },
    ];

  // ✅ НОВЫЙ МЕТОД: Добавление услуги в базу данных
    String addService(Map<String, dynamic> serviceData) {
      final String serviceId = 'service_${Random().nextInt(10000)}';
      final now = DateTime.now().toIso8601String();
      
      // Приводим userRole к нормализованному виду
    String normalizedRole = serviceData['userRole'];
    switch (normalizedRole) {
      case 'Бригадир':
        normalizedRole = 'foreman';
        break;
      case 'Курьер':
        normalizedRole = 'courier';
        break;
      case 'Поставщик':
        normalizedRole = 'supplier';
        break;
      case 'Заказчик':
        normalizedRole = 'customer';
        break;
      default:
        normalizedRole = 'other';
    }

    _services.add({
      'id': serviceId,
      'createdAt': now,
      'status': 'active',
      'userRole': normalizedRole, // фиксируем роль
      'type': normalizedRole,     // можно оставить одинаково
      ...serviceData,
    });
      print('✅ Услуга добавлена в базу данных: $_services');
      return serviceId;
    }

    List<Map<String, dynamic>> getServicesByUser(String userId, String role) {
    return _services.where((s) =>
      s['providerId'] == userId && s['userRole'] == role
    ).toList();
  }

  // ✅ НОВЫЙ МЕТОД: Получение списка всех услуг
    List<Map<String, dynamic>> getServices() {
      return _services;
    }

    // ============= УВЕДОМЛЕНИЯ =============
    final List<Map<String, dynamic>> _notifications = [
      
    ];

    // Получить все уведомления пользователя
    List<Map<String, dynamic>> getNotificationsForUser(String userId) {
      return _notifications.where((n) => n['userId'] == userId).toList();
    }

    // Пометить уведомление как прочитанное
    void markNotificationAsRead(String notifId) {
      final notif = _notifications.firstWhere((n) => n['id'] == notifId, orElse: () => {});
      if (notif.isNotEmpty) notif['isRead'] = true;
    }

    // Добавить новое уведомление
    void addNotification(Map<String, dynamic> notif) {
      _notifications.add(notif);
    }

    // Удалить уведомление по id
    void deleteNotification(String notifId) {
      _notifications.removeWhere((n) => n['id'] == notifId);
    }

    // Очистить все уведомления пользователя
    void clearNotificationsForUser(String userId) {
      _notifications.removeWhere((n) => n['userId'] == userId);
    }

    // Удалить услугу по id
    int removeService(String serviceId) {
      final before = _services.length;
      _services.removeWhere((s) => s['id'] == serviceId);
      return before - _services.length;
    }
 // ✅ ДОБАВЬ ЭТО СЮДА — ПРЯМО ВНУТРЬ КЛАССА
    Map<String, dynamic>? getRequestByTypeAndId(String type, String id) {
      switch (type) {
        case 'material':
          try {
            return getMaterialRequests().firstWhere((r) => r['id'] == id);
          } catch (_) {
            return null;
          }
        case 'foreman':
          try {
            return getForemanRequests().firstWhere((r) => r['id'] == id);
          } catch (_) {
            return null;
          }
        case 'courier':
          try {
            return getCourierRequests().firstWhere((r) => r['id'] == id);
          } catch (_) {
            return null;
          }
        default:
          return null;
      }
    }
}

  