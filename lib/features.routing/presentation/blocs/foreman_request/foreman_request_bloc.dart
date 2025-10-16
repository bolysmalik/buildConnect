import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/core/mock/mock_services.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/foreman_request/foreman_request_event.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/foreman_request/foreman_request_state.dart';

class ForemanRequestBloc extends Bloc<ForemanRequestEvent, ForemanRequestState> {
  final MockServiceManager _serviceManager = MockServiceManager();
  
  ForemanRequestBloc() : super(const ForemanRequestInitial()) {
    on<ForemanRequestSubmitted>(_onForemanRequestSubmitted);
    on<AddAttachment>(_onAddAttachment);
    on<RemoveAttachment>(_onRemoveAttachment);
    on<ForemanRequestReset>(_onForemanRequestReset);
    
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _serviceManager.initialize();
  }

  Future<void> _onForemanRequestSubmitted(
      ForemanRequestSubmitted event,
      Emitter<ForemanRequestState> emit,
      ) async {
    emit(ForemanRequestLoading());
    try {
      await _serviceManager.initialize();
      
      // Получаем текущего пользователя
      final currentUser = _serviceManager.auth.currentUser;
      if (currentUser == null) {
        emit(ForemanRequestError('Пользователь не авторизован'));
        return;
      }

      final currentState = state;
      final attachments = currentState is ForemanRequestInitial 
          ? currentState.attachments 
          : <String>[];

      final dataWithAttachments = {
        ...event.requestData,
        'attachments': attachments,
      };

      print('Данные заявки на услуги бригадира: $dataWithAttachments');

      // Создаем заявку через mock сервис
      final result = await _serviceManager.requests.createForemanRequest(
        customerId: currentUser['id'],
        requestData: dataWithAttachments,
      );

      if (result['success'] == true) {
        emit(ForemanRequestSuccess());
      } else {
        emit(ForemanRequestError(result['message'] ?? 'Ошибка создания заявки'));
      }
    } catch (e) {
      emit(ForemanRequestError('Произошла ошибка при отправке заявки: $e'));
    }
  }

  void _onAddAttachment(AddAttachment event, Emitter<ForemanRequestState> emit) {
    final currentState = state;
    if (currentState is ForemanRequestInitial) {
      final newAttachments = List<String>.from(currentState.attachments)..add(event.filePath);
      emit(currentState.copyWith(attachments: newAttachments));
    }
  }

  void _onRemoveAttachment(RemoveAttachment event, Emitter<ForemanRequestState> emit) {
    final currentState = state;
    if (currentState is ForemanRequestInitial) {
      final newAttachments = List<String>.from(currentState.attachments)..remove(event.filePath);
      emit(currentState.copyWith(attachments: newAttachments));
    }
  }

  void _onForemanRequestReset(ForemanRequestReset event, Emitter<ForemanRequestState> emit) {
    emit(const ForemanRequestInitial());
  }
}