import 'package:flutter/material.dart';
import 'package:flutter_valhalla/features/routing/presentation/utils/date_formatter.dart';
import '../../../../app.dart';
import '../../../../core/theme/app_colors.dart';

typedef RequestCallback = dynamic Function(Map<String, dynamic>);

class RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final UserRole userRole;
  final RequestCallback onDetails;
  final RequestCallback? onRespond;

  /// 🔹 параметры управления отображением
  final bool showRespondButton;
  final bool showStatus;
  final bool showBudgetAlways;

  const RequestCard({
    super.key,
    required this.request,
    required this.userRole,
    required this.onDetails,
    this.onRespond,
    this.showRespondButton = true,
    this.showStatus = false,
    this.showBudgetAlways = false,
  });

  @override
  Widget build(BuildContext context) {
    
    // ✅ теперь проверяем оба ключа
    final rawType = request['type'] ?? request['requestType'] ?? '';

    // если пусто — попробуем определить по роли
    final type = switch (rawType) {
      'foreman' => 'foreman',
      'supplier' || 'material' => 'material',
      'courier' => 'courier',
      _ => switch (userRole) {
          UserRole.foreman => 'foreman',
          UserRole.supplier => 'material',
          UserRole.courier => 'courier',
          _ => 'unknown',
        }
    };
    IconData icon;
    Color color;
    String typeName;

    switch (type) {
      case 'foreman':
        icon = Icons.handyman;
        color = Colors.orange;
        typeName = 'Бригадир';
        break;
      case 'supplier':
      case 'material':
        icon = Icons.inventory_2;
        color = Colors.blue;
        typeName = 'Материалы';
        break;
      case 'courier':
        icon = Icons.local_shipping;
        color = Colors.green;
        typeName = 'Доставка';
        break;
      default:
        icon = Icons.work;
        color = Colors.grey;
        typeName = 'Заявка';
    }

    final responded = request['responded'] == true;
    final isUnauthorized = userRole == UserRole.unauthorized;

    /// 🔹 статус берём из моков (активна / принята / отклонена)
    final status = (request['status'] ?? request['myResponseStatus'] ?? 'active').toString();

    final statusText = switch (status) {
      'accepted' => 'ПРИНЯТА',
      'rejected' => 'ОТКЛОНЕНА',
      _ => 'АКТИВНА',
    };

    final statusColor = switch (status) {
      'accepted' => Colors.green,
      'rejected' => Colors.red,
      _ => Colors.orange,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onDetails(request),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Заголовок с типом заявки
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request['title'] ?? 'Заявка без названия',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          typeName,
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// 🔹 статус — как было раньше
                  if (showStatus)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10,
                          color: statusColor.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  /// 🔹 бюджет
                  if (request['budget'] != null && (showBudgetAlways || !showStatus))
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        '${request['budget']} ₸',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              /// 🔹 описание
              if (request['description'] != null)
                Text(
                  request['description'],
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 12),

              /// 🔹 детали заявки
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(Icons.person, request['customerName'] ?? 'Неизвестный'),
                  ),
                  Expanded(
                    child: _buildDetailItem(Icons.location_on, request['city'] ?? 'Не указан'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      Icons.access_time,
                      formatDate(request['createdAt'] ?? ''),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// 🔹 кнопки
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onDetails(request),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Подробнее'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  if (showRespondButton) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isUnauthorized
                            ? () => onRespond?.call(request)
                            : responded
                                ? null
                                : () {
                                    onRespond?.call(request);
                                    request['responded'] = true;
                                  },
                        icon: const Icon(Icons.send, size: 16),
                        label: Text(
                          isUnauthorized
                              ? 'Откликнуться'
                              : responded
                                  ? 'Отклик отправлен'
                                  : 'Откликнуться',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isUnauthorized
                              ? AppColors.primary
                              : responded
                                  ? Colors.grey
                                  : color,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
}
