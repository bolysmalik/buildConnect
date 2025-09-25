import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/app.dart';
import 'package:flutter_valhalla/core/utils/registration_role_extension.dart';
import 'package:flutter_valhalla/core/utils/user_role_extension.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/authbloc/auth_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/authbloc/auth_event.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/login/view/login_page.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/registration/view/registration_page.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/home_page/view/home_page.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/map/routing_map_screen.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/product%20finder/pages/product_finder_screen.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/profile/view/profile_page.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/my%20request/view/my_request_page.dart';
import 'package:flutter_valhalla/core/theme/app_colors.dart';
import 'package:flutter_valhalla/core/mock/mock_auth_service.dart';
import 'package:flutter_valhalla/core/mock/mock_services.dart';

class AppDrawer extends StatelessWidget {
  final UserRole userRole;
  const AppDrawer({super.key, required this.userRole});

  static const Map<RegistrationRole, String> roles = {
    RegistrationRole.customer: 'Заказчик',
    RegistrationRole.foreman: 'Бригадир',
    RegistrationRole.supplier: 'Поставщик',
    RegistrationRole.courier: 'Курьер',
  };

  @override
  Widget build(BuildContext context) {
    final authService = MockAuthService();
    final currentUser =
        authService.getUserByActiveRole() ?? authService.currentUser;
    final fullName = currentUser?['name'] ?? 'Пользователь';
    final userName = fullName.split(' ').first;
    final rating = (4.2 + (DateTime.now().millisecondsSinceEpoch % 8) / 10)
        .toStringAsFixed(1);
    // 🔹 Берём активную роль
    // 🔹 Берём роль приоритетно из userRole, если нет — из authService
    final activeRole = userRole != UserRole.unauthorized
        ? userRole
        : authService.getActiveRole()?.toUserRole();

    // 🔹 Определяем отображаемое название
    final displayedRole = activeRole != null
        ? roles[activeRole.toRegistrationRole()] ?? activeRole.name
        : 'Неизвестно';

    return Drawer(
      child: Column(
        children: [
          // 🔹 Заголовок
          Container(
            constraints: const BoxConstraints(minHeight: 120, maxHeight: 160),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkIconSecondary
                      : Colors.grey,
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  if (userRole == UserRole.unauthorized) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AccountPage()),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProfilePage(newRole: userRole),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      // аватарка
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // инфо
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    userName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.darkIconSecondary
                                      : AppColors.iconSecondary,
                                  size: 16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  rating,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      displayedRole,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🔹 Основные пункты
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.search,
                  title: 'Поиск продукта',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProductFinderPage(),
                      ),
                    );
                  },
                ),

                // 🔹 Выбор роли
                ExpansionTile(
                  leading: Icon(
                    Icons.work_outline,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkIconPrimary
                        : AppColors.iconPrimary,
                  ),
                  title: Text(
                    "Выбор роли",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  children: roles.entries.map((entry) {
                    final role = entry.key;
                    final title = entry.value;
                    final isSelected = activeRole == role.toUserRole();

                    return ListTile(
                      title: Text(title),
                      trailing: isSelected
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).primaryColor,
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        final hasRegistered = authService.hasRole(role);

                        if (hasRegistered) {
                          // 🔹 Смена роли через BLoC
                          BlocProvider.of<AuthBloc>(
                            context,
                          ).add(AuthRoleChangedEvent(role));

                          // 🔹 Переход на HomePage с новой ролью
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  HomePage(userRole: role.toUserRole()),
                            ),
                          );
                        } else {
                          // 🔹 сначала регистрация
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  RegistrationPage(initialRole: role),
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                ),

                Divider(color: Colors.grey.withOpacity(0.7), thickness: 0.5),
                ..._buildRoleSpecificDrawerItems(context),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.map,
                  title: 'Карта',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => RoutingMapScreen(userRole: userRole),
                      ),
                      (route) => false,
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.settings,
                  title: 'Настройки',
                  onTap: () {
                  
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Drawer item
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkIconPrimary
            : AppColors.iconPrimary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkTextPrimary
              : AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
      hoverColor: AppColors.primaryLight.withOpacity(0.1),
      focusColor: AppColors.primaryLight.withOpacity(0.1),
    );
  }

  List<Widget> _buildRoleSpecificDrawerItems(BuildContext context) {
    List<Widget> items = [];

    switch (userRole) {
      case UserRole.customer:
        items.add(
          _buildDrawerItem(
            context: context,
            icon: Icons.assignment,
            title: 'Мои заявки',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MyRequestPage()),
              );
            },
          ),
        );
        break;
      case UserRole.unauthorized:
      case UserRole.foreman:
      case UserRole.supplier:
      case UserRole.courier:
        items.addAll([]);
        break;
    }

    return items;
  }
}
