import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/core/theme/app_colors.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/authbloc/auth_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/authbloc/auth_event.dart';

class QuickLoginButtons extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController passwordController;

  const QuickLoginButtons({
    super.key,
    required this.phoneController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            '🧪 Quick Login (Development)',
            style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildQuickLoginButton(
              context,
              'Заказчик',
              Icons.person,
              AppColors.primary,
              '+77771234567',
              'test123',
            ),
            _buildQuickLoginButton(
              context,
              'Бригадир',
              Icons.handyman,
              AppColors.primary,
              '+77779876543',
              'test123',
            ),
            _buildQuickLoginButton(
              context,
              'Поставщик',
              Icons.store,
              AppColors.primary,
              '+77775555555',
              'test123',
            ),
            _buildQuickLoginButton(
              context,
              'Курьер',
              Icons.local_shipping,
              AppColors.primary,
              '+77778888888',
              'test123',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickLoginButton(
    BuildContext context,
    String role,
    IconData icon,
    Color color,
    String phone,
    String password,
  ) {
    return ElevatedButton(
      onPressed: () {
        phoneController.text = phone;
        passwordController.text = password;

        context.read<AuthBloc>().add(
          AuthLoginWithPhoneEvent(phone, password),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            role,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
