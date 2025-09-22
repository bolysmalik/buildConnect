// mock_auth_service.dart
// Сервис для имитации аутентификации

import 'dart:async';
import 'package:flutter_valhalla/core/utils/phone_utils.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/registration/view/registration_page.dart';

import 'mock_database.dart';

class MockAuthService {
  static final MockAuthService _instance = MockAuthService._internal();
  factory MockAuthService() => _instance;
  MockAuthService._internal();

  final MockDatabase _db = MockDatabase();

  // 🔹 Список зарегистрированных ролей
  final Set<RegistrationRole> _registeredRoles = {};

  // 🔹 Активная роль (для ProfilePage, Drawer и т.д.)
  RegistrationRole? activeRole;

  // ✅ Стрим для активной роли (чтобы UI и сервисы реагировали)
  final StreamController<RegistrationRole?> _activeRoleController =
      StreamController<RegistrationRole?>.broadcast();

  Stream<RegistrationRole?> get activeRoleChanges =>
      _activeRoleController.stream;

  // 🔹 Установка активной роли
  void setActiveRole(RegistrationRole role) {
    activeRole = role;
    _activeRoleController.add(role); // ✅ уведомляем подписчиков
    print('🔹 Активная роль установлена: ${role.name}');
  }

  // 🔹 Получение активной роли
  RegistrationRole? getActiveRole() => activeRole;

  // 🔹 Получение профиля
  Map<String, dynamic>? getUserProfile() {
    return _currentUser;
  }

  // Проверка, зарегистрирован ли пользователь в роли
  bool hasRole(RegistrationRole role) {
    return getUserRoles().contains(role.name);
  }

  // Сохраняем роль после регистрации
  void registerRole(RegistrationRole role) {
    _registeredRoles.add(role);

    if (_currentUser != null) {
      final roles = (_currentUser!['roles'] as List<String>? ?? []);
      if (!roles.contains(role.name)) {
        roles.add(role.name);
        _currentUser = {
          ..._currentUser!,
          'roles': roles,
        };
        _authController.add(_currentUser);
      }
    }
   // ✅ если роль только что зарегистрирована — делаем её активной
    if (activeRole == null) {
      setActiveRole(role);
    }
  }

  // Текущий пользователь
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;

  // Стрим для состояния аутентификации
  final StreamController<Map<String, dynamic>?> _authController =
      StreamController<Map<String, dynamic>?>.broadcast();

  Stream<Map<String, dynamic>?> get authStateChanges => _authController.stream;

  // Проверка статуса аутентификации
  Future<Map<String, dynamic>?> checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }

  // Вход по номеру телефона (имитация)
  Future<Map<String, dynamic>> signInWithPhone(
      String phone, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    final normalizedPhone = PhoneUtils.normalize(phone);
    final user = _db.getUserByPhone(normalizedPhone);
    if (user != null) {
      if (user['password'] == password) {
        // 🔹 проверка пароля
        _currentUser = user;
        _authController.add(_currentUser);
        // ✅ если у юзера есть роли — ставим первую активной
        if ((_currentUser!['roles'] as List).isNotEmpty) {
          final roleName = (_currentUser!['roles'] as List).first;
          final role = RegistrationRole.values
              .firstWhere((r) => r.name == roleName, orElse: () => RegistrationRole.customer);
          setActiveRole(role);
        }
        return {
          'success': true,
          'user': user,
          'message': 'Успешный вход',
        };
      } else {
        throw Exception('Неверный пароль');
      }
    } else {
      throw Exception('Пользователь с таким номером не найден');
    }
  }

  // Вход через социальные сети (имитация)
  Future<Map<String, dynamic>> signInWithSocial(String provider) async {
    await Future.delayed(const Duration(seconds: 2));

    final existingUser = _db.getUserById('user_001'); // демо
    if (existingUser != null) {
      _currentUser = existingUser;
      _authController.add(_currentUser);
      // ✅ ставим активную роль
      if ((_currentUser!['roles'] as List).isNotEmpty) {
        final roleName = (_currentUser!['roles'] as List).first;
        final role = RegistrationRole.values
            .firstWhere((r) => r.name == roleName, orElse: () => RegistrationRole.customer);
        setActiveRole(role);
      }
      return {
        'success': true,
        'user': existingUser,
        'message': 'Успешный вход через $provider',
      };
    } else {
      throw Exception('Ошибка входа через $provider');
    }
  }

  // Регистрация заказчика
  Future<Map<String, dynamic>> registerCustomer(
      Map<String, dynamic> customerData) async {
    await Future.delayed(const Duration(seconds: 2));
    final normalizedPhone = PhoneUtils.normalize(customerData['phone']);
    final existingUser = _db.getUserByPhone(customerData['phone']);
    if (existingUser != null) {
      _currentUser = existingUser;
    } else {
      final userData = {
        ...customerData,
        'phone': normalizedPhone,
        'roles': ['customer'],
        'isVerified': true,
        'password': customerData['password'], // 🔹 сохраняем пароль
      };
      final userId = _db.addUser(userData);
      _currentUser = _db.getUserById(userId);
      _currentUser!['id'] = userId;
    }

    registerRole(RegistrationRole.customer);
    _authController.add(_currentUser);
    return {
      'success': true,
      'user': _currentUser,
      'message': 'Регистрация завершена успешно',
    };
  }

  // Регистрация бригадира
  Future<Map<String, dynamic>> registerForeman(
      Map<String, dynamic> foremanData) async {
    await Future.delayed(const Duration(seconds: 2));
    final normalizedPhone = PhoneUtils.normalize(foremanData['phone']);
    final existingUser = _db.getUserByPhone(foremanData['phone']);
    if (existingUser != null) {
      _currentUser = existingUser;
    } else {
      final userData = {
        ...foremanData,
        'phone': normalizedPhone,
        'roles': ['foreman'],
        'isVerified': true,
        'password': foremanData['password'], // 🔹 сохраняем пароль
      };
      final userId = _db.addUser(userData);
      _currentUser = _db.getUserById(userId);
      _currentUser!['id'] = userId;
    }

    registerRole(RegistrationRole.foreman);
    _authController.add(_currentUser);
    return {
      'success': true,
      'user': _currentUser,
      'message': 'Регистрация завершена успешно',
    };
  }

  // Регистрация поставщика
  Future<Map<String, dynamic>> registerSupplier(
      Map<String, dynamic> supplierData) async {
    await Future.delayed(const Duration(seconds: 2));
    final normalizedPhone = PhoneUtils.normalize(supplierData['phone']);
    final existingUser = _db.getUserByPhone(supplierData['phone']);
    if (existingUser != null) {
      _currentUser = existingUser;
    } else {
      final userData = {
        ...supplierData,
        'phone': normalizedPhone, 
        'roles': ['supplier'],
        'isVerified': true,
        'password': supplierData['password'], // 🔹 сохраняем пароль
      };
      final userId = _db.addUser(userData);
      _currentUser = _db.getUserById(userId);
      _currentUser!['id'] = userId;
    }

    registerRole(RegistrationRole.supplier);
    _authController.add(_currentUser);
    return {
      'success': true,
      'user': _currentUser,
      'message': 'Регистрация завершена успешно',
    };
  }

  // Регистрация курьера
  Future<Map<String, dynamic>> registerCourier(
      Map<String, dynamic> courierData) async {
    await Future.delayed(const Duration(seconds: 2));
    final normalizedPhone = PhoneUtils.normalize(courierData['phone']);
    final existingUser = _db.getUserByPhone(courierData['phone']);
    if (existingUser != null) {
      _currentUser = existingUser;
    } else {
      final userData = {
        ...courierData,
        'phone': normalizedPhone,
        'roles': ['courier'],
        'isVerified': true,
        'password': courierData['password'], // 🔹 сохраняем пароль
      };
      final userId = _db.addUser(userData);
      _currentUser = _db.getUserById(userId);
      _currentUser!['id'] = userId;
    }

    registerRole(RegistrationRole.courier);
    _authController.add(_currentUser);
    return {
      'success': true,
      'user': _currentUser,
      'message': 'Регистрация завершена успешно',
    };
  }
  
  // Получение пользователя по активной роли
  Map<String, dynamic>? getUserByActiveRole() {
    if (_currentUser == null) return null;

    final roles = List<String>.from(_currentUser?['roles'] ?? []);
    final roleName = activeRole?.name;

    if (roles.contains(roleName)) {
      return {
        ..._currentUser!,
        'activeRole': roleName, // ✅ полезно для логов
      };
    }

    return null;
  }

  // Выход из системы
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    activeRole = null; // ✅ сбрасываем активную роль
    _authController.add(null);
    _activeRoleController.add(null);
  }

  // Обновление профиля пользователя
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> updates) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_currentUser != null) {
      final userId = _currentUser!['id'];
      final updatedUser = {
        ..._currentUser!,
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final success = _db.updateUser(userId, updates);
      if (success) {
        _currentUser = updatedUser;
        _authController.add(_currentUser);
      }

      return {
        'success': success,
        'user': updatedUser,
        'message':
            success ? 'Профиль обновлен успешно' : 'Ошибка обновления профиля',
      };
    } else {
      throw Exception('Пользователь не аутентифицирован');
    }
  }

  // Получить информацию о пользователе по ID
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _db.getUserById(userId);
  }

  // Проверка верификации пользователя
  bool isUserVerified() {
    return _currentUser?['isVerified'] == true;
  }

  // Получить все роли пользователя
  List<String> getUserRoles() {
    return List<String>.from(_currentUser?['roles'] ?? []);
  }

  // Получить ID пользователя
  String? getUserId() {
    return _currentUser?['id'];
  }

  // Получить пользователя по ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _db.getUserById(userId);
  }

  // Освободить ресурсы
  void dispose() {
    _authController.close();
    _activeRoleController.close(); // ✅
  }
}
