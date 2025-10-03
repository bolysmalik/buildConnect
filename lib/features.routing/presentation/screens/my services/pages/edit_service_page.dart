import 'package:flutter/material.dart';

class EditServicePage extends StatefulWidget {
  final Map<String, dynamic> service;
  final void Function(Map<String, dynamic> updatedService) onSave;

  const EditServicePage({super.key, required this.service, required this.onSave});

  @override
  State<EditServicePage> createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.service['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.service['description'] ?? '');
    _locationController = TextEditingController(text: widget.service['service_location'] ?? '');
    _priceController = TextEditingController(text: widget.service['budget']?.toString() ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _save() {
    final updated = Map<String, dynamic>.from(widget.service);
    updated['title'] = _titleController.text;
    updated['description'] = _descriptionController.text;
    updated['service_location'] = _locationController.text;
    updated['budget'] = _priceController.text;
    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать услугу')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Описание'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Локация'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Стоимость (₸)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
