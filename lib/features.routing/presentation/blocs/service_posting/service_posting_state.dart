import 'package:equatable/equatable.dart';

abstract class ServicePostingState extends Equatable {
  const ServicePostingState();

  @override
  List<Object?> get props => [];
}

class ServicePostingInitial extends ServicePostingState {
  final List<String> attachments;

  const ServicePostingInitial({this.attachments = const []});

  @override
  List<Object?> get props => [attachments];
}

class ServicePostingLoading extends ServicePostingState {}

class ServicePostingSuccess extends ServicePostingState {}

class ServicePostingError extends ServicePostingState {
  final String message;

  const ServicePostingError({required this.message});

  @override
  List<Object?> get props => [message];
}