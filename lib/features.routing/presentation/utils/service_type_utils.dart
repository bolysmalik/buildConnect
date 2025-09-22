import 'package:flutter/material.dart';

Map<String, dynamic> getServiceDetails(String type) {
  switch (type.toLowerCase()) {
    case 'material':
      return {
        'icon': Icons.inventory,
        'color': Colors.blue,
        'name': 'Материалы',
      };
    case 'foreman':
      return {
        'icon': Icons.handyman,
        'color': Colors.orange,
        'name': 'Бригадиры',
      };
    case 'courier':
      return {
        'icon': Icons.local_shipping,
        'color': Colors.purple,
        'name': 'Доставка',
      };
    default:
      return {
        'icon': Icons.assignment,
        'color': Colors.grey,
        'name': 'Услуга',
      };
  }
}
