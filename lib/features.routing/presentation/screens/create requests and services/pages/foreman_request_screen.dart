import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/create%20requests%20and%20services/widgest/base_request_form.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/create%20requests%20and%20services/widgest/form_fields.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/create%20requests%20and%20services/widgest/media_section.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/foreman_request/foreman_request_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/foreman_request/foreman_request_event.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/foreman_request/foreman_request_state.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/create%20requests%20and%20services/widgest/submit_button.dart';
import 'package:flutter_valhalla/features/routing/presentation/utils/date_time_picker.dart';

class ForemanRequestScreen extends StatelessWidget {
  const ForemanRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForemanRequestBloc(),
      child: const _ForemanRequestView(),
    );
  }
}

class _ForemanRequestView extends StatefulWidget {
  const _ForemanRequestView();

  @override
  State<_ForemanRequestView> createState() => _ForemanRequestViewState();
}

class _ForemanRequestViewState extends State<_ForemanRequestView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pickupAddressController = TextEditingController();
  final _pickupDateController = TextEditingController();
  final _pickupTimeController = TextEditingController();
  final _budgetController = TextEditingController();

  String _city = 'Алматы';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pickupAddressController.dispose();
    _pickupDateController.dispose();
    _pickupTimeController.dispose();
    _budgetController.dispose();
    super.dispose();
  }


  void _submitRequest(List<String> attachments) {
    if (_formKey.currentState!.validate()) {
      final requestData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'city': _city,
        'pickup_address': _pickupAddressController.text,
        'pickup_date': _pickupDateController.text,
        'pickup_time': _pickupTimeController.text,
        'budget': _budgetController.text,
        'attachments': attachments,
        // ✅ Добавляем время создания заявки
        'createdAt': DateTime.now().toIso8601String(),
      };

      context.read<ForemanRequestBloc>().add(ForemanRequestSubmitted(requestData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание заявки на услуги Бригадира'),
      ),
      body: BlocConsumer<ForemanRequestBloc, ForemanRequestState>(
        listener: (context, state) {
          if (state is ForemanRequestSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Заявка успешно отправлена!')),
            );

            // Очищаем форму после успешной отправки
            _titleController.clear();
            _descriptionController.clear();
            _pickupAddressController.clear();
            _pickupDateController.clear();
            _pickupTimeController.clear();
            _budgetController.clear();

            // Сбрасываем состояние BLoC для очистки вложений
            context.read<ForemanRequestBloc>().add(const ForemanRequestReset());
          } else if (state is ForemanRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          final attachments = state is ForemanRequestInitial ? state.attachments : <String>[];
          return BaseRequestForm(
              formKey: _formKey,
                children: [
                  Text('Город: $_city', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 20),
                  buildTextField(
                    context: context,
                    controller: _titleController,
                    labelText: 'Название заявки',
                    validator: (value) => value!.isEmpty ? 'Введите название заявки' : null,
                  ),
                  const SizedBox(height: 15),
                  buildTextField(
                    context: context,
                    controller: _descriptionController,
                    labelText: 'Описание',
                    maxLines: 3,
                    validator: (value) => value!.isEmpty ? 'Введите описание заявки' : null,
                  ),
                  const SizedBox(height: 15),
                  buildTextField(
                    context: context,
                    controller: _pickupAddressController,
                    labelText: 'Адрес получения',
                    validator: (value) => value!.isEmpty ? 'Введите адрес получения' : null,
                  ),
                  const SizedBox(height: 15),
                  buildDateField(context, _pickupDateController, 'Дата получения', selectDate),
                  const SizedBox(height: 15),
                  buildTimeField(context, _pickupTimeController, 'Время получения', selectTime),
                  const SizedBox(height: 15),
                  buildTextField(
                    context: context,
                    controller: _budgetController,
                    labelText: 'Укажите бюджет',
                    validator: (value) => value!.isEmpty ? 'Свою цену' : null,
                  ),
                  const SizedBox(height: 15),

                  MediaSection(attachments: attachments),
                  const SizedBox(height: 30),
                  SubmitButton(
                    isLoading: state is ForemanRequestLoading,
                    onPressed: () => _submitRequest(attachments),
                  ),
                ],
          );
        },
      ),
    );
  }
}
