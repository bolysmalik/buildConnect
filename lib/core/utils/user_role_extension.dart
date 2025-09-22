import 'package:flutter_valhalla/app.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/registration/view/registration_page.dart';

extension UserRoleX on UserRole {
  RegistrationRole toRegistrationRole() {
    switch (this) {
      case UserRole.customer:
        return RegistrationRole.customer;
      case UserRole.foreman:
        return RegistrationRole.foreman;
      case UserRole.supplier:
        return RegistrationRole.supplier;
      case UserRole.courier:
        return RegistrationRole.courier;
      case UserRole.unauthorized:
        throw UnimplementedError('Role unauthorized not supported');
    }
  }
}
