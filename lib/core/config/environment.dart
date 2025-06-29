import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Énumération des environnements disponibles
enum Environment {
  development,
  test,
  production,
}

/// Classe de gestion des environnements
class EnvironmentConfig {
  /// L'environnement actuel
  static Environment _environment = Environment.development;

  /// Getter pour l'environnement actuel
  static Environment get environment => _environment;

  /// Nom de l'environnement actuel
  static String get name => dotenv.env['ENV_NAME'] ?? 'development';

  /// Initialise l'environnement
  static Future<void> initialize({Environment env = Environment.development}) async {
    _environment = env;
    
    // Charge le fichier d'environnement approprié
    String fileName;
    switch (env) {
      case Environment.development:
        fileName = '.env.dev';
        break;
      case Environment.test:
        fileName = '.env.test';
        break;
      case Environment.production:
        fileName = '.env.prod';
        break;
    }
    
    // Charge le fichier d'environnement
    await dotenv.load(fileName: fileName);
    
    print('Environnement initialisé: ${dotenv.env['ENV_NAME']}');
    print('URL de base: ${dotenv.env['API_BASE_URL']}');
  }

  /// Vérifie si l'environnement actuel est de développement
  static bool get isDevelopment => _environment == Environment.development;

  /// Vérifie si l'environnement actuel est de test
  static bool get isTest => _environment == Environment.test;

  /// Vérifie si l'environnement actuel est de production
  static bool get isProduction => _environment == Environment.production;
}
