import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../data/models/profile_model.dart';
import '../../domain/repositories/profile_repository.dart';
import '../widgets/token_debug_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileRepository _profileRepository = GetIt.instance<ProfileRepository>();
  bool _isLoading = true;
  ProfileModel? _profile;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _profileRepository.getUserProfile();
    
    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        });
      },
      (profile) {
        setState(() {
          _isLoading = false;
          _profile = profile;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Naviguer vers l'écran d'édition du profil
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Erreur: $_errorMessage',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserProfile,
              child: const Text('Réessayer'),
            ),
            const SizedBox(height: 24),
            // Widget de débogage pour voir le token
            const TokenDebugWidget(),
          ],
        ),
      );
    }

    if (_profile == null) {
      return const Center(
        child: Text('Aucune information de profil disponible'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildInfoSection('Informations personnelles', _buildPersonalInfo()),
          const SizedBox(height: 16),
          _buildInfoSection('Localisation', _buildLocationInfo()),
          const SizedBox(height: 16),
          _buildInfoSection('Document d\'identité', _buildIdInfo()),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Implémenter la déconnexion
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              'Déconnexion',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          backgroundImage: _profile?.profilePicture?.url != null
              ? NetworkImage(_profile!.profilePicture!.url!)
              : null,
          child: _profile?.profilePicture?.url == null
              ? Text(
                  _getInitials(_profile?.fullName ?? ''),
                  style: const TextStyle(fontSize: 40, color: Colors.black54),
                )
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          _profile?.fullName ?? '',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Citoyen',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        if (_profile?.isVerified == true)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                'Vérifié',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildInfoSection(String title, Widget content) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Column(
      children: [
        _buildInfoRow(
          Icons.email,
          'Email',
          _profile?.email ?? 'Non renseigné',
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          Icons.phone,
          'Téléphone',
          _profile?.phone ?? 'Non renseigné',
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          Icons.location_city,
          'Région',
          _profile?.region ?? 'Non renseignée',
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    final address = _profile?.address;
    final location = _profile?.currentLocation;
    
    return Column(
      children: [
        if (location != null)
          _buildInfoRow(
            Icons.location_on,
            'Coordonnées',
            'Lat: ${location.coordinates[1]}, Long: ${location.coordinates[0]}',
          ),
        const SizedBox(height: 12),
        if (address?.street != null)
          _buildInfoRow(
            Icons.home,
            'Adresse',
            address!.street!,
          ),
        if (address?.city != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildInfoRow(
              Icons.location_city,
              'Ville',
              address!.city!,
            ),
          ),
        if (address?.neighborhood != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildInfoRow(
              Icons.domain,
              'Quartier',
              address!.neighborhood!,
            ),
          ),
        if (address?.postalCode != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildInfoRow(
              Icons.markunread_mailbox,
              'Code postal',
              address!.postalCode!,
            ),
          ),
        if (address == null || (address.street == null && address.city == null && 
            address.neighborhood == null && address.postalCode == null))
          const Text('Aucune information d\'adresse disponible'),
      ],
    );
  }

  Widget _buildIdInfo() {
    return Column(
      children: [
        _buildInfoRow(
          Icons.badge,
          'Type de document',
          _profile?.idType ?? 'Non renseigné',
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          Icons.numbers,
          'Numéro',
          _profile?.idNumber ?? 'Non renseigné',
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          Icons.verified_user,
          'Statut de vérification',
          _profile?.isVerified == true ? 'Vérifié' : 'Non vérifié',
          valueColor: _profile?.isVerified == true ? Colors.green : Colors.red,
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[700],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: valueColor,
                  fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return '';
    
    final nameParts = fullName.split(' ');
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }
    
    return nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
  }
}
