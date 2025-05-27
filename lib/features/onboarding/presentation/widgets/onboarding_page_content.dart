import 'package:flutter/material.dart';
import '../../data/models/onboarding_item_model.dart';

class OnboardingPageContent extends StatelessWidget {
  final OnboardingItemModel item;

  const OnboardingPageContent({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Placeholder for image - assuming images are in assets/images/
          // You'll need to add your images to the assets folder and pubspec.yaml
          Image.asset(
            item.imagePath,
            height: MediaQuery.of(context).size.height * 0.4,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 48.0),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16.0),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
