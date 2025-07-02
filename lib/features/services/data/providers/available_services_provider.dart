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
        iconPath: 'assets/images/police.jpg',
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
        iconPath: 'assets/images/hygiene.jpg',
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
        name: 'Douane',
        description:
            'Signaler des activités de contrebande ou des marchandises illégales',
        iconPath: 'assets/images/douane.jpg',
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
        iconPath: 'assets/images/gendarmerie.jpg',
        color: '#004A2F', // Vert foncé
        categories: [
          'Sécurité routière',
          'Délit rural',
          'Contrefaçon',
          'Environnement',
        ],
        isActive: true,
      ),

      // UCG
      AvailableServiceModel(
        id: 'ucg-service',
        name: 'UCG',
        description:
            'Signaler des problèmes liés à la gestion des déchets et à la salubrité publique',
        iconPath: 'assets/images/ucg.png',
        color: '#004A2F',
        categories: [
          'Déchets ménagers',
          'Dépôts sauvages',
          'Hygiène publique',
          'Nettoyage des voies',
        ],

        isActive: true,
      ),

      // ONAS
      AvailableServiceModel(
        id: 'onas-service',
        name: 'ONAS',
        description:
            'Signaler des problèmes liés à l\'assainissement, aux eaux usées ou aux canalisations bouchées',
        iconPath: 'assets/images/onas.jpg',
        color: '#0066CC', // Bleu ONAS
        categories: [
          'Canalisations bouchées',
          'Débordement eaux usées',
          'Assainissement non fonctionnel',
          'Odeurs nauséabondes',
        ],

        isActive: true,
      ),

      //SANTE
      AvailableServiceModel(
      id: 'sante-service',
      name: 'Santé Publique',
      description:
          'Signaler des problèmes liés aux structures de santé, aux urgences non prises en charge ou à la qualité des soins',
      iconPath: 'assets/images/sante.jpg',
      color: '#CC0000', // Rouge santé / urgence
      categories: [
        'Manque de personnel médical',
        'Absence de médicaments',
        'Refus de prise en charge',
        'Hygiène insuffisante',
      ],
      isActive: true,
),


      // SENELEC
      AvailableServiceModel(
      id: 'senelec-service',
      name: 'SENELEC',
      description:
          'Signaler des problèmes liés à l’électricité, comme des coupures de courant, des installations dangereuses ou des compteurs défectueux',
      iconPath: 'assets/images/senelec.jpg',
      color: '#FFD700', // Jaune doré inspiré de la lumière / énergie
      categories: [
        'Coupure de courant',
        'Facturation anormale',
        'Compteur défectueux',
        'Installation électrique dangereuse',
        'Poteau électrique tombé',
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
