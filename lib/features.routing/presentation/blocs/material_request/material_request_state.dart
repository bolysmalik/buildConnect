import 'package:equatable/equatable.dart';

abstract class MaterialRequestState extends Equatable {
  const MaterialRequestState();

  @override
  List<Object> get props => [];
}

class MaterialRequestInitial extends MaterialRequestState {
  final List<String> attachments;

  const MaterialRequestInitial({this.attachments = const []});

  MaterialRequestInitial copyWith({List<String>? attachments}) {
    return MaterialRequestInitial(
      attachments: attachments ?? this.attachments,
    );
  }

  @override
  List<Object> get props => [attachments];
}

class MaterialRequestLoading extends MaterialRequestState {}

class MaterialRequestSuccess extends MaterialRequestState {}

class MaterialRequestError extends MaterialRequestState {
  final String message;

  const MaterialRequestError(this.message);

  @override
  List<Object> get props => [message];
}