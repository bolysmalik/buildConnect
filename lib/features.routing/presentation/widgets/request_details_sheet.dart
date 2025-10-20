

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RequestDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> request;
  final Function(Map<String, dynamic>) onOpenChat;
  final Function(Map<String, dynamic>)? onRespond;

  const RequestDetailsSheet( {
    required this.request,
    required this.onOpenChat,
    this.onRespond,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок

          Row(
            children: [
              Expanded(
                child: Text(
                  request['title'] ?? 'Заявка',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 8),

          //
          if (request['description'] != null) ...[
            Text(
              request['description'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
          ],

          // Цена


          // Детали в зависимости от типа заявки
          if (request['type'] == 'material') ...[
            _buildDetailRow(
              'Список необходимых товаров:',
              request['material_list'],
            ),
            _buildDetailRow('Дата доставки:', request['delivery_date']),
            _buildDetailRow('Время доставки:', request['delivery_time']),
            _buildDetailRow(
              'Требуются грузчики:',
              request['needs_loaders'] == true ? 'Да' : 'Нет',
            ),
          ] else if (request['type'] == 'foreman') ...[
            //_buildDetailRow('Название заявки:', request['title']),
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

          const SizedBox(height: 16),

          // Информация о заказчике
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
                //const SizedBox(width: 8),
                Icon(Icons.wallet, color: Colors.green),
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
            
            
            const SizedBox(height: 16),
          ],
          
          //const SizedBox(height: 20),
          // Отступ для безопасной зоны
          SizedBox(height: MediaQuery.of(context).padding.bottom),
          
        ],
      ),
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
}
