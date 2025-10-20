import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:latlong2/latlong.dart';
import '../../data/repositories/routing_repository.dart';
import '../blocs/routing/routing_bloc.dart';

void showSearchModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const SearchModal(),
  );
}

class SearchModal extends StatefulWidget {
  const SearchModal({super.key});

  @override
  State<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal> {
  late RoutingBloc bloc;
  late RoutingRepository repository;
  final Map<String, TextEditingController> _viaControllers = {};

  late TextEditingController fromController;
  late TextEditingController toController;

  @override
  void initState() {
    super.initState();
    bloc = context.read<RoutingBloc>();
    repository = bloc.repository;

    // 💡 Инициализируем контроллеры из текущего состояния BLoC
    fromController = TextEditingController(text: bloc.state.fromField.text);
    toController = TextEditingController(text: bloc.state.toField.text);
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    _viaControllers.forEach((key, controller) => controller.dispose());
    _viaControllers.clear();
    super.dispose();
  }

  // 💡 Функция для получения контроллера для промежуточной точки
  TextEditingController _getViaController(RoutingField field) {
    return _viaControllers.putIfAbsent(
      field.id.toString(),
          () => TextEditingController(text: field.text),
    );
  }

  // 💡 Функция для очистки неиспользуемых контроллеров
  void _cleanupViaControllers(List<RoutingField> currentFields) {
    final ids = currentFields.map((f) => f.id.toString()).toSet();
    final toRemove = _viaControllers.keys.where((id) => !ids.contains(id)).toList();
    for (final id in toRemove) {
      _viaControllers[id]?.dispose();
      _viaControllers.remove(id);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoutingBloc, RoutingState>(
      // 💡 Слушаем сообщения от BLoC и показываем их пользователю
      listenWhen: (prev, curr) => prev.resultMessage != curr.resultMessage && curr.resultMessage.isNotEmpty,
      listener: (context, state) {
        _showSnack(state.resultMessage);
      },
      child: Padding(
        padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text('Поиск маршрута', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // 💡 Поле "Откуда"
              BlocBuilder<RoutingBloc, RoutingState>(
                buildWhen: (prev, curr) => prev.fromField != curr.fromField,
                builder: (context, state) {
                  final field = state.fromField;
                  if (fromController.text != field.text) {
                    fromController.text = field.text;
                    fromController.selection = TextSelection.collapsed(offset: fromController.text.length);
                  }
                  return Column(
                    children: [
                      TextField(
                        controller: fromController,
                        decoration: InputDecoration(
                          labelText: 'Откуда',
                          border: const OutlineInputBorder(),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.map),
                                tooltip: 'Выбрать на карте',
                                onPressed: () {
                                  Navigator.pop(context);
                                  bloc.add(const SelectFieldForMapTap(RoutingFieldType.from));
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.my_location),
                                tooltip: 'Моё местоположение',
                                onPressed: () {
                                  bloc.add(LoadUserLocation());
                                  Navigator.pop(context);
                                },
                              ),
                              if (fromController.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    fromController.clear();
                                    bloc.add(const UpdateFromField(''));
                                  },
                                ),
                            ],
                          ),
                        ),
                        onChanged: (value) => bloc.add(UpdateFromField(value)),
                      ),
                      buildSuggestionList(field.suggestions, (s) async {
                        fromController.text = s;
                        final coords = await repository.searchLocation(s);
                        if (coords != null) {
                          bloc.add(SetStartPoint(coords));
                        }
                        // 💡 Очищаем подсказки после выбора
                        bloc.add(UpdateFromField(s));
                      }),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),

              // 💡 Поле "Куда"
              BlocBuilder<RoutingBloc, RoutingState>(
                buildWhen: (prev, curr) => prev.toField != curr.toField,
                builder: (context, state) {
                  final field = state.toField;
                  if (toController.text != field.text) {
                    toController.text = field.text;
                    toController.selection = TextSelection.collapsed(offset: toController.text.length);
                  }
                  return Column(
                    children: [
                      TextField(
                        controller: toController,
                        decoration: InputDecoration(
                          labelText: 'Куда',
                          border: const OutlineInputBorder(),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.map),
                                tooltip: 'Выбрать на карте',
                                onPressed: () {
                                  Navigator.pop(context);
                                  bloc.add(const SelectFieldForMapTap(RoutingFieldType.to));
                                },
                              ),
                              if (toController.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    toController.clear();
                                    bloc.add(const UpdateToField(''));
                                  },
                                ),
                            ],
                          ),
                        ),
                        onChanged: (value) => bloc.add(UpdateToField(value)),
                      ),
                      buildSuggestionList(field.suggestions, (s) async {
                        toController.text = s;
                        final coords = await repository.searchLocation(s);
                        if (coords != null) {
                          bloc.add(SetEndPoint(coords));
                        }
                        // 💡 Очищаем подсказки после выбора
                        bloc.add(UpdateToField(s));
                      }),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),

              // 💡 Промежуточные точки
              BlocBuilder<RoutingBloc, RoutingState>(
                buildWhen: (prev, curr) => prev.viaFields != curr.viaFields,
                builder: (context, state) {
                  _cleanupViaControllers(state.viaFields);

                  return Column(
                    children: [
                      ...state.viaFields.map((field) {
                        final controller = _getViaController(field);
                        if (controller.text != field.text) {
                          controller.text = field.text;
                          controller.selection = TextSelection.collapsed(offset: controller.text.length);
                        }
                        return Column(
                          children: [
                            TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                labelText: 'Промежуточная точка',
                                border: const OutlineInputBorder(),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.map),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        bloc.add(SelectFieldForMapTap(RoutingFieldType.via, viaId: field.id));
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        bloc.add(RemoveViaField(field.id));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              onChanged: (v) => bloc.add(UpdateViaFieldText(field.id, v)),
                            ),
                            buildSuggestionList(field.suggestions, (s) async {
                              controller.text = s;
                              final coords = await repository.searchLocation(s);
                              if (coords != null) {
                                bloc.add(UpdateViaFieldCoords(field.id, coords));
                              }
                              // 💡 Очищаем подсказки после выбора
                              bloc.add(UpdateViaFieldText(field.id, s));
                            }),
                            const SizedBox(height: 10),
                          ],
                        );
                      }),

                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Добавить промежуточную точку'),
                        onPressed: () => bloc.add(AddViaField()),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                icon: const Icon(Icons.alt_route),
                label: const Text("Построить маршрут"),
                onPressed: () {
                  if (bloc.state.fromField.coords == null || bloc.state.toField.coords == null) {
                    _showSnack("⚠️ Укажите старт и финиш");
                    return;
                  }
                  bloc.add(const BuildRoute());
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 💡 Упрощённая функция для отображения подсказок
  Widget buildSuggestionList(List<String> suggestions, Function(String) onSelect) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    return ListView.builder(
      shrinkWrap: true,
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final s = suggestions[index];
        return ListTile(
          title: Text(s),
          onTap: () => onSelect(s),
        );
      },
    );
  }
}

