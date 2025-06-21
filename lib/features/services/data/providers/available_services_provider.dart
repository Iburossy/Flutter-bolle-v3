import '../models/available_service_model.dart';
import 'package:flutter/material.dart';

/// Fournisseur de données pour les services disponibles
/// Pour l'instant, c'est une implémentation fictive en attendant une API réelle
class AvailableServicesProvider {
  /// Retourne une liste de services disponibles
  /// À terme, cela devrait faire un appel API vers le citoyen-service
  List<AvailableServiceModel> getAvailableServices() {
    return [
      // Police nationale
      AvailableServiceModel(
        id: 'police-service',
        name: 'Police nationale',
        description:
            'Signaler des incidents, déposer une plainte ou demander une assistance',
        iconPath: 'assets/icons/police.png',
        color: '#006837', // Vert foncé
        categories: [
          'Vol',
          'Agression',
          'Disparition',
          'Accident',
          'Nuisance sonore',
        ],
        isActive: true,
      ),

      // Service d'hygiène
      AvailableServiceModel(
        id: '68356f4666e7c7fb7fc3ab3f', // ID réel du service d'hygiène dans MongoDB
        name: 'Service d\'hygiène',
        description:
            'Signaler des problèmes liés à l\'hygiène, la salubrité publique et l\'environnement',
        iconPath: 'assets/icons/hygiene.png',
        color: '#FFC107', // Jaune
        categories: [
          'solutions', // Correspond aux catégories définies dans MongoDB
          'déchets',
          'eau',
          'nuisibles',
          'autres',
        ],
        isActive: true,
      ),

      // Douanes
      AvailableServiceModel(
        id: 'customs-service',
        name: 'Douanes',
        description:
            'Signaler des activités de contrebande ou des marchandises illégales',
        iconPath: 'assets/icons/customs.png',
        color: '#D73B28', // Rouge-orange
        categories: [
          'Contrebande',
          'Fraude fiscale',
          'Marchandises illicites',
          'Trafic',
        ],
        isActive: true,
      ),

      // Gendarmerie
      AvailableServiceModel(
        id: 'gendarmerie-service',
        name: 'Gendarmerie',
        description:
            'Signaler des incidents en zone rurale ou sur les grands axes routiers',
        iconPath: 'assets/icons/gendarmerie.png',
        color: '#004A2F', // Vert foncé
        categories: [
          'Sécurité routière',
          'Délit rural',
          'Contrefaçon',
          'Environnement',
        ],
        isActive: true,
      ),
    ];
  }

  /// Convertit une couleur hexadécimale en objet Color de Flutter
  static Color hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // Ajouter l'opacité complète si non spécifiée
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
