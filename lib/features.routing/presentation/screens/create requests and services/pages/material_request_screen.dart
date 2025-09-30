import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/create%20requests%20and%20services/widgest/base_request_form.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/create%20requests%20and%20services/widgest/form_fields.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/create%20requests%20and%20services/widgest/media_section.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/material_request/material_request_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/material_request/material_request_event.dart';
import 'package:flutter_valhalla/features/routing/presentation/blocs/material_request/material_request_state.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/create%20requests%20and%20services/widgest/submit_button.dart';
import 'package:flutter_valhalla/features/routing/presentation/utils/date_time_picker.dart';

class MaterialRequestScreen extends StatelessWidget {
  const MaterialRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MaterialRequestBloc(),
      child: const _MaterialRequestView(),
    );
  }
}

class _MaterialRequestView extends StatefulWidget {
  const _MaterialRequestView();

  @override
  State<_MaterialRequestView> createState() => _MaterialRequestViewState();
}

class _MaterialRequestViewState extends State<_MaterialRequestView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _deliveryAddressController = TextEditingController();
  final TextEditingController _deliveryDateController = TextEditingController();
  final TextEditingController _deliveryTimeController = TextEditingController();
  final TextEditingController _goodsListController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  List<String> _selectedCategories = [];
  final List<String> _availableCategories = [
    'Отделочные материалы',
    'Электрика',
    'Сантехника',
    'Инструменты',
    'Металлопрокат',
    'Другое',
  ];

  bool _needsLoaders = false;
  String _city = 'Алматы';

  @override
  void dispose() {
    _titleController.dispose();
    _deliveryAddressController.dispose();
    _deliveryDateController.dispose();
    _deliveryTimeController.dispose();
    _goodsListController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _submitRequest(List<String> attachments) {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final timestamp = '${now.day}.${now.month}.${now.year} ${now.hour}:${now.minute}:${now.second}';

      final requestData = {
        'title': _titleController.text,
        'city': _city,
        'delivery_address': _deliveryAddressController.text,
        'delivery_date': _deliveryDateController.text,
        'delivery_time': _deliveryTimeController.text,
        'material_list': _goodsListController.text,
        'budget': _budgetController.text,
        'selected_categories': _selectedCategories,
        'needs_loaders': _needsLoaders,
        'attachments': attachments,
        'created_at': timestamp,
      };

      context.read<MaterialRequestBloc>().add(MaterialRequestSubmitted(requestData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание заявки на материалы'),
      ),
      body: BlocConsumer<MaterialRequestBloc, MaterialRequestState>(
        listener: (context, state) {
          if (state is MaterialRequestSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Заявка на материалы отправлена!')),
            );

            _titleController.clear();
            _deliveryAddressController.clear();
            _deliveryDateController.clear();
            _deliveryTimeController.clear();
            _goodsListController.clear();
            _budgetController.clear();

            setState(() {
              _selectedCategories.clear();
              _needsLoaders = false;
            });

            context.read<MaterialRequestBloc>().add(const MaterialRequestReset());
          } else if (state is MaterialRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          final attachments = state is MaterialRequestInitial ? state.attachments : <String>[];

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
                    controller: _deliveryAddressController,
                    labelText: 'Адрес доставки',
                    validator: (value) => value!.isEmpty ? 'Введите адрес доставки' : null,
                  ),
                  const SizedBox(height: 15),
                  buildDateField(context, _deliveryDateController, 'Дата доставки', selectDate),
                  const SizedBox(height: 15),
                  buildTimeField(context, _deliveryTimeController, 'Время доставки', selectTime),
                  const SizedBox(height: 15),

                  buildTextField(
                    context: context,
                    controller: _goodsListController,
                    labelText: 'Список необходимых материалов',
                    maxLines: 5,
                    validator: (value) => value!.isEmpty ? 'Введите список материалов' : null,
                  ),
                  const SizedBox(height: 15),

                  buildTextField(
                    context: context,
                    controller: _budgetController,
                    labelText: 'Укажите бюджет',
                    validator: (value) => value!.isEmpty ? 'Введите цену' : null,
                  ),
                  const SizedBox(height: 20),

                  const Text('Категории товаров:', style: TextStyle(fontSize: 16)),
                  Wrap(
                    spacing: 8.0,
                    children: _availableCategories.map((category) {
                      return FilterChip(
                        label: Text(category),
                        selected: _selectedCategories.contains(category),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategories.add(category);
                            } else {
                              _selectedCategories.remove(category);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

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
                    isLoading: state is MaterialRequestLoading,
                    onPressed: () => _submitRequest(attachments),
                  ),
                ],
          );
        },
      ),
    );
  }
}
