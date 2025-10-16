import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/core/mock/mock_services.dart';
import 'material_request_event.dart';
import 'material_request_state.dart';

class MaterialRequestBloc extends Bloc<MaterialRequestEvent, MaterialRequestState> {
  final MockServiceManager _serviceManager = MockServiceManager();
  
  MaterialRequestBloc() : super(MaterialRequestInitial()) {
    on<MaterialRequestSubmitted>(_onMaterialRequestSubmitted);
    on<AddAttachment>(_onAddAttachment); // ✅ ДОБАВЛЕНО: Обработчик для добавления файла
    on<RemoveAttachment>(_onRemoveAttachment); // ✅ ДОБАВЛЕНО: Обработчик для удаления файла
    on<MaterialRequestReset>(_onMaterialRequestReset); // ✅ ДОБАВЛЕНО: Обработчик для сброса
    
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _serviceManager.initialize();
  }

  Future<void> _onMaterialRequestSubmitted(
      MaterialRequestSubmitted event,
      Emitter<MaterialRequestState> emit,
      ) async {
    emit(MaterialRequestLoading());
    try {
      await _serviceManager.initialize();
      
      // Получаем текущего пользователя
      final currentUser = _serviceManager.auth.currentUser;
      print('🔍 DEBUG: Current user в MaterialRequestBloc: $currentUser');
      
      if (currentUser == null) {
        emit(MaterialRequestError('Пользователь не авторизован'));
        return;
      }

      final currentState = state;
      final attachments = currentState is MaterialRequestInitial 
          ? currentState.attachments 
          : <String>[];

      final dataWithAttachments = {
        ...event.requestData,
        'attachments': attachments,
      };

      print('🔍 DEBUG: Данные заявки на материалы: $dataWithAttachments');

      // Создаем заявку через mock сервис
      final result = await _serviceManager.requests.createMaterialRequest(
        customerId: currentUser['id'],
        requestData: dataWithAttachments,
      );

      print('🔍 DEBUG: Результат создания заявки: $result');

      if (result['success'] == true) {
        emit(MaterialRequestSuccess());
      } else {
        emit(MaterialRequestError(result['message'] ?? 'Ошибка создания заявки'));
      }
    } catch (e) {
      emit(MaterialRequestError('Произошла ошибка при отправке заявки: $e'));
    }
  }

  // ✅ ДОБАВЛЕНО: Функция для добавления вложения
  void _onAddAttachment(AddAttachment event, Emitter<MaterialRequestState> emit) {
    final currentState = state;
    if (currentState is MaterialRequestInitial) {
      final newAttachments = List<String>.from(currentState.attachments)..add(event.filePath);
      emit(currentState.copyWith(attachments: newAttachments));
    }
  }

  // ✅ ДОБАВЛЕНО: Функция для удаления вложения
  void _onRemoveAttachment(RemoveAttachment event, Emitter<MaterialRequestState> emit) {
    final currentState = state;
    if (currentState is MaterialRequestInitial) {
      final newAttachments = List<String>.from(currentState.attachments)..remove(event.filePath);
      emit(currentState.copyWith(attachments: newAttachments));
    }
  }

  // ✅ ДОБАВЛЕНО: Функция для сброса состояния
  void _onMaterialRequestReset(MaterialRequestReset event, Emitter<MaterialRequestState> emit) {
    emit(MaterialRequestInitial());
  }
}