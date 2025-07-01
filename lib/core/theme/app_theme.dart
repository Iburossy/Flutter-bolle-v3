import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Classe qui définit le thème de l'application
class AppTheme {
  /// Obtenir le thème clair de l'application
  static ThemeData getLightTheme() {
    return ThemeData(
      // Couleur principale qui sera utilisée pour générer la palette de couleurs
      primaryColor: AppColors.primaryColor,

      // Définition du schéma de couleurs
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        error: AppColors.error,
        surface: AppColors.backgroundColor,
      ),

      // Couleur d'arrière-plan des scaffolds
      scaffoldBackgroundColor: AppColors.backgroundColor,

      // Style des cartes
      cardTheme: const CardTheme(
        color: Color.fromARGB(255, 245, 245, 245),
        elevation: 2,
        margin: EdgeInsets.all(8),
      ),

      // Style des boutons élevés
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Style des boutons texte
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor),
      ),

      // Style des champs de texte
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.textLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),

      // Style des textes
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.textPrimary),
        displayMedium: TextStyle(color: AppColors.textPrimary),
        displaySmall: TextStyle(color: AppColors.textPrimary),
        headlineLarge: TextStyle(color: AppColors.textPrimary),
        headlineMedium: TextStyle(color: AppColors.textPrimary),
        headlineSmall: TextStyle(color: AppColors.textPrimary),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        titleSmall: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textPrimary),
        bodySmall: TextStyle(color: AppColors.textSecondary),
        labelLarge: TextStyle(color: AppColors.textPrimary),
        labelMedium: TextStyle(color: AppColors.textPrimary),
        labelSmall: TextStyle(color: AppColors.textLight),
      ),

      // Autres personnalisations
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.appBarColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // Activer le Material 3 (optionnel)
      useMaterial3: true,
    );
  }

  /// Obtenir le thème sombre de l'application (si nécessaire)
  static ThemeData getDarkTheme() {
    // Vous pouvez implémenter un thème sombre ici si nécessaire
    return ThemeData.dark().copyWith(
      // Personnalisations du thème sombre
    );
  }
}
