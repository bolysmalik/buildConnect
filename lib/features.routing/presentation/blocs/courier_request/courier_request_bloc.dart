import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/core/mock/mock_services.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/courier_request/courier_request_event.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/courier_request/courier_request_state.dart';

class CourierRequestBloc extends Bloc<CourierRequestEvent, CourierRequestState> {
  final MockServiceManager _serviceManager = MockServiceManager();
  
  CourierRequestBloc() : super(const CourierRequestInitial()) {
    on<CourierRequestSubmitted>(_onCourierRequestSubmitted);
    // ✅ ДОБАВЛЕНО: Обработчики для новых событий
    on<AddAttachment>(_onAddAttachment);
    on<RemoveAttachment>(_onRemoveAttachment);
    on<CourierRequestReset>(_onCourierRequestReset);
    
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _serviceManager.initialize();
  }

  Future<void> _onCourierRequestSubmitted(
      CourierRequestSubmitted event,
      Emitter<CourierRequestState> emit,
      ) async {
    emit(CourierRequestLoading());
    try {
      await _serviceManager.initialize();
      
      // Получаем текущего пользователя
      final currentUser = _serviceManager.auth.currentUser;
      if (currentUser == null) {
        emit(CourierRequestError('Пользователь не авторизован'));
        return;
      }

      final currentState = state;
      final attachments = currentState is CourierRequestInitial 
          ? currentState.attachments 
          : <String>[];

      final dataWithAttachments = {
        ...event.requestData,
        'attachments': attachments,
      };

      print('Данные заявки на услуги курьера: $dataWithAttachments');

      // Создаем заявку через mock сервис
      final result = await _serviceManager.requests.createCourierRequest(
        customerId: currentUser['id'],
        requestData: dataWithAttachments,
      );

      if (result['success'] == true) {
        emit(CourierRequestSuccess());
      } else {
        emit(CourierRequestError(result['message'] ?? 'Ошибка создания заявки'));
      }
    } catch (e) {
      emit(CourierRequestError('Произошла ошибка при отправке заявки: $e'));
    }
  }

  // ✅ ДОБАВЛЕНО: Логика для добавления вложения в состояние
  void _onAddAttachment(AddAttachment event, Emitter<CourierRequestState> emit) {
    final currentState = state;
    if (currentState is CourierRequestInitial) {
      final newAttachments = List<String>.from(currentState.attachments)..add(event.filePath);
      emit(currentState.copyWith(attachments: newAttachments));
    }
  }

  // ✅ ДОБАВЛЕНО: Логика для удаления вложения из состояния
  void _onRemoveAttachment(RemoveAttachment event, Emitter<CourierRequestState> emit) {
    final currentState = state;
    if (currentState is CourierRequestInitial) {
      final newAttachments = List<String>.from(currentState.attachments)..remove(event.filePath);
      emit(currentState.copyWith(attachments: newAttachments));
    }
  }

  void _onCourierRequestReset(CourierRequestReset event, Emitter<CourierRequestState> emit) {
    emit(const CourierRequestInitial());
  }
}