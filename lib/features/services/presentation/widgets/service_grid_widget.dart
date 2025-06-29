import 'package:flutter/material.dart';
import '../../data/models/available_service_model.dart';
import '../../data/providers/available_services_provider.dart';
import '../screens/service_detail_screen.dart';

/// Widget réutilisable pour afficher une grille de services
/// Peut être configuré pour différentes mises en page et styles
class ServiceGridWidget extends StatelessWidget {
  /// Liste des services à afficher
  final List<AvailableServiceModel> services;
  
  /// Nombre de colonnes dans la grille
  final int crossAxisCount;
  
  /// Espacement entre les éléments horizontalement
  final double crossAxisSpacing;
  
  /// Espacement entre les éléments verticalement
  final double mainAxisSpacing;
  
  /// Rayon de bordure pour les cartes
  final double borderRadius;
  
  /// Ratio hauteur/largeur des cartes
  final double childAspectRatio;
  
  /// Style d'affichage (simple ou avec overlay de texte)
  final ServiceCardStyle cardStyle;
  
  /// Fonction de navigation personnalisée (optionnelle)
  final Function(BuildContext, AvailableServiceModel)? onServiceTap;
  
  /// Padding autour de la grille
  final EdgeInsets padding;

  const ServiceGridWidget({
    Key? key,
    required this.services,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 16.0,
    this.mainAxisSpacing = 16.0,
    this.borderRadius = 16.0,
    this.childAspectRatio = 1.0,
    this.cardStyle = ServiceCardStyle.simple,
    this.onServiceTap,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
        ),
        itemCount: services.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return _buildServiceCard(context, services[index]);
        },
      ),
    );
  }

  /// Construit une carte de service selon le style demandé
  Widget _buildServiceCard(BuildContext context, AvailableServiceModel service) {
    return GestureDetector(
      onTap: () {
        if (onServiceTap != null) {
          onServiceTap!(context, service);
        } else {
          _defaultNavigateToServiceDetail(context, service);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image du service
              Image.asset(
                service.iconPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Erreur de chargement d\'image pour ${service.name}: ${service.iconPath}');
                  final color = AvailableServicesProvider.hexToColor(service.color);
                  return Container(
                    color: color.withValues(alpha: 0.3),
                    alignment: Alignment.center,
                    child: Icon(
                      _getIconForService(service.id),
                      size: 50,
                      color: color,
                    ),
                  );
                },
              ),
              
              // Overlay de texte (si le style le demande)
              if (cardStyle == ServiceCardStyle.withOverlay)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      service.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigation par défaut vers l'écran de détail du service
  void _defaultNavigateToServiceDetail(BuildContext context, AvailableServiceModel service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(service: service),
      ),
    );
  }

  /// Fonction helper pour obtenir une icône selon le type de service
  IconData _getIconForService(String serviceId) {
    switch (serviceId.toLowerCase()) {
      case 'police-service':
        return Icons.local_police;
      case 'customs-service':
        return Icons.business;
      case 'gendarmerie-service':
        return Icons.security;
      case 'ucg-service':
        return Icons.cleaning_services;
      case 'onas-service':
        return Icons.water_drop;
      default:
        return Icons.business;
    }
  }
}

/// Styles disponibles pour les cartes de service
enum ServiceCardStyle {
  /// Carte simple avec juste l'image
  simple,
  
  /// Carte avec overlay de texte sur l'image
  withOverlay,
}
