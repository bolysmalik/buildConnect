// theme_cubit.dart
// Cubit для управления темой приложения

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light); // По умолчанию светлая тема

  // Переключение на светлую тему
  void setLightTheme() {
    emit(ThemeMode.light);
  }

  // Переключение на темную тему
  void setDarkTheme() {
    emit(ThemeMode.dark);
  }

  // Переключение на системную тему
  void setSystemTheme() {
    emit(ThemeMode.system);
  }

  // Получить название текущей темы для отображения
  String get currentThemeName {
    switch (state) {
      case ThemeMode.light:
        return 'Светлая';
      case ThemeMode.dark:
        return 'Темная';
      case ThemeMode.system:
        return 'Системная';
    }
  }
}
