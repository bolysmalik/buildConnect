import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../blocs/courier_request/courier_request_bloc.dart';
import '../../../blocs/courier_request/courier_request_event.dart';
import '../../../blocs/courier_request/courier_request_state.dart';
import '../../../utils/date_time_picker.dart';
import '../widgest/base_request_form.dart';
import '../widgest/form_fields.dart';
import '../widgest/media_section.dart';
import '../widgest/submit_button.dart';

class CourierRequestScreen extends StatelessWidget {
  const CourierRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CourierRequestBloc(),
      child: const _CourierRequestView(),
    );
  }
}

class _CourierRequestView extends StatefulWidget {
  const _CourierRequestView();

  @override
  State<_CourierRequestView> createState() => _CourierRequestViewState();
}

class _CourierRequestViewState extends State<_CourierRequestView> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pickupAddressController = TextEditingController();
  final _pickupDateController = TextEditingController();
  final _pickupTimeController = TextEditingController();
  final _goodsListController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _priceController = TextEditingController(); 

  final _formKey = GlobalKey<FormState>();

  bool _needsLoaders = false;
  String _city = 'Алматы';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pickupAddressController.dispose();
    _pickupDateController.dispose();
    _pickupTimeController.dispose();
    _goodsListController.dispose();
    _deliveryAddressController.dispose();
    _priceController.dispose(); 
    super.dispose();
  }

  void _submitRequest(List<String> attachments) {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final formatter = DateFormat('dd.MM.yyyy HH:mm:ss');
      final timestamp = formatter.format(now);

      final requestData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'city': _city,
        'pickup_address': _pickupAddressController.text,
        'pickup_date': _pickupDateController.text,
        'pickup_time': _pickupTimeController.text,
        'goods_list': _goodsListController.text,
        'delivery_address': _deliveryAddressController.text,
        'budget': _priceController.text, 
        'needs_loaders': _needsLoaders,
        'attachments': attachments,
        'timestamp': timestamp, 
      };

      context.read<CourierRequestBloc>().add(CourierRequestSubmitted(requestData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание заявки на услуги Курьера'),
      ),
      body: BlocConsumer<CourierRequestBloc, CourierRequestState>(
        listener: (context, state) {
          if (state is CourierRequestSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Заявка успешно отправлена!')),
            );

            // Очищаем форму после успешной отправки
            _titleController.clear();
            _descriptionController.clear();
            _pickupAddressController.clear();
            _pickupDateController.clear();
            _pickupTimeController.clear();
            _goodsListController.clear();
            _deliveryAddressController.clear();
            _priceController.clear();
            setState(() {
              _needsLoaders = false;
            });

            // Сбрасываем состояние BLoC для очистки вложений
            context.read<CourierRequestBloc>().add(const CourierRequestReset());
          } else if (state is CourierRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          final attachments = state is CourierRequestInitial ? state.attachments : <String>[];
            return BaseRequestForm(
              formKey: _formKey,
                children: [
                  Text('Город: $_city', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 20),

                  buildTextField(context: context, controller: _titleController, labelText: 'Название заявки',
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
                    controller: _goodsListController,
                    labelText: 'Вес товаров',
                    validator: (value) => value!.isEmpty ? 'Укажите вес товрав' : null,
                  ),
                  const SizedBox(height: 20),

                  buildTextField(
                    context: context,
                    controller: _deliveryAddressController,
                    labelText: 'Адрес доставки',
                    validator: (value) => value!.isEmpty ? 'Введите адрес доставки' : null,
                  ),
                  const SizedBox(height: 15),

                  // ✅ ИЗМЕНЕНО: Поле для "Предложите цену"
                  buildTextField(
                    context: context,
                    controller: _priceController,
                    labelText: 'Предложите цену',
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Введите цену' : null,
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Checkbox(
                        value: _needsLoaders,
                        onChanged: (bool? value) => setState(() => _needsLoaders = value ?? false),
                      ),
                      const Text('Требуются грузчики?'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  MediaSection(attachments: attachments),
                  const SizedBox(height: 30),
                  SubmitButton(
                    isLoading: state is CourierRequestLoading,
                    onPressed: () => _submitRequest(attachments)),
                ],
          );
        },
      ),
    );
  }
}
