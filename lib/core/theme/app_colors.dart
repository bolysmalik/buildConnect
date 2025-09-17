// app_colors.dart
// Файл с цветовой схемой приложения

import 'package:flutter/material.dart';

class AppColors {
  // Основные цвета
  static const Color primary = Color(0xFF7465FF);
  static const Color primaryLight = Color(0xFF9B8FFF);
  static const Color primaryDark = Color(0xFF5A4DC7);
  
  // Цвета для иконок
  static const Color iconPrimary = Color(0xFF7465FF);
  static const Color iconSecondary = Colors.grey;
  static const Color iconDisabled = Color(0xFFBDBDBD);
  
  // Цвета для текста (светлая тема)
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  
  // Фоновые цвета (светлая тема)
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color card = Colors.white;
  
  // Дополнительные цвета
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // ✅ ТЕМНАЯ ТЕМА - Цвета для иконок
  static const Color darkIconPrimary = Color(0xFF9B8FFF);
  static const Color darkIconSecondary = Color(0xFF888888);
  static const Color darkIconDisabled = Color(0xFF555555);
  
  // ✅ ТЕМНАЯ ТЕМА - Цвета для текста
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFBBBBBB);
  static const Color darkTextHint = Color(0xFF777777);
  
  // ✅ ТЕМНАЯ ТЕМА - Фоновые цвета
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2A2A2A);
}
