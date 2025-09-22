import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;
  final String userRole;
  const AuthAuthenticated(this.userId,this.userRole);

  @override
  List<Object> get props => [userId,userRole];
}

class AuthUnauthenticated extends AuthState {}

// НОВОЕ СОСТОЯНИЕ: для ролей, требующих модерации
class AuthRegistrationPendingModeration extends AuthState {
  const AuthRegistrationPendingModeration();

  @override
  List<Object> get props => [];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}