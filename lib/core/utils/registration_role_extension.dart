import 'package:flutter_valhalla/app.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/registration/view/registration_page.dart';

extension RegistrationRoleX on RegistrationRole {
  UserRole toUserRole() {
    switch (this) {
      case RegistrationRole.customer:
        return UserRole.customer;
      case RegistrationRole.foreman:
        return UserRole.foreman;
      case RegistrationRole.supplier:
        return UserRole.supplier;
      case RegistrationRole.courier:
        return UserRole.courier;
    }
  }
}
