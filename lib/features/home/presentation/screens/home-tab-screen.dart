import 'package:flutter/material.dart';
import '../../../services/data/models/available_service_model.dart';
import '../../../services/data/providers/available_services_provider.dart';
import '../../../services/presentation/screens/service_detail_screen.dart';
import '../../../services/presentation/widgets/service_grid_widget.dart';

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
            'Qui voulez-vous envoyer une alerter ?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ServiceGridWidget(
              services: services,
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              cardStyle: ServiceCardStyle.withOverlay,
              onServiceTap: _navigateToServiceDetail,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Cette méthode n'est plus nécessaire car nous utilisons ServiceGridWidget

  void _navigateToServiceDetail(
    BuildContext context,
    AvailableServiceModel service,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(service: service),
      ),
    );
  }
}
