import 'package:equatable/equatable.dart';

abstract class ForemanRequestEvent extends Equatable {
  const ForemanRequestEvent();

  @override
  List<Object> get props => [];
}

class ForemanRequestSubmitted extends ForemanRequestEvent {
  final Map<String, dynamic> requestData;

  const ForemanRequestSubmitted(this.requestData);

  @override
  List<Object> get props => [requestData];
}

class AddAttachment extends ForemanRequestEvent {
  final String filePath;

  const AddAttachment(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class RemoveAttachment extends ForemanRequestEvent {
  final String filePath;

  const RemoveAttachment(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class ForemanRequestReset extends ForemanRequestEvent {
  const ForemanRequestReset();
}