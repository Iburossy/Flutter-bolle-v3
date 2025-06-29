import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config/environment.dart';
import 'injection_container.dart' as di; // di for dependency injection

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Déterminer l'environnement à partir des arguments de ligne de commande
  final String envName = const String.fromEnvironment('ENV', defaultValue: 'development');
  Environment env;
  
  switch (envName) {
    case 'production':
      env = Environment.production;
      break;
    case 'test':
      env = Environment.test;
      break;
    case 'development':
    default:
      env = Environment.development;
      break;
  }
  
  // Initialiser l'environnement
  await EnvironmentConfig.initialize(env: env);
  print('Application lancée en environnement: ${EnvironmentConfig.name}');
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const App());
}
