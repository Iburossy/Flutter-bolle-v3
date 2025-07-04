import 'package:flutter/material.dart';
import '../../../services/data/models/available_service_model.dart';
import '../../../services/data/providers/available_services_provider.dart';
import '../../../services/presentation/screens/service_detail_screen.dart';

class HomeTabScreen extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const HomeTabScreen({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    // Récupérer les services disponibles depuis le provider
    // Pour la page d'accueil, on limite à 4 services maximum pour un aperçu
    final servicesProvider = AvailableServicesProvider();
    final allServices = servicesProvider.getAvailableServices();
    final services = allServices.length > 4 ? allServices.sublist(0, 4) : allServices;
    
    // Calculer le nombre de colonnes en fonction de la largeur d'écran
    final crossAxisCount = 2; // Toujours 2 colonnes pour la page d'accueil
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      // Utiliser SingleChildScrollView pour un seul défilement global
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Services',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 53, 126, 120),
                ),
              ),
            ),
            const Text(
              'Qui voulez-vous alerter ?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
            ),
            const SizedBox(height: 24),
            // Utiliser GridView sans défilement propre
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.9,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: services.length,
              // IMPORTANT: Désactiver le défilement de la grille elle-même
              physics: const NeverScrollableScrollPhysics(),
              // Réduire la grille à sa taille minimale nécessaire
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final service = services[index];
                return _buildServiceCard(context, service);
              },
            ),
            const SizedBox(height: 24),
            // Bouton Voir Plus si il y a plus de 4 services
            if (allServices.length > 4)
              ElevatedButton(
                onPressed: () => onNavigateToTab(1), // Naviguer vers l'onglet Services
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 53, 126, 120),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Voir plus de services',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  // Construction d'une carte de service
  Widget _buildServiceCard(BuildContext context, AvailableServiceModel service) {
    return GestureDetector(
      onTap: () => _navigateToServiceDetail(context, service),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image du service
              Image.asset(
                service.iconPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Image de secours en cas d'erreur
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 48),
                    ),
                  );
                },
              ),
              // Overlay foncé pour améliorer la lisibilité du texte
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              // Nom du service
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Text(
                  service.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToServiceDetail(BuildContext context, AvailableServiceModel service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(service: service),
      ),
    );
  }
}
