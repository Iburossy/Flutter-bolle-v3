import 'package:flutter/material.dart';
import '../../../services/data/models/available_service_model.dart';
import '../../../services/data/providers/available_services_provider.dart';
import '../../../services/presentation/screens/service_detail_screen.dart';

class ServicesTabScreen extends StatelessWidget {
  const ServicesTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final servicesProvider = AvailableServicesProvider();
    final services = servicesProvider.getAvailableServices();

    // Message pour aucun service disponible
    if (services.isEmpty) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: Colors.amber,
                ),
                SizedBox(height: 16),
                Text(
                  'Aucun service disponible actuellement',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Calculer le nombre de colonnes en fonction de la largeur d'écran
    final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // Un seul widget de défilement pour tout le contenu
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête dans le widget scrollable
                const Text(
                  'Services disponibles',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 53, 126, 120),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Qui voulez-vous alerter ?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),
                // Utiliser GridView.count avec physics: NeverScrollableScrollPhysics()
                // pour désactiver le défilement indépendant de la grille
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Construction d'une carte de service (reprise du widget ServiceGridWidget)
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
