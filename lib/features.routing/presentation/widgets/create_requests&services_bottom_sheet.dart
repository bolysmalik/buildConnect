import 'package:flutter/material.dart';
import 'package:flutter_valhalla/app.dart';
import 'package:flutter_valhalla/core/theme/app_colors.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/create%20requests%20and%20services/pages/material_request_screen.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/create%20requests%20and%20services/pages/foreman_request_screen.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/create%20requests%20and%20services/pages/courier_request_screen.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/create%20requests%20and%20services/pages/service_posting_screen.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/login/view/login_page.dart';

/// 🔹 Показывает нижнее меню создания заявок/услуг
void showCreateMenu(BuildContext context, UserRole userRole) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Создать',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ..._buildCreateMenuOptions(context, userRole),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

/// 🔹 Возвращает список доступных пунктов в меню создания
List<Widget> _buildCreateMenuOptions(BuildContext context, UserRole userRole) {
  switch (userRole) {
    case UserRole.customer:
      return [
        _buildCreateOption(
          context,
          icon: Icons.shopping_bag,
          title: 'Купить строительные материалы',
          subtitle: 'Найти поставщиков материалов',
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => MaterialRequestScreen()),
            );
          },
        ),
        _buildCreateOption(
          context,
          icon: Icons.handyman,
          title: 'Заказать услуги бригадира',
          subtitle: 'Найти квалифицированного бригадира',
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ForemanRequestScreen()),
            );
          },
        ),
        _buildCreateOption(
          context,
          icon: Icons.local_shipping,
          title: 'Заказать услуги курьера',
          subtitle: 'Доставка материалов и грузов',
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => CourierRequestScreen()),
            );
          },
        ),
      ];

    case UserRole.foreman:
    case UserRole.supplier:
    case UserRole.courier:
      return [
        _buildCreateOption(
          context,
          icon: Icons.work,
          title: 'Создать предложение услуг',
          subtitle: 'Разместить свои услуги',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ServicePostingScreen()),
            );
          },
        ),
      ];

    case UserRole.unauthorized:
      return [
        _buildCreateOption(
          context,
          icon: Icons.login,
          title: 'Войдите, чтобы создать заявку',
          subtitle: 'Авторизуйтесь, чтобы продолжить',
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AccountPage()),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Для создания заявки необходимо войти в аккаунт.'),
              ),
            );
          },
        ),
      ];
  }
}

/// 🔹 Вспомогательный виджет для пункта меню
Widget _buildCreateOption(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    leading: Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Icon(icon, color: AppColors.primary, size: 24),
    ),
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
    ),
    subtitle: Text(
      subtitle,
      style: TextStyle(color: Colors.grey[600], fontSize: 14),
    ),
    onTap: onTap,
  );
}
