import 'package:equatable/equatable.dart';

abstract class ServicePostingEvent extends Equatable {
  const ServicePostingEvent();

  @override
  List<Object?> get props => [];
}

class ServicePostingSubmitted extends ServicePostingEvent {
  final Map<String, dynamic> serviceData;

  const ServicePostingSubmitted(this.serviceData);

  @override
  List<Object?> get props => [serviceData];
}

class AddAttachment extends ServicePostingEvent {
  final String filePath;

  const AddAttachment(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class RemoveAttachment extends ServicePostingEvent {
  final String filePath;

  const RemoveAttachment(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class ServicePostingReset extends ServicePostingEvent {
  const ServicePostingReset();
}