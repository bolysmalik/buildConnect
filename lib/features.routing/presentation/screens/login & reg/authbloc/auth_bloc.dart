import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/authbloc/auth_event.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/authbloc/auth_state.dart';
import 'package:flutter_valhalla/core/mock/mock_service_manager.dart';
import 'dart:async';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final MockServiceManager _serviceManager = MockServiceManager();
  
  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthLoginWithPhoneEvent>(_onLoginWithPhone);
    on<AuthLoginWithSocialEvent>(_onLoginWithSocial);
    on<AuthLogoutEvent>(_onLogout);

    // ОБРАБОТЧИКИ ДЛЯ РЕГИСТРАЦИИ
    on<AuthRegisterCustomerEvent>(_onRegisterCustomer);
    on<AuthRegisterForemanEvent>(_onRegisterForeman);
    on<AuthRegisterSupplierEvent>(_onRegisterSupplier);
    on<AuthRegisterCourierEvent>(_onRegisterCourier);
    on<AuthRoleChangedEvent>(_onRoleChanged);
    
    // Инициализируем сервисы
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _serviceManager.initialize();
  }

  Future<void> _onCheckStatus(AuthCheckStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _serviceManager.initialize();
      final currentUser = await _serviceManager.auth.checkAuthStatus();
      
      if (currentUser != null) {
        emit(AuthAuthenticated(
          currentUser['id'],
          _serviceManager.auth.activeRole?.name ?? (currentUser['roles'] as List).first,
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginWithPhone(AuthLoginWithPhoneEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _serviceManager.auth.signInWithPhone(event.phoneNumber, event.password);
      
      if (result['success'] == true) {
        final user = result['user'];
        emit(AuthAuthenticated(
          user['id'],
          _serviceManager.auth.activeRole?.name ?? (user['roles'] as List).first,
        ));

      } else {
        emit(AuthError(result['message'] ?? 'Ошибка входа'));
      }
    } catch (e) {
      emit(AuthError('Ошибка входа: $e'));
    }
  }

  Future<void> _onRoleChanged(AuthRoleChangedEvent event, Emitter<AuthState> emit) async {
    final currentUser = _serviceManager.auth.currentUser;
    if (currentUser != null) {
      _serviceManager.auth.setActiveRole(event.newRole);
      emit(AuthAuthenticated(
        currentUser['id'],
        event.newRole.name,
      ));
    }
  }

  Future<void> _onLoginWithSocial(AuthLoginWithSocialEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _serviceManager.auth.signInWithSocial('apple'); // Используем Apple как пример
      
      if (result['success'] == true) {
        final user = result['user'];
        emit(AuthAuthenticated(
          user['id'],
          _serviceManager.auth.activeRole?.name ?? (user['roles'] as List).first,
        ));

      } else {
        emit(AuthError(result['message'] ?? 'Ошибка входа через соцсети'));
      }
    } catch (e) {
      emit(AuthError('Ошибка входа через соцсети: $e'));
    }
  }

  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _serviceManager.auth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Ошибка выхода: $e'));
    }
  }

  // ОБРАБОТЧИК ДЛЯ РЕГИСТРАЦИИ ЗАКАЗЧИКА
  Future<void> _onRegisterCustomer(AuthRegisterCustomerEvent event, Emitter<AuthState> emit) async {
    print('Данные для регистрации заказчика (Map): ${event.customerData}');
    emit(AuthLoading());
    try {
      final result = await _serviceManager.auth.registerCustomer(event.customerData);
      
      if (result['success'] == true) {
        final user = result['user'];
          emit(AuthAuthenticated(
            user['id'],
            _serviceManager.auth.activeRole?.name ?? (user['roles'] as List).first,
          ));

      } else {
        emit(AuthError(result['message'] ?? 'Ошибка регистрации заказчика'));
      }
    } catch (e) {
      emit(AuthError('Ошибка регистрации заказчика: $e'));
    }
  }

  // ОБРАБОТЧИК ДЛЯ РЕГИСТРАЦИИ БРИГАДИРА
  Future<void> _onRegisterForeman(AuthRegisterForemanEvent event, Emitter<AuthState> emit) async {
    print('Данные для регистрации бригадира (Map): ${event.foremanData}');
    emit(AuthLoading());
    try {
      final result = await _serviceManager.auth.registerForeman(event.foremanData);
      
      if (result['requiresModeration'] == true) {
        emit(const AuthRegistrationPendingModeration());
      } else if (result['success'] == true) {
        final user = result['user'];
        emit(AuthAuthenticated(
            user['id'],
            _serviceManager.auth.activeRole?.name ?? (user['roles'] as List).first,
          ));
      } else {
        emit(AuthError(result['message'] ?? 'Ошибка регистрации бригадира'));
      }
    } catch (e) {
      emit(AuthError('Ошибка регистрации бригадира: $e'));
    }
  }

  // ОБРАБОТЧИК ДЛЯ РЕГИСТРАЦИИ ПОСТАВЩИКА
  Future<void> _onRegisterSupplier(AuthRegisterSupplierEvent event, Emitter<AuthState> emit) async {
    print('Данные для регистрации поставщика (Map): ${event.supplierData}');
    emit(AuthLoading());
    try {
      final result = await _serviceManager.auth.registerSupplier(event.supplierData);
      
      if (result['requiresModeration'] == true) {
        emit(const AuthRegistrationPendingModeration());
      } else if (result['success'] == true) {
        final user = result['user'];
        emit(AuthAuthenticated(
            user['id'],
            _serviceManager.auth.activeRole?.name ?? (user['roles'] as List).first,
          ));
      } else {
        emit(AuthError(result['message'] ?? 'Ошибка регистрации поставщика'));
      }
    } catch (e) {
      emit(AuthError('Ошибка регистрации поставщика: $e'));
    }
  }

  // ОБРАБОТЧИК ДЛЯ РЕГИСТРАЦИИ КУРЬЕРА
  Future<void> _onRegisterCourier(AuthRegisterCourierEvent event, Emitter<AuthState> emit) async {
    print('Данные для регистрации курьера (Map): ${event.courierData}');
    emit(AuthLoading());
    try {
      final result = await _serviceManager.auth.registerCourier(event.courierData);
      
      if (result['requiresModeration'] == true) {
        emit(const AuthRegistrationPendingModeration());
      } else if (result['success'] == true) {
        final user = result['user'];
        emit(AuthAuthenticated(
            user['id'],
           _serviceManager.auth.activeRole?.name ?? (user['roles'] as List).first,
          ));
      } else {
        emit(AuthError(result['message'] ?? 'Ошибка регистрации курьера'));
      }
    } catch (e) {
      emit(AuthError('Ошибка регистрации курьера: $e'));
    }
  }
}