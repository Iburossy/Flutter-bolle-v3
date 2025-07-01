import 'package:flutter/material.dart';

/// Classe qui contient toutes les couleurs utilisées dans l'application
class AppColors {
  // Couleurs principales
  static const Color primaryColor = Color.fromARGB(255, 53, 126, 120); // Jaune principal
  static const Color secondaryColor = Color.fromARGB(255, 2, 99, 244); // Jaune secondaire
  static const Color accentColor = Color.fromARGB(255, 53, 126, 120); // Accent (pour les actions importantes)
  static const Color appBarColor = Color.fromARGB(255, 53, 126, 120); // Couleur de la barre d'application

  // Couleurs de fond
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);

  // Couleurs d'état
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}
