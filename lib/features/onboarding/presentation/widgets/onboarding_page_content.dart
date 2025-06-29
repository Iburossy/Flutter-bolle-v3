import 'package:flutter/material.dart';
import '../../data/models/onboarding_item_model.dart';

class OnboardingPageContent extends StatelessWidget {
  final OnboardingItemModel item;

  const OnboardingPageContent({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image plein écran
        Image.asset(
          item.imagePath,
          fit: BoxFit.cover,
        ),

        // Dégradé pour améliorer lisibilité du texte
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),

        // Texte positionné plus haut
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(left: 32, right: 32, bottom: 120), // ↑ Ici on remonte le texte
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Column(
                key: ValueKey(item.title),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
