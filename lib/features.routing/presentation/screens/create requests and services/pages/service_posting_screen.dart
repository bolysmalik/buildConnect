import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/create%20requests%20and%20services/widgest/base_request_form.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/create%20requests%20and%20services/widgest/form_fields.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/create%20requests%20and%20services/widgest/media_section.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/service_posting/service_posting_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/service_posting/service_posting_event.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/service_posting/service_posting_state.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/authbloc/auth_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/authbloc/auth_state.dart';

class ServicePostingScreen extends StatelessWidget {
  const ServicePostingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServicePostingBloc(),
      child: const _ServicePostingView(),
    );
  }
}

class _ServicePostingView extends StatefulWidget {
  const _ServicePostingView();

  @override
  State<_ServicePostingView> createState() => _ServicePostingViewState();
}

class _ServicePostingViewState extends State<_ServicePostingView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _serviceTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _serviceLocationController = TextEditingController();
  final _priceController = TextEditingController();

  final _city = 'Алматы';

  @override
  void dispose() {
    _titleController.dispose();
    _serviceTypeController.dispose();
    _descriptionController.dispose();
    _serviceLocationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submitService() {
    if (_formKey.currentState!.validate()) {
      final attachments = (context.read<ServicePostingBloc>().state as ServicePostingInitial).attachments;

      final authState = context.read<AuthBloc>().state;

      if (authState is AuthAuthenticated) {
        final userRole = authState.userRole;
        final userId = authState.userId;

        final serviceData = {
          'title': _titleController.text,
          'service_type': _serviceTypeController.text,
          'description': _descriptionController.text,
          'city': _city,
          'service_location': _serviceLocationController.text,
          'budget': _priceController.text,
          'attachments': attachments,
          'userRole': userRole,
          'customerId': userId, 
          'createdAt': DateTime.now().toIso8601String(),
        };

        context.read<ServicePostingBloc>().add(
            ServicePostingSubmitted(serviceData));
      }else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка: Не удалось получить данные пользователя. Вы не авторизованы.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Разместить свою услугу'),
      ),
      body: BlocConsumer<ServicePostingBloc, ServicePostingState>(
        listener: (context, state) {
          if (state is ServicePostingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ваша услуга успешно опубликована!')),
            );
            _titleController.clear();
            _serviceTypeController.clear();
            _descriptionController.clear();
            _serviceLocationController.clear();
            _priceController.clear();
            context.read<ServicePostingBloc>().add(const ServicePostingReset());
          } else if (state is ServicePostingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          final attachments = state is ServicePostingInitial ? state.attachments : <String>[];
          final isLoading = state is ServicePostingLoading;

          return BaseRequestForm(
              formKey: _formKey,
                children: [
                  Text('Город: $_city', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 20),
                  buildTextField(
                    context: context,
                    controller: _titleController,
                    labelText: 'Название услуги',
                    validator: (value) => value!.isEmpty ? 'Введите название услуги' : null,
                  ),
                  const SizedBox(height: 15),
                  buildTextField(
                    context: context,
                    controller: _serviceTypeController,
                    labelText: 'Тип услуги (например, Сантехнические работы)',
                    validator: (value) => value!.isEmpty ? 'Введите тип услуги' : null,
                  ),
                  const SizedBox(height: 15),
                  buildTextField(
                    context: context,
                    controller: _descriptionController,
                    labelText: 'Описание',
                    maxLines: 5,
                    validator: (value) => value!.isEmpty ? 'Введите описание услуги' : null,
                  ),
                  const SizedBox(height: 15),
                  buildTextField(
                    context: context,
                    controller: _serviceLocationController,
                    labelText: 'Место оказания услуг',
                    validator: (value) => value!.isEmpty ? 'Введите место оказания услуг' : null,
                  ),
                  const SizedBox(height: 15),
                  buildTextField(
                    context: context,
                    controller: _priceController,
                    labelText: 'Укажите стоимость (₸)',
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Укажите стоимость' : null,
                  ),
                  const SizedBox(height: 15),
                  MediaSection(attachments: attachments),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitService,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Опубликовать услугу',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
          );
        },
      ),
    );
  }
}
