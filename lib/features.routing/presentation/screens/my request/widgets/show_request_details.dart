import 'package:flutter/material.dart';
import 'package:flutter_valhalla/features/routing/presentation/utils/date_formatter.dart';

Future<void> showRequestDetails({
  required BuildContext context,
  required Map<String, dynamic> request,
  required Future<void> Function(Map<String, dynamic>) onDelete,
  required Future<void> Function(Map<String, dynamic>) onEdit,
}) async {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request['title'] ?? 'Детали заявки',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.blue),
                    tooltip: 'Удалить',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Удалить заявку?'),
                          content: const Text(
                            'Вы уверены, что хотите удалить эту заявку? Это действие необратимо.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Отмена'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text(
                                'Да, удалить',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        Navigator.pop(context);
                        await onDelete(request);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Редактировать',
                    onPressed: () async {
                      Navigator.pop(context);
                      await onEdit(request);
                    },
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (request['description'] != null) ...[
                Text(request['description']),
                const SizedBox(height: 16),
              ],
              if (request['type'] == 'material') ...[
                _buildDetailRow('Дата доставки:', request['delivery_date']),
                _buildDetailRow('Время доставки:', request['delivery_time']),
                _buildDetailRow('Список необходимых товаров:', request['material_list']),
                _buildDetailRow('Требуются грузчики:',
                    request['needs_loaders'] == true ? 'Да' : 'Нет'),
              ] else if (request['type'] == 'foreman') ...[
                _buildDetailRow('Дата начала:', request['pickup_date']),
                _buildDetailRow('Время начала:', request['pickup_time']),
              ] else if (request['type'] == 'courier') ...[
                _buildDetailRow('Адрес отправки:', request['pickup_address']),
                _buildDetailRow('Дата отправки:', request['pickup_date']),
                _buildDetailRow('Время отправки:', request['pickup_time']),
                const SizedBox(height: 8),
                _buildDetailRow('Адрес доставки:', request['delivery_address']),
                const SizedBox(height: 8),
                _buildDetailRow('Вес товаров:', request['goods_list']),
                _buildDetailRow(
                  'Грузчики:',
                  request['needs_loaders'] == true ? 'Да' : 'Нет',
                ),
              ],
              if (request['city'] != null)
                _buildDetailRow('Город:', request['city']),
              _buildDetailRow(
                'Создана:',
                formatDate(request['createdAt'] ?? ''),
              ),
              const SizedBox(height: 16),
              const Text(
                'Заказчик:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(request['customerName'] ?? 'Не указано'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(request['city'] ?? 'Не указано'),
                ],
              ),
              const SizedBox(height: 8),
              if (request['budget'] != null) ...[
                Row(
                  children: [
                    const Icon(Icons.wallet, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      '${request['budget']} ₸',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildDetailRow(String label, String? value) {
  if (value == null || value.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    ),
  );
}

