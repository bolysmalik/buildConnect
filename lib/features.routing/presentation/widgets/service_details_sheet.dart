import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/mock/mock_database.dart';

class ServiceDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback? onContact;
  final bool showContactButton;
  final bool showEditButton;
  final VoidCallback? onEdit;
  final Future<void> Function()? onDelete;

  const ServiceDetailsSheet({
    Key? key,
    required this.service,
    this.onContact,
    this.showContactButton = true,
    this.showEditButton = false,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);
  

  Future<void> _deleteService(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить услугу?'),
        content: const Text('Вы уверены, что хотите удалить эту услугу? Это действие необратимо.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Да, удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      Navigator.pop(context);
      final serviceId = service['id'];
      final removed = MockDatabase().removeService(serviceId);
      if (removed > 0) {
        if (onDelete != null) await onDelete!(); // обновить родительский экран
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Услуга удалена'), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при удалении услуги'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Заголовок
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    service['title'] ?? 'Услуга',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (showEditButton)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.blue),
                  tooltip: 'Удалить',
                  onPressed: () => _deleteService(context),
                ),
                if (showEditButton)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Редактировать',
                    onPressed: () {
                      Navigator.pop(context);
                      if(onEdit != null) onEdit!();
                    },
                  ),
                  
                  IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Контент услуги
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Описание
                  if (service['description'] != null) ...[
                    Text(
                      service['description'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Цена


                  // Информация об исполнителе
                  const Text(
                    'Исполнитель:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(service['providerName'] ?? 'Не указано'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(service['city'] ?? 'Не указано'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text('Рейтинг: ${service['rating'] ?? 'Нет оценок'}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (service['budget'] != null) ...[
                    Row(
                      children: [

                        Icon(Icons.wallet, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          '${service['budget']} ₸',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Кнопка связаться
          if (showContactButton) 
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16), 
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onContact?.call();
              },
              icon: const Icon(Icons.chat),
              label: const Text(
                'Связаться с исполнителем',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}