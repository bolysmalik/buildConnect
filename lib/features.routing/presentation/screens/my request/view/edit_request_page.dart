import 'package:flutter/material.dart';

class EditRequestPage extends StatefulWidget {
  final Map<String, dynamic> request;

  const EditRequestPage({Key? key, required this.request}) : super(key: key);

  @override
  State<EditRequestPage> createState() => _EditRequestPageState();
}

class _EditRequestPageState extends State<EditRequestPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;
  late TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.request['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.request['description'] ?? '');
    _budgetController = TextEditingController(text: widget.request['budget']?.toString() ?? '');
    _cityController = TextEditingController(text: widget.request['city'] ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _save() {
    final updatedRequest = Map<String, dynamic>.from(widget.request);
    updatedRequest['title'] = _titleController.text.trim();
    updatedRequest['description'] = _descriptionController.text.trim();
    updatedRequest['budget'] = num.tryParse(_budgetController.text.trim()) ?? 0;
    updatedRequest['city'] = _cityController.text.trim();
    Navigator.of(context).pop(updatedRequest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать заявку'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Заголовок',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _budgetController,
              decoration: const InputDecoration(
                labelText: 'Бюджет (₸)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Город',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
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
