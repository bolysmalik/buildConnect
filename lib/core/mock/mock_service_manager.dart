// mock_service_manager.dart
// Центральный менеджер для всех mock сервисов

import 'mock_database.dart';
import 'mock_auth_service.dart';
import 'mock_requests_service.dart';
import 'mock_chat_service.dart';
import 'dart:async';

class MockServiceManager {
  static final MockServiceManager _instance = MockServiceManager._internal();
  factory MockServiceManager() => _instance;
  MockServiceManager._internal();

  // Синглтоны сервисов
  late final MockDatabase database;
  late final MockAuthService authService;
  late final MockRequestsService requestsService;
  late final MockChatService chatService;

  // Флаг инициализации
  bool _isInitialized = false;

  // Стрим для уведомлений о новых заявках
  final StreamController<String> _newRequestController =
  StreamController<String>.broadcast();

  Stream<String> get newRequestStream => _newRequestController.stream;

  // Стрим для уведомлений об обновлении чатов (прочитанные сообщения и т.д.)
  final StreamController<String> _chatUpdateController =
  StreamController<String>.broadcast();

  Stream<String> get chatUpdateStream => _chatUpdateController.stream;

  // Инициализация всех сервисов
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Инициализируем сервисы
    database = MockDatabase();
    authService = MockAuthService();
    requestsService = MockRequestsService(database);
    chatService = MockChatService();

    // Передаем базу данных в сервисы
    chatService.setDatabase(database);

    // Настраиваем уведомления о новых заявках
    requestsService.setNewRequestCallback((requestType) {
      notifyNewRequest(requestType);
    });

    // Заполняем тестовыми данными при необходимости
    await _seedTestData();

    _isInitialized = true;
    print('✅ MockServiceManager инициализирован');
  }

  // Заполнение тестовыми данными
  Future<void> _seedTestData() async {
    // Проверяем, есть ли уже данные
    final stats = database.getStatistics();

    if (stats['totalUsers'] == 0) {
      print('📊 Заполняем базу тестовыми данными...');

      // Тестовые данные уже есть в MockDatabase при инициализации
      // Здесь можно добавить дополнительные данные если нужно

      print('✅ Тестовые данные загружены');
      print('📈 Статистика: ${database.getStatistics()}');
    } else {
      print('📊 Найдены существующие данные: ${stats}');
    }
  }

  // Получение экземпляров сервисов
  MockDatabase get db {
    _ensureInitialized();
    return database;
  }

  MockAuthService get auth {
    _ensureInitialized();
    return authService;
  }

  MockRequestsService get requests {
    _ensureInitialized();
    return requestsService;
  }

  MockChatService get chat {
    _ensureInitialized();
    return chatService;
  }

  // Проверка инициализации
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception('MockServiceManager не инициализирован! Вызовите initialize() сначала.');
    }
  }

  // Проверка готовности
  bool get isInitialized => _isInitialized;

  // Сброс всех данных (для тестирования)
  Future<void> resetAllData() async {
    _ensureInitialized();

    print('🔄 Сброс всех mock данных...');
    database.clearAllData();
    await authService.signOut();

    // Заполняем заново тестовыми данными
    await _seedTestData();

    print('✅ Данные сброшены и пересозданы');
  }

  // Получить полную статистику всех сервисов
  Future<Map<String, dynamic>> getFullStatistics() async {
    _ensureInitialized();

    final dbStats = database.getStatistics();
    final currentUser = authService.currentUser;
    final unreadMessages = currentUser != null
        ? await chatService.getUnreadMessagesCount(currentUser['id'])
        : 0;

    return {
      'database': dbStats,
      'auth': {
        'isAuthenticated': currentUser != null,
        'currentUserId': currentUser?['id'],
        'currentUserRole': currentUser?['role'],
      },
      'chat': {
        'unreadMessages': unreadMessages,
      },
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Освобождение ресурсов
  void dispose() {
    if (_isInitialized) {
      authService.dispose();
      chatService.dispose();
      _newRequestController.close();
      _isInitialized = false;
      print('🔥 MockServiceManager освобожден');
    }
  }

  // Уведомить о новой заявке
  void notifyNewRequest(String requestType) {
    _newRequestController.add(requestType);
  }

  // Уведомить об обновлении чатов (прочитанные сообщения и т.д.)
  void notifyChatUpdate(String chatId) {
    _chatUpdateController.add(chatId);
  }

  // ============= УДОБНЫЕ МЕТОДЫ =============

  // Быстрый вход тестового пользователя
  Future<Map<String, dynamic>> loginAsTestUser(String role) async {
    _ensureInitialized();

    final testUsers = {
      'customer': '+77771234567',
      'foreman': '+77779876543',
      'supplier': '+77775555555',
      'courier': '+77778888888',
    };

    final phone = testUsers[role];
    if (phone == null) {
      throw Exception('Неизвестная роль: $role');
    }

    return await authService.signInWithPhone(phone, 'test123');
  }

  // Создать тестовую заявку
  Future<String> createTestRequest(String type, String customerId) async {
    _ensureInitialized();

    final testData = {
      'material': {
        'title': 'Тестовая заявка на материалы',
        'description': 'Описание тестовой заявки',
        'quantity': '10 единиц',
        'budget': '50000',
        'city': 'Алматы',
        'address': 'Тестовый адрес 123',
      },
      'foreman': {
        'title': 'Тестовая заявка на бригадира',
        'description': 'Нужен бригадир для тестовых работ',
        'workType': 'Общие работы',
        'budget': '100000',
        'city': 'Алматы',
        'address': 'Тестовый объект 456',
        'startDate': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'duration': '5 дней',
      },
      'courier': {
        'title': 'Тестовая заявка на курьера',
        'description': 'Нужна доставка тестового груза',
        'fromAddress': 'Склад тестовый',
        'toAddress': 'Объект тестовый',
        'cargoType': 'Документы',
        'weight': '1 кг',
        'budget': '5000',
        'city': 'Алматы',
        'pickupDate': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      },
    };

    final data = testData[type];
    if (data == null) {
      throw Exception('Неизвестный тип заявки: $type');
    }

    switch (type) {
      case 'material':
        final result = await requestsService.createMaterialRequest(
          customerId: customerId,
          requestData: data,
        );
        return result['requestId'];
      case 'foreman':
        final result = await requestsService.createForemanRequest(
          customerId: customerId,
          requestData: data,
        );
        return result['requestId'];
      case 'courier':
        final result = await requestsService.createCourierRequest(
          customerId: customerId,
          requestData: data,
        );
        return result['requestId'];
      default:
        throw Exception('Неизвестный тип заявки: $type');
    }
  }
}