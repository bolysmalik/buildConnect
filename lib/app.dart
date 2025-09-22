// app.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_valhalla/core/utils/user_role_utils.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/authbloc/auth_bloc.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/login%20&%20reg/authbloc/auth_state.dart';
import 'package:flutter_valhalla/features/routing/presentation/screens/home_page/view/home_page.dart';
import 'package:flutter_valhalla/core/theme/app_theme.dart'; // ✅ Добавлен импорт темы
import 'package:flutter_valhalla/core/theme/theme_cubit.dart'; // ✅ Добавлен импорт ThemeCubit

// ✅ Определяем роли пользователя
enum UserRole { customer, foreman, supplier, courier, unauthorized }

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Valhalla Flutter BLoC',
          theme: AppTheme.lightTheme, // ✅ Используем нашу светлую тему
          darkTheme: AppTheme.darkTheme, // ✅ Используем нашу темную тему
          themeMode: themeMode, // ✅ Используем themeMode из ThemeCubit
          home: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              // Здесь можно добавить логику, которая реагирует на состояния.
            },
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (state is AuthAuthenticated) {
                // ✅ Преобразуем String в UserRole перед передачей
                return HomePage(userRole: stringToUserRole(state.userRole));
              } else {
                //return const AccountPage();
                return const HomePage(userRole: UserRole.unauthorized);
              }
            },
          ),
        );
      },
    );
  }
}