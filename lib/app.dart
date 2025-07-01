import 'package:flutter/material.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart'; // Import OnboardingScreen
import 'features/splash/presentation/screens/splash_screen.dart'; // Import SplashScreen
import 'core/theme/app_theme.dart'; // Import du thème personnalisé

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yollë',
      debugShowCheckedModeBanner: false, // Optionnel: pour cacher la bannière de debug
      theme: AppTheme.getLightTheme(), // Utilisation de notre thème personnalisé
      home: SplashScreen(nextScreen: const OnboardingScreen()), // Afficher d'abord le SplashScreen, puis OnboardingScreen
    );
  }
}
