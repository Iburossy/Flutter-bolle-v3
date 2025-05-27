import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/profile_model.dart';
import '../../domain/repositories/profile_repository.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileModel profile;

  const EditProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileRepository _profileRepository = GetIt.instance<ProfileRepository>();
  final _formKey = GlobalKey<FormState>();
  File? _profileImageFile;
  bool _isUploading = false;
  
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _regionController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _neighborhoodController;
  late TextEditingController _postalCodeController;
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _emailController = TextEditingController(text: widget.profile.email ?? '');
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _regionController = TextEditingController(text: widget.profile.region);
    
    final address = widget.profile.address;
    _streetController = TextEditingController(text: address?.street ?? '');
    _cityController = TextEditingController(text: address?.city ?? '');
    _neighborhoodController = TextEditingController(text: address?.neighborhood ?? '');
    _postalCodeController = TextEditingController(text: address?.postalCode ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _regionController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Créer un nouveau modèle de profil avec les valeurs mises à jour
    final updatedProfile = ProfileModel(
      id: widget.profile.id,
      fullName: _fullNameController.text,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      role: widget.profile.role,
      isVerified: widget.profile.isVerified,
      isActive: widget.profile.isActive,
      region: _regionController.text,
      currentLocation: widget.profile.currentLocation,
      address: AddressModel(
        street: _streetController.text.isNotEmpty ? _streetController.text : null,
        city: _cityController.text.isNotEmpty ? _cityController.text : null,
        neighborhood: _neighborhoodController.text.isNotEmpty ? _neighborhoodController.text : null,
        postalCode: _postalCodeController.text.isNotEmpty ? _postalCodeController.text : null,
      ),
      idType: widget.profile.idType,
      idNumber: widget.profile.idNumber,
      profilePicture: widget.profile.profilePicture,
      createdAt: widget.profile.createdAt,
      updatedAt: DateTime.now(),
    );

    final result = await _profileRepository.updateUserProfile(updatedProfile);
    
    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (profile) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pop(profile);
      },
    );
  }

  Future<void> _selectProfilePicture() async {
    final status = await Permission.photos.request();
    if (!mounted) return;
    
    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (!mounted) return;
      
      if (pickedFile != null) {
        setState(() {
          _profileImageFile = File(pickedFile.path);
          _isUploading = true;
        });
        
        try {
          // Simuler un téléchargement (à remplacer par un vrai appel API)
          await Future.delayed(const Duration(seconds: 2));
          
          // Dans une implémentation réelle, vous appelleriez votre API pour télécharger l'image
          // final imageUrl = await _profileRepository.uploadProfilePicture(_profileImageFile!);          
          
          if (!mounted) return;
          setState(() {
            _isUploading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo de profil mise à jour')),
          );
        } catch (e) {
          if (!mounted) return;
          setState(() {
            _isUploading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${e.toString()}')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission d\'accès aux photos refusée')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveProfile,
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfilePictureSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('Informations personnelles'),
            const SizedBox(height: 16),
            _buildPersonalInfoSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('Adresse'),
            const SizedBox(height: 16),
            _buildAddressSection(),
            const SizedBox(height: 32),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Erreur: $_errorMessage',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Enregistrer les modifications',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: _profileImageFile != null
                    ? FileImage(_profileImageFile!)
                    : (widget.profile.profilePicture?.url != null
                        ? NetworkImage(widget.profile.profilePicture!.url!)
                        : null),
                backgroundColor: Colors.grey[300],
                child: (_profileImageFile == null && widget.profile.profilePicture?.url == null)
                    ? Text(
                        _getInitials(widget.profile.fullName),
                        style: const TextStyle(fontSize: 40, color: Colors.black54),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: InkWell(
                    onTap: () {
                      _selectProfilePicture();
                    },
                    child: _isUploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 24,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Changer la photo',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      children: [
        TextFormField(
          controller: _fullNameController,
          decoration: const InputDecoration(
            labelText: 'Nom complet',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre nom complet';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              // Validation simple de l'email
              if (!value.contains('@') || !value.contains('.')) {
                return 'Veuillez entrer un email valide';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Téléphone',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              // Validation simple du numéro de téléphone sénégalais
              if (!RegExp(r'^(\+221|00221|221)?[7][0-9]{8}$').hasMatch(value)) {
                return 'Veuillez entrer un numéro de téléphone sénégalais valide';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _regionController,
          decoration: const InputDecoration(
            labelText: 'Région',
            prefixIcon: Icon(Icons.location_city),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre région';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      children: [
        TextFormField(
          controller: _streetController,
          decoration: const InputDecoration(
            labelText: 'Rue',
            prefixIcon: Icon(Icons.home),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cityController,
          decoration: const InputDecoration(
            labelText: 'Ville',
            prefixIcon: Icon(Icons.location_city),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _neighborhoodController,
          decoration: const InputDecoration(
            labelText: 'Quartier',
            prefixIcon: Icon(Icons.domain),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _postalCodeController,
          decoration: const InputDecoration(
            labelText: 'Code postal',
            prefixIcon: Icon(Icons.markunread_mailbox),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
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
