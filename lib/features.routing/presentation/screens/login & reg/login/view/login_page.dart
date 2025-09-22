import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/core/utils/hone_mask.dart';
import 'package:flutter_valhalla/core/utils/phone_utils.dart';
import 'package:flutter_valhalla/core/utils/user_role_utils.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/home_page/view/home_page.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/login/widgets/quick_login_buttons.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/registration/view/registration_page.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/profile/view/profile_page.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/authbloc/auth_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/authbloc/auth_event.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/authbloc/auth_state.dart';
import 'package:flutter_valhalla/app.dart';
import 'package:flutter_valhalla/core/theme/app_colors.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/login/view/sign_with_social.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();



  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Вход выполнен успешно!')),
          );
          // ✅ Навигация на HomePage с userRole
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => HomePage(userRole: stringToUserRole(state.userRole))),
                (route) => false,
          );
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        Widget body;
        String appBarTitle;

        if (state is AuthLoading) {
          appBarTitle = 'Загрузка...';
          body = const Center(child: CircularProgressIndicator());
        } else if (state is AuthAuthenticated) {
          appBarTitle = 'Мой Профиль';
          // ✅ Преобразуем String в UserRole перед передачей
          body = _buildProfileView(context, stringToUserRole(state.userRole));
        } else if (state is AuthRegistrationPendingModeration) {
          appBarTitle = 'Заявка на рассмотрении';
          body = _buildModerationView(context);
        } else {
          appBarTitle = 'Вход / Регистрация';
          body = _buildLoginView(context, state);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            centerTitle: true,
            automaticallyImplyLeading: true,
          ),
          body: body,
        );
      },
    );
  }

  Widget _buildProfileView(BuildContext context, UserRole userRole) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Вы вошли в систему!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person, color: Colors.white),
                label: const Text('Перейти в профиль', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
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
          ],
        ),
      ),
    );
  }

  Widget _buildModerationView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.access_time, size: 64, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Ваша заявка отправлена на рассмотрение',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Мы свяжемся с вами после проверки всех данных.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthLogoutEvent());
              },
              child: const Text('Вернуться к экрану входа'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginView(BuildContext context, AuthState state) {
    bool isLoading = state is AuthLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: AbsorbPointer(
        absorbing: isLoading,
        child: Form(
          key: _loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Welcome back',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Login to continue',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 40),

              const Text('Phone Number', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [phoneMaskFormatter],
                decoration: const InputDecoration(
                  hintText: '+7 (___) ___-__-__',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите номер телефона';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              const Text('Password', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Введите пароль',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите пароль';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.phone, color: Colors.white),
                  label: const Text('Войти', style: TextStyle(color: Colors.white)),
                  onPressed: isLoading ? null : () {
                    if (_loginFormKey.currentState!.validate()) {
                      final normalizedPhone = PhoneUtils.normalize(_phoneController.text.trim());
                      context.read<AuthBloc>().add(
                        AuthLoginWithPhoneEvent(
                           normalizedPhone,
                          _passwordController.text,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // ✅ Используем наш основной цвет
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Center(child: Text('or', style: TextStyle(color: Colors.black))),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.app_registration, color: AppColors.primary),
                  label: const Text('Register now', style: TextStyle(color: AppColors.primary)),
                  onPressed: isLoading ? null : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegistrationPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
               SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.alternate_email, color: Colors.white),
                  label: const Text('Login with social media', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  SignInScreen(), // убедитесь, что LoginPage импортирован
                        ),
                      );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Social media login coming soon!')),
                    );
                  },
                ),
              ),
              QuickLoginButtons(
                phoneController: _phoneController,
                passwordController: _passwordController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
