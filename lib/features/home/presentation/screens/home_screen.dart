import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../services/data/models/available_service_model.dart';
import '../../../services/data/providers/available_services_provider.dart';
import '../../../services/presentation/screens/service_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSecureStorage _secureStorage = GetIt.instance<FlutterSecureStorage>();
  int _selectedIndex = 0;
  
  // Méthode pour naviguer entre les onglets
  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  late final List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    // Initialiser les écrans avec le callback de navigation
    _screens = [
      HomeTabScreen(onNavigateToTab: _navigateToTab),
      const AlertsTabScreen(),
      const ServicesTabScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bollé'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alertes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.miscellaneous_services),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    // Capture the context before the async gap
    final BuildContext currentContext = context;
    final confirmed = await showDialog<bool>(
      context: currentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _secureStorage.deleteAll();
      if (!mounted) return;
      
      // Use the mounted check before accessing context
      Navigator.of(currentContext).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}

class HomeTabScreen extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const HomeTabScreen({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    // Récupérer les services disponibles
    final servicesProvider = AvailableServicesProvider();
    final services = servicesProvider.getAvailableServices();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo et titre Bollé
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/bolle_logo.png',
                width: 48,
                height: 48,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF006837),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shield, color: Colors.yellow, size: 30),
                  );
                },
              ),
              const SizedBox(width: 12),
              const Text(
                'Bollé',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004A2F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          
          // Grille de services 2x2
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: services.map((service) {
                return _buildServiceCard(context, service);
              }).toList(),
            ),
          ),
          
          // Bouton "Lancer alerte"
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => onNavigateToTab(2), // Naviguer vers l'onglet des services
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006837),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Lancer alerte',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  // Méthode pour construire une carte de service
  Widget _buildServiceCard(BuildContext context, AvailableServiceModel service) {
    final serviceColor = AvailableServicesProvider.hexToColor(service.color);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(service: service),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: serviceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône du service
            Icon(
              _getIconForService(service.id),
              color: Colors.yellow,
              size: 40,
            ),
            const SizedBox(height: 16),
            // Nom du service
            Text(
              service.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Méthode pour obtenir l'icône appropriée en fonction de l'ID du service
  IconData _getIconForService(String serviceId) {
    switch (serviceId) {
      case 'police-service':
        return Icons.local_police;
      case 'hygiene-service':
        return Icons.cleaning_services;
      case 'customs-service':
        return Icons.account_balance;
      case 'gendarmerie-service':
        return Icons.local_fire_department;
      default:
        return Icons.miscellaneous_services;
    }
  }
}

class AlertsTabScreen extends StatelessWidget {
  const AlertsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Page des alertes à implémenter'),
    );
  }
}

class ServicesTabScreen extends StatelessWidget {
  const ServicesTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Utiliser le fournisseur de services pour obtenir les services disponibles
    final servicesProvider = AvailableServicesProvider();
    final services = servicesProvider.getAvailableServices();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Services disponibles',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sélectionnez un service pour envoyer une alerte',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: services.isEmpty
                ? const Center(child: Text('Aucun service disponible actuellement'))
                : GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: services.map((service) {
                      return _buildServiceCard(context, service);
                    }).toList(),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour construire une carte de service
  Widget _buildServiceCard(BuildContext context, AvailableServiceModel service) {
    final serviceColor = AvailableServicesProvider.hexToColor(service.color);
    
    return GestureDetector(
      onTap: () => _navigateToServiceDetail(context, service),
      child: Container(
        decoration: BoxDecoration(
          color: serviceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône du service
            Icon(
              _getIconForService(service.id),
              color: Colors.yellow,
              size: 40,
            ),
            const SizedBox(height: 16),
            // Nom du service
            Text(
              service.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Méthode pour obtenir l'icône appropriée en fonction de l'ID du service
  IconData _getIconForService(String serviceId) {
    switch (serviceId) {
      case 'police-service':
        return Icons.local_police;
      case 'hygiene-service':
        return Icons.cleaning_services;
      case 'customs-service':
        return Icons.account_balance;
      case 'gendarmerie-service':
        return Icons.local_fire_department;
      default:
        return Icons.miscellaneous_services;
    }
  }

  // Méthode pour naviguer vers la page de détail du service
  void _navigateToServiceDetail(BuildContext context, AvailableServiceModel service) {
    // Naviguer vers l'écran de création d'alerte pour ce service
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(service: service),
      ),
    );
  }
}
