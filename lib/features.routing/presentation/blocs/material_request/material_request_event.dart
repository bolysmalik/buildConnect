import 'package:equatable/equatable.dart';

abstract class MaterialRequestEvent extends Equatable {
  const MaterialRequestEvent();

  @override
  List<Object> get props => [];
}

class MaterialRequestSubmitted extends MaterialRequestEvent {
  final Map<String, dynamic> requestData;

  const MaterialRequestSubmitted(this.requestData);

  @override
  List<Object> get props => [requestData];
}

class AddAttachment extends MaterialRequestEvent {
  final String filePath;

  const AddAttachment(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class RemoveAttachment extends MaterialRequestEvent {
  final String filePath;

  const RemoveAttachment(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class MaterialRequestReset extends MaterialRequestEvent {
  const MaterialRequestReset();
}