import 'package:flutter_valhalla/app.dart';

UserRole stringToUserRole(String role) {
  switch (role) {
    case 'customer':
      return UserRole.customer;
    case 'foreman':
      return UserRole.foreman;
    case 'supplier':
      return UserRole.supplier;
    case 'courier':
      return UserRole.courier;
    default:
      return UserRole.customer;
  }
}
