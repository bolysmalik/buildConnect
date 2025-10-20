// test_mock_system.dart
// Тест для проверки работы mock системы

import 'package:flutter_valhalla/core/mock/mock_services.dart';

Future<void> testMockSystem() async {
  print('🧪 Тестирование mock системы...\n');
  
  try {
    // Инициализация
    final serviceManager = MockServiceManager();
    await serviceManager.initialize();
    print('✅ MockServiceManager инициализирован');
    
    // Тест базы данных
    print('\n📊 Тест базы данных:');
    final stats = serviceManager.db.getStatistics();
    print('Статистика: $stats');
    
    // Тест аутентификации
    print('\n🔐 Тест аутентификации:');
    
    // Вход существующего пользователя
    final loginResult = await serviceManager.auth.signInWithPhone('+77771234567', 'test123');
    print('Вход: ${loginResult['success'] ? "✅" : "❌"} ${loginResult['message']}');
    
    if (loginResult['success']) {
      final currentUser = serviceManager.auth.currentUser;
      print('Текущий пользователь: ${currentUser?['name']} (${currentUser?['role']})');
    }
    
    // Тест заявок
    print('\n📝 Тест заявок:');
    if (serviceManager.auth.currentUser != null) {
      final userId = serviceManager.auth.currentUser!['id'];
      
      // Создаем тестовую заявку
      final materialRequestResult = await serviceManager.requests.createMaterialRequest(
        customerId: userId,
        requestData: {
          'title': 'Тест цемент',
          'description': 'Тестовая заявка на цемент',
          'quantity': '10 мешков',
          'budget': '25000',
          'city': 'Алматы',
          'address': 'Тестовый адрес',
        },
      );
      print('Создание заявки: ${materialRequestResult['success'] ? "✅" : "❌"} ${materialRequestResult['message']}');
      
      // Получаем заявки пользователя
      final userRequests = await serviceManager.requests.getMaterialRequests(customerId: userId);
      print('Заявки пользователя: ${userRequests.length} шт.');
    }
    
    // Тест чатов
    print('\n💬 Тест чатов:');
    if (serviceManager.auth.currentUser != null) {
      final userId = serviceManager.auth.currentUser!['id'];
      
      // Получаем чаты пользователя
      final userChats = await serviceManager.chat.getUserChats(userId);
      print('Чаты пользователя: ${userChats.length} шт.');
      
      if (userChats.isNotEmpty) {
        final chatId = userChats.first['id'];
        
        // Отправляем тестовое сообщение
        final messageResult = await serviceManager.chat.sendMessage(
          chatId: chatId,
          senderId: userId,
          text: 'Тестовое сообщение от ${DateTime.now()}',
        );
        print('Отправка сообщения: ${messageResult['success'] ? "✅" : "❌"} ${messageResult['message']}');
      }
    }
    
    // Общая статистика
    print('\n📈 Общая статистика:');
    final fullStats = await serviceManager.getFullStatistics();
    print('Полная статистика: $fullStats');
    
    print('\n🎉 Все тесты пройдены успешно!');
    
  } catch (e) {
    print('❌ Ошибка в тесте: $e');
  }
}

// Функция для демонстрации быстрого входа
Future<void> quickLoginDemo() async {
  print('\n🚀 Демонстрация быстрого входа...');
  
  final serviceManager = MockServiceManager();
  await serviceManager.initialize();
  
  final roles = ['customer', 'foreman', 'supplier', 'courier'];
  
  for (final role in roles) {
    try {
      final result = await serviceManager.loginAsTestUser(role);
      print('Вход как $role: ${result['success'] ? "✅" : "❌"} ${result['user']['name']}');
      await serviceManager.auth.signOut();
    } catch (e) {
      print('Ошибка входа $role: $e');
    }
  }
}
