import 'package:equatable/equatable.dart';

abstract class ForemanRequestState extends Equatable {
  const ForemanRequestState();

  @override
  List<Object> get props => [];
}

class ForemanRequestInitial extends ForemanRequestState {
  final List<String> attachments;

  const ForemanRequestInitial({this.attachments = const []});

  ForemanRequestInitial copyWith({
    List<String>? attachments,
  }) {
    return ForemanRequestInitial(
      attachments: attachments ?? this.attachments,
    );
  }

  @override
  List<Object> get props => [attachments];
}

class ForemanRequestLoading extends ForemanRequestState {}

class ForemanRequestSuccess extends ForemanRequestState {}

class ForemanRequestError extends ForemanRequestState {
  final String message;

  const ForemanRequestError(this.message);

  @override
  List<Object> get props => [message];
}