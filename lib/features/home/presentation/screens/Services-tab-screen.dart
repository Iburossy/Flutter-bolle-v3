import 'package:flutter/material.dart';
import '../../../services/data/models/available_service_model.dart';
import '../../../services/data/providers/available_services_provider.dart';
import '../../../services/presentation/screens/service_detail_screen.dart';
import '../../../services/presentation/widgets/service_grid_widget.dart';

class ServicesTabScreen extends StatelessWidget {
  const ServicesTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final servicesProvider = AvailableServicesProvider();
    final services = servicesProvider.getAvailableServices();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Services disponibles',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A5632), // Couleur verte pour le thème Yollë
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Qui voulez-vous alerter ?',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF757575),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: services.isEmpty
                  ? const Center(
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
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // Responsive layout - ajuste le nombre de colonnes selon la largeur
                        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                        
                        return ServiceGridWidget(
                          services: services,
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.9,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          cardStyle: ServiceCardStyle.withOverlay,
                          padding: const EdgeInsets.only(bottom: 20),
                          onServiceTap: _navigateToServiceDetail,
                        );
                      },
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
