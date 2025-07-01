import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/service_contact_model.dart';
import '../../data/services/service_directory_service.dart';

class ServiceDirectoryScreen extends StatefulWidget {
  const ServiceDirectoryScreen({Key? key}) : super(key: key);

  @override
  State<ServiceDirectoryScreen> createState() => _ServiceDirectoryScreenState();
}

class _ServiceDirectoryScreenState extends State<ServiceDirectoryScreen> with SingleTickerProviderStateMixin {
  final ServiceDirectoryService _directoryService = ServiceDirectoryService();
  late TabController _tabController;
  late List<String> _categories;
  
  // Liste complète des contacts
  late List<ServiceContactModel> _allContacts;
  
  // Liste filtrée des contacts (pour la recherche)
  late List<ServiceContactModel> _filteredContacts;
  
  // Contrôleur pour le champ de recherche
  final TextEditingController _searchController = TextEditingController();
  
  // État de recherche active
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _categories = _directoryService.getCategories();
    _tabController = TabController(length: _categories.length, vsync: this);
    
    // Initialiser les listes de contacts
    _allContacts = _directoryService.getServiceContacts();
    _filteredContacts = List.from(_allContacts);
    
    // Ajouter un listener sur le contrôleur de recherche
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_filterContacts);
    _searchController.dispose();
    super.dispose();
  }



  // Fonction pour lancer un appel téléphonique
  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      // Nettoyer le numéro de téléphone (supprimer les espaces)
      final String cleanNumber = phoneNumber.replaceAll(' ', '');
      
      // Créer l'URI pour l'appel téléphonique - utiliser directement le composeur
      final Uri launchUri = Uri.parse('tel:$cleanNumber');
      
      // Lancer directement l'application de téléphone sans vérifier les permissions
      // Cela utilisera le composeur qui ne nécessite pas de permission spéciale
      if (!await launchUrl(launchUri, mode: LaunchMode.externalApplication)) {
        throw Exception('Impossible de lancer l\'appel');
      }
    } catch (e) {
      if (!mounted) return;
      
      print('Erreur lors du lancement de l\'appel: $e');
      
      // Afficher un message d'erreur plus convivial
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Impossible de lancer l\'appel. Veuillez vérifier que votre appareil peut passer des appels.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    }
  }
  
  // Filtrer les contacts en fonction du texte de recherche
  void _filterContacts() {
    final String searchText = _searchController.text.toLowerCase();
    
    if (searchText.isEmpty) {
      setState(() {
        _filteredContacts = List.from(_allContacts);
        _isSearching = false;
      });
      return;
    }
    
    setState(() {
      _filteredContacts = _allContacts.where((contact) {
        return contact.name.toLowerCase().contains(searchText) ||
               contact.description.toLowerCase().contains(searchText) ||
               contact.phoneNumber.contains(searchText);
      }).toList();
      _isSearching = true;
    });
  }
  
  // Effacer la recherche
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredContacts = List.from(_allContacts);
      _isSearching = false;
    });
  }

  // Obtenir l'icône correspondant au nom d'icône
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_police':
        return Icons.local_police;
      case 'fire_truck':
        return Icons.fire_truck;
      case 'medical_services':
        return Icons.medical_services;
      case 'security':
        return Icons.security;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'business_center':
        return Icons.business_center;
      case 'account_balance':
        return Icons.account_balance;
      case 'local_hospital':
        return Icons.local_hospital;
      default:
        return Icons.phone;
    }
  }

  // Widget pour afficher un contact de service en format carte pour la grille
  Widget _buildContactCard(ServiceContactModel contact) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icône du service en haut
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color.fromARGB(255, 53, 126, 120),
              child: Icon(
                _getIconData(contact.iconName),
                color: const Color.fromARGB(255, 255, 255, 255),
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            // Nom du service
            Text(
              contact.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Numéro de téléphone
            Text(
              contact.phoneNumber,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Description courte
            Text(
              contact.description,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            // Bouton d'appel
            ElevatedButton(
              onPressed: () => _makePhoneCall(contact.phoneNumber),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 53, 126, 120),
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
              ),
              child: const Icon(Icons.call),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un service...',
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: _clearSearch,
                ),
              ),
            )
          : const Text('Annuaire des Services'),
        backgroundColor: const Color(0xFF006837),
        foregroundColor: Colors.white,
        actions: [
          // Bouton de recherche
          IconButton(
            icon: Icon(_isSearching ? Icons.search_off : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _clearSearch();
                }
              });
            },
          ),
        ],
        bottom: _isSearching 
          ? null 
          : TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: _categories.map((category) => Tab(text: category)).toList(),
            ),
      ),
      body: _isSearching 
        ? _buildSearchResults()
        : TabBarView(
            controller: _tabController,
            children: _categories.map((category) {
              final contacts = _directoryService.getContactsByCategory(category);
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                padding: const EdgeInsets.all(8),
                itemCount: contacts.length,
                itemBuilder: (context, index) => _buildContactCard(contacts[index]),
              );
            }).toList(),
          ),
    );
  }
  
  // Construire les résultats de recherche
  Widget _buildSearchResults() {
    if (_filteredContacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun service trouvé pour "${_searchController.text}"',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      padding: const EdgeInsets.all(8),
      itemCount: _filteredContacts.length,
      itemBuilder: (context, index) => _buildContactCard(_filteredContacts[index]),
    );
  }
}
