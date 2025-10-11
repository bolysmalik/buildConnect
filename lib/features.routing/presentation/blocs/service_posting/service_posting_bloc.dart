import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/service_posting/service_posting_event.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/service_posting/service_posting_state.dart';
import 'package:flutter_valhalla/core/mock/mock_service_manager.dart';

class ServicePostingBloc extends Bloc<ServicePostingEvent, ServicePostingState> {
  final MockServiceManager _serviceManager = MockServiceManager();

  ServicePostingBloc() : super(const ServicePostingInitial()) {
    on<ServicePostingSubmitted>(_onServicePostingSubmitted);
    on<AddAttachment>(_onAddAttachment);
    on<RemoveAttachment>(_onRemoveAttachment);
    on<ServicePostingReset>(_onReset);
  }

  Future<void> _onServicePostingSubmitted(
      ServicePostingSubmitted event,
      Emitter<ServicePostingState> emit,
      ) async {
    emit(ServicePostingLoading());
    try {
      await _serviceManager.initialize();
      final currentUser = _serviceManager.auth.currentUser;
      if (currentUser == null) {
        emit(const ServicePostingError(message: 'Пользователь не авторизован'));
        return;
      }

      final serviceData = Map<String, dynamic>.from(event.serviceData);
      serviceData['providerId'] = currentUser['id'];

      final String serviceId = _serviceManager.db.addService(serviceData);

      if (serviceId.isNotEmpty) {
        _serviceManager.notifyNewRequest('service');
        emit(ServicePostingSuccess());
      } else {
        emit(const ServicePostingError(message: 'Неизвестная ошибка при публикации услуги.'));
      }

    } catch (e) {
      emit(ServicePostingError(message: e.toString()));
    }
  }

  void _onAddAttachment(
      AddAttachment event,
      Emitter<ServicePostingState> emit,
      ) {
    if (state is ServicePostingInitial) {
      final currentState = state as ServicePostingInitial;
      final newAttachments = List<String>.from(currentState.attachments)..add(event.filePath);
      emit(ServicePostingInitial(attachments: newAttachments));
    }
  }

  void _onRemoveAttachment(
      RemoveAttachment event,
      Emitter<ServicePostingState> emit,
      ) {
    if (state is ServicePostingInitial) {
      final currentState = state as ServicePostingInitial;
      final newAttachments = List<String>.from(currentState.attachments)
        ..remove(event.filePath);
      emit(ServicePostingInitial(attachments: newAttachments));
    }
  }

  void _onReset(
      ServicePostingReset event,
      Emitter<ServicePostingState> emit,
      ) {
    emit(const ServicePostingInitial());
  }
}