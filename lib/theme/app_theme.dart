import 'package:flutter/material.dart';

abstract class _AppColors {
  static const Color primaryColor = Color(0xFF0D47A1); // Um azul mais escuro
  static const Color accentColor = Color(0xFF4CAF50); // Verde para ações de sucesso
  static const Color confirmButtonColor = Color(0xFF4CAF50); // Verde
  static const Color cancelButtonColor = Color(0xFFF44336); // Vermelho
  static const Color googleButtonColor = Color(0xFFDB4437); // Vermelho do Google
  static const Color googleButtonTextColor = Colors.white;

  // Cores para o tema claro
  static const Color lightPrimary = primaryColor;
  static const Color lightAccent = accentColor;
  static const Color lightBackground = Color(0xFFF5F5F5); // Um cinza bem claro
  static const Color lightCard = Colors.white;

  // Cores para o tema escuro
  static const Color darkPrimary = Color(0xFF1E88E5); // Um azul mais claro para contraste
  static const Color darkAccent = Color(0xFF66BB6A); // Um verde mais claro
  static const Color darkBackground = Color(0xFF121212); // Padrão do Material Design
  static const Color darkCard = Color(0xFF1E1E1E);
}


class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: _AppColors.lightPrimary,
    scaffoldBackgroundColor: _AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: _AppColors.lightPrimary,
      secondary: _AppColors.lightAccent,
      surface: _AppColors.lightCard,
      background: _AppColors.lightBackground,
      error: _AppColors.cancelButtonColor,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: _AppColors.lightCard,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: _AppColors.lightPrimary,
        foregroundColor: Colors.white,
      ),
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _AppColors.darkPrimary,
    scaffoldBackgroundColor: _AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: _AppColors.darkPrimary,
      secondary: _AppColors.darkAccent,
      surface: _AppColors.darkCard,
      background: _AppColors.darkBackground,
      error: _AppColors.cancelButtonColor,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: _AppColors.darkCard,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: _AppColors.darkPrimary,
        foregroundColor: Colors.white,
      ),
    ),
    useMaterial3: true,
  );
}
