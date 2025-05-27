import 'package:flutter/material.dart';
import '../../data/models/available_service_model.dart';
import '../../data/providers/available_services_provider.dart';

/// Widget représentant une carte de service
class ServiceCard extends StatelessWidget {
  final AvailableServiceModel service;
  final VoidCallback onTap;

  const ServiceCard({
    Key? key,
    required this.service,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convertir la couleur hexadécimale en objet Color
    final serviceColor = AvailableServicesProvider.hexToColor(service.color);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: serviceColor.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône ou placeholder du service
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: serviceColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  _getIconForService(service.id),
                  color: serviceColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              // Informations du service
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Afficher les catégories
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: service.categories.map((category) => 
                        Chip(
                          label: Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              color: serviceColor,
                            ),
                          ),
                          backgroundColor: serviceColor.withValues(alpha: 0.1),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        )
                      ).toList(),
                    ),
                  ],
                ),
              ),
              // Flèche indiquant qu'on peut taper sur la carte
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Méthode pour obtenir l'icône appropriée en fonction de l'ID du service
  IconData _getIconForService(String serviceId) {
    switch (serviceId) {
      case 'hygiene-service':
        return Icons.cleaning_services;
      default:
        return Icons.miscellaneous_services;
    }
  }
}
