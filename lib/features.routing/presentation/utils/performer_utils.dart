import 'package:flutter/material.dart';
import 'package:flutter_valhalla/app.dart';

/// Возвращает цвет для типа исполнителя
Color getPerformerColor(String type) {
  switch (type) {
    case 'material':
    case 'supplier':
      return Colors.blue;
    case 'foreman':
      return Colors.orange;
    case 'courier':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

/// Возвращает иконку для типа исполнителя
IconData getPerformerIcon(String type) {
  switch (type) {
    case 'material':
    case 'supplier':
      return Icons.store;
    case 'foreman':
      return Icons.construction;
    case 'courier':
      return Icons.local_shipping;
    default:
      return Icons.person;
  }
}

String getPerformerTypeName(String type) {
    switch (type) {
      case 'supplier':
      case 'material':
        return 'Поставщик';
      case 'foreman':
        return 'Бригадир';
      case 'courier':
        return 'Курьер';
      default:
        return 'Исполнитель';
    }
  }

IconData getRoleIcon(String role) {
    switch (role) {
      case 'customer':
        return Icons.person;
      case 'foreman':
        return Icons.handyman;
      case 'supplier':
        return Icons.store;
      case 'courier':
        return Icons.local_shipping;
      default:
        return Icons.person;
    }
  }

String getRoleDisplayName(String role) {
    switch (role) {
      case 'customer':
        return 'Заказчик';
      case 'foreman':
        return 'Бригадир';
      case 'supplier':
        return 'Поставщик';
      case 'courier':
        return 'Курьер';
      default:
        return 'Пользователь';
    }
  }

String getRequestTypeForRole(UserRole role) {
  switch (role) {
    case UserRole.foreman:
      return 'foreman';
    case UserRole.supplier:
      return 'material';
    case UserRole.courier:
      return 'courier';
    default:
      return '';
  }
}