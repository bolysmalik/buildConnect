import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/app.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/authbloc/auth_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/authbloc/auth_state.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/authbloc/auth_event.dart';
import 'package:flutter_valhalla/core/theme/app_colors.dart';
import 'package:flutter_valhalla/core/mock/mock_services.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/login/view/login_page.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/profile/widgets/build_stats_section.dart';
import 'package:flutter_valhalla/features/routing/presentation/utils/performer_utils.dart'; // ✅ Добавлен импорт

class ProfilePage extends StatefulWidget {
  final UserRole? newRole;
  const ProfilePage({super.key, this.newRole});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final MockServiceManager _serviceManager = MockServiceManager();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      await _serviceManager.initialize();
      final currentUser = _serviceManager.auth.currentUser;
      
      if (currentUser != null) {
        setState(() {
          _userProfile = currentUser;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Ошибка загрузки профиля: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Показываем уведомление об успешном выходе
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Вы успешно вышли из аккаунта'),
              backgroundColor: AppColors.success,
            ),
          );
          
          // Возвращаемся на страницу входа
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AccountPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Мой профиль'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 1,
          iconTheme: const IconThemeData(color: AppColors.iconPrimary),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _userProfile == null
                ? const Center(child: Text('Профиль не найден'))
                : _buildProfileContent(),
      ),
    );
  }

  Widget _buildProfileContent() {
    final roles = List<String>.from(_userProfile?['roles'] ?? []);
    final role = widget.newRole?.name ??
    _serviceManager.auth.activeRole?.name ??
    (roles.isNotEmpty ? roles.first : 'customer');
    final name = _userProfile!['name'] ?? 'Имя не указано';
    final phone = _userProfile!['phone'] ?? '';
    final city = _userProfile!['city'] ?? '';
    final isVerified = _userProfile!['isVerified'] ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Аватар и основная информация
          _buildProfileHeader(role, name, isVerified),
          
          const SizedBox(height: 24),
          
          // Основная информация
          _buildInfoSection('Основная информация', [
            _buildInfoTile(Icons.phone, 'Телефон', phone),
            //_buildInfoTile(Icons.email, 'Email', email.isNotEmpty ? email : 'Не указан'),
            _buildInfoTile(Icons.location_city, 'Город', city.isNotEmpty ? city : 'Не указан'),
            _buildInfoTile(Icons.verified, 'Статус', isVerified ? 'Верифицирован' : 'Не верифицирован'),
          ]),
          
          const SizedBox(height: 24),
          
          // Специфическая информация по роли
          _buildRoleSpecificInfo(role),
          
          const SizedBox(height: 24),
          
          // Статистика
         buildStatsSection(role, _getRandomStat),
          
          const SizedBox(height: 32),
          
          // Кнопки действий
          _buildActionButtons(),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(String role, String name, bool isVerified) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Аватар
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(
                  getRoleIcon(role),
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
              if (isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Имя
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Роль
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              getRoleDisplayName(role),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.iconPrimary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSpecificInfo(String role) {
    switch (role) {
      case 'foreman':
        return _buildInfoSection('Профессиональная информация', [
          _buildInfoTile(Icons.work, 'Специализация', _userProfile!['specialization'] ?? 'Не указана'),
          _buildInfoTile(Icons.timeline, 'Опыт работы', _userProfile!['experience'] ?? 'Не указан'),
        ]);
      case 'supplier':
        return _buildInfoSection('Информация о компании', [
          _buildInfoTile(Icons.business, 'Компания', _userProfile!['companyName'] ?? 'Не указана'),
          _buildInfoTile(Icons.location_on, 'Адрес', _userProfile!['address'] ?? 'Не указан'),
        ]);
      case 'courier':
        return _buildInfoSection('Информация о транспорте', [
          _buildInfoTile(Icons.directions_car, 'Тип транспорта', _userProfile!['vehicleType'] ?? 'Не указан'),
        ]);
      default:
        return const SizedBox.shrink();
    }
  }


  int _getRandomStat(String role, String type) {
    // Заглушка для статистики
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Кнопка редактирования профиля
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text('Редактировать профиль', style: TextStyle(color: Colors.white)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Функция редактирования в разработке')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        
        // Кнопка выхода
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Выйти из аккаунта', style: TextStyle(color: Colors.white)),
            onPressed: () {
              _showLogoutDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Выход из аккаунта'),
          content: const Text('Вы уверены, что хотите выйти?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const AuthLogoutEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Выйти'),
            ),
          ],
        );
      },
    );
  }
}
