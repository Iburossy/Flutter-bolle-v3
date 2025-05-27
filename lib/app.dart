import 'package:flutter/material.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart'; // Import OnboardingScreen

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Citoyen App',
      debugShowCheckedModeBanner: false, // Optionnel: pour cacher la bannière de debug
      theme: ThemeData(
        primarySwatch: Colors.green,
        // Vous pouvez personnaliser davantage votre thème ici
        // Par exemple, pour correspondre aux couleurs de vos maquettes:
        // colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFYOUR_PRIMARY_COLOR_HEX)),
        // textTheme: Theme.of(context).textTheme.apply(
        //   fontFamily: 'VotrePoliceCustom', // Si vous en avez une
        // ),
      ),
      home: const OnboardingScreen(), // Définir OnboardingScreen comme page d'accueil
    );
  }
}
