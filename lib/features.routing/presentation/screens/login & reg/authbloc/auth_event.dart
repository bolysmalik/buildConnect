import 'package:equatable/equatable.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/registration/view/registration_page.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class AuthCheckStatusEvent extends AuthEvent {
  const AuthCheckStatusEvent();
}

class AuthLoginWithPhoneEvent extends AuthEvent {
  const AuthLoginWithPhoneEvent(this.phoneNumber, this.password);
  final String phoneNumber;
  final String password;
  @override
  List<Object> get props => [phoneNumber, password];
}
class AuthLoginWithTelegramEvent extends AuthEvent {
  final String id;
  final String username;

  const AuthLoginWithTelegramEvent({required this.id, required this.username});

  @override
  List<Object> get props => [id, username];
}
class AuthLoginWithSocialEvent extends AuthEvent {
  const AuthLoginWithSocialEvent();
}

class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent();
}

// НОВЫЕ СОБЫТИЯ ДЛЯ РЕГИСТРАЦИИ
class AuthRegisterCustomerEvent extends AuthEvent {
  const AuthRegisterCustomerEvent(this.customerData);
  final Map<String, dynamic> customerData;
  @override
  List<Object> get props => [customerData];
}

class AuthRegisterForemanEvent extends AuthEvent {
  const AuthRegisterForemanEvent(this.foremanData);
  final Map<String, dynamic> foremanData;
  @override
  List<Object> get props => [foremanData];
}

class AuthRegisterSupplierEvent extends AuthEvent {
  const AuthRegisterSupplierEvent(this.supplierData);
  final Map<String, dynamic> supplierData;
  @override
  List<Object> get props => [supplierData];
}

class AuthRegisterCourierEvent extends AuthEvent {
  const AuthRegisterCourierEvent(this.courierData);
  final Map<String, dynamic> courierData;
  @override
  List<Object> get props => [courierData];
}

class AuthRoleChangedEvent extends AuthEvent {
  final RegistrationRole newRole;

  const AuthRoleChangedEvent(this.newRole);
}