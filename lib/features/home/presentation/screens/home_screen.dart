import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:geolocator/geolocator.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../services/data/models/available_service_model.dart';
import '../../../services/data/providers/available_services_provider.dart';
import '../../../services/presentation/screens/service_detail_screen.dart';
import '../../../home/widgets/location_map_widget.dart';

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
          
          // Espace en bas
          const SizedBox(height: 24),
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

class AlertsTabScreen extends StatefulWidget {
  const AlertsTabScreen({super.key});

  @override
  State<AlertsTabScreen> createState() => _AlertsTabScreenState();
}

class _AlertsTabScreenState extends State<AlertsTabScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Déchets';
  String _selectedPriority = 'medium';
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  
  // Localisation
  Position? _currentPosition;
  String _currentAddress = '';
  
  // Liste des preuves (photos, vidéos, etc.)
  final List<Map<String, dynamic>> _proofs = [];
  
  // Catégories d'alertes disponibles
  final List<String> _categories = [
    'Déchets',
    'Eau',
    'Électricité',
    'Voirie',
    'Sécurité',
    'Autre'
  ];
  
  // Niveaux de priorité
  final Map<String, String> _priorities = {
    'low': 'Faible',
    'medium': 'Moyenne',
    'high': 'Élevée',
    'critical': 'Critique'
  };
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  // Méthode pour mettre à jour la position et l'adresse
  void _updateLocation(Position position, String address) {
    setState(() {
      _currentPosition = position;
      _currentAddress = address;
    });
  }
  
  // Méthode pour ajouter une preuve (photo, vidéo, etc.)
  Future<void> _addProof() async {
    // Cette méthode serait implémentée pour utiliser image_picker
    // et uploader les fichiers vers Cloudinary
    // Pour l'instant, affichons simplement une boîte de dialogue
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une preuve'),
        content: const Text('Cette fonctionnalité utiliserait image_picker pour prendre des photos ou vidéos, puis les enverrait à Cloudinary.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  // Méthode pour soumettre l'alerte
  Future<void> _submitAlert() async {
    if (_formKey.currentState!.validate() && _currentPosition != null) {
      setState(() => _isSubmitting = true);
      
      try {
        // Ici, nous utiliserions le bloc pour soumettre l'alerte
        // avec toutes les informations, y compris la localisation
        
        // Simuler un délai pour l'exemple
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alerte envoyée avec succès!')),
          );
          
          // Réinitialiser le formulaire
          _formKey.currentState!.reset();
          _titleController.clear();
          _descriptionController.clear();
          setState(() {
            _proofs.clear();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    } else if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une localisation')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Signaler un problème',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Titre de l'alerte
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description de l'alerte (optionnelle)
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnelle)',
                  hintText: 'Ajoutez des détails sur l\'alerte si nécessaire',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                // Pas de validation requise car le champ est optionnel
              ),
              const SizedBox(height: 16),
              
              // Catégorie
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Priorité
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priorité',
                  border: OutlineInputBorder(),
                ),
                items: _priorities.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Localisation avec Google Maps
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Localisation',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (_currentAddress.isNotEmpty)
                    Flexible(
                      child: Text(
                        _currentAddress,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LocationMapWidget(
                    height: 250,
                    onLocationSelected: _updateLocation,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Preuves (photos, vidéos, etc.)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Preuves',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addProof,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Ajouter'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_proofs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('Aucune preuve ajoutée'),
                  ),
                )
              else
                Container(
                  // Ici, on afficherait la liste des preuves
                ),
              const SizedBox(height: 16),
              
              // Option pour rester anonyme
              CheckboxListTile(
                title: const Text('Rester anonyme'),
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              
              // Bouton de soumission
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitAlert,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Envoyer l\'alerte'),
                ),
              ),
            ],
          ),
        ),
      ),
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
