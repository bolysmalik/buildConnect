import 'package:equatable/equatable.dart';

abstract class CourierRequestState extends Equatable {
  const CourierRequestState();

  @override
  List<Object> get props => [];
}

class CourierRequestInitial extends CourierRequestState {
  // ✅ ДОБАВЛЕНО: Список путей к вложениям
  final List<String> attachments;

  const CourierRequestInitial({this.attachments = const []});

  CourierRequestInitial copyWith({
    List<String>? attachments,
  }) {
    return CourierRequestInitial(
      attachments: attachments ?? this.attachments,
    );
  }

  @override
  List<Object> get props => [attachments];
}

class CourierRequestLoading extends CourierRequestState {}

class CourierRequestSuccess extends CourierRequestState {}

class CourierRequestError extends CourierRequestState {
  final String message;

  const CourierRequestError(this.message);

  @override
  List<Object> get props => [message];
}