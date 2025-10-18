import 'package:equatable/equatable.dart';

abstract class CourierRequestEvent extends Equatable {
  const CourierRequestEvent();

  @override
  List<Object> get props => [];
}

class CourierRequestSubmitted extends CourierRequestEvent {
  final Map<String, dynamic> requestData;

  const CourierRequestSubmitted(this.requestData);

  @override
  List<Object> get props => [requestData];
}

// ✅ ДОБАВЛЕНО: Новое событие для добавления вложения
class AddAttachment extends CourierRequestEvent {
  final String filePath;

  const AddAttachment(this.filePath);

  @override
  List<Object> get props => [filePath];
}

// ✅ ДОБАВЛЕНО: Событие для удаления вложения
class RemoveAttachment extends CourierRequestEvent {
  final String filePath;

  const RemoveAttachment(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class CourierRequestReset extends CourierRequestEvent {
  const CourierRequestReset();
}