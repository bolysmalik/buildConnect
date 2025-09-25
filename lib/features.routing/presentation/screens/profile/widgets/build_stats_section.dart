import 'package:flutter/material.dart';
import 'package:flutter_valhalla/core/theme/app_colors.dart';

Widget buildStatsSection(String role, int Function(String, String) getRandomStat) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Статистика',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Заявки',
                  '${getRandomStat(role, 'requests')}',
                  Icons.assignment,
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Чаты',
                  '${getRandomStat(role, 'chats')}',
                  Icons.chat,
                  AppColors.info,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Рейтинг',
                  '${getRandomStat(role, 'rating')}/5',
                  Icons.star,
                  AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildStatItem(String label, String value, IconData icon, Color color) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      const SizedBox(height: 8),
      Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
    ],
  );
}


int getRandomStat(String role, String type) {
  switch (type) {
    case 'requests':
      return role == 'customer' ? 12 : 8;
    case 'chats':
      return 5;
    case 'rating':
      return 4;
    default:
      return 0;
  }
}