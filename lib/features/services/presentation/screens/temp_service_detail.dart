import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../data/models/available_service_model.dart';
import '../../../../features/alerts/data/models/create_alert_request_model.dart';
import '../../../../features/alerts/presentation/bloc/create_alert_bloc.dart';
import '../../../../features/alerts/presentation/bloc/create_alert_event.dart';
import '../../../../features/alerts/presentation/bloc/create_alert_state.dart';
import '../../../../injection_container.dart' as di;

class ServiceDetailScreen extends StatefulWidget {
  final AvailableServiceModel service;

  const ServiceDetailScreen({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  bool _isAnonymous = true; // Par défaut, l'alerte est anonyme
  bool _isLoading = false;
  
  // Fichiers sélectionnés
  List<String> _selectedImagePaths = [];
  String? _selectedVideoPath;
  String? _selectedAudioPath;
  List<double>? _currentCoordinates;
  String _currentAddress = '';
  
  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
  
  // Construction de l'icône du service
  Widget _buildServiceIcon() {
    // Conversion de la couleur hexadécimale en Color
    final Color serviceColor = Color(int.parse(widget.service.color.replaceAll('#', '0xFF')));
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: serviceColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(
        widget.service.iconPath,
        width: 20,
        height: 20,
      ),
    );
  }
  
  // Construction du menu déroulant pour les catégories
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.red),
      style: const TextStyle(fontSize: 16, color: Colors.black),
      items: widget.service.categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCategory = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner une catégorie';
        }
        return null;
      },
    );
  }
  
  // Construction du champ de description
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: 'Décrivez le problème en détail...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),

    );
  }
  
  // Option d'anonymat (radio buttons)
  Widget _buildAnonymousOption() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<bool>(
            title: const Text('Anonyme'),
            value: true,
            groupValue: _isAnonymous,
            onChanged: (bool? value) {
              setState(() {
                _isAnonymous = value ?? true;
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile<bool>(
            title: const Text('Non anonyme'),
            value: false,
            groupValue: _isAnonymous,
            onChanged: (bool? value) {
              setState(() {
                _isAnonymous = value ?? false;
              });
            },
          ),
        ),
      ],
    );
  }
  
  // Bouton de soumission
  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _submitAlert(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Soumettre l\'alerte',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
  
  // Traitement des preuves pour la requête
  List<Map<String, dynamic>>? _processProofs() {
    final List<Map<String, dynamic>> proofs = [];
    
    // Ajouter les images si présentes
    if (_selectedImagePaths.isNotEmpty) {
      proofs.addAll(_selectedImagePaths.map((path) => {
        'type': 'image',
        'url': path,
        'size': File(path).lengthSync(),
      }));
    }
    
    // Ajouter la vidéo si présente
    if (_selectedVideoPath != null) {
      proofs.add({
        'type': 'video',
        'url': _selectedVideoPath,
        'size': File(_selectedVideoPath!).lengthSync(),
      });
    }
    
    // Ajouter l'audio si présent
    if (_selectedAudioPath != null) {
      proofs.add({
        'type': 'audio',
        'url': _selectedAudioPath,
        'size': File(_selectedAudioPath!).lengthSync(),
      });
    }
    
    return proofs.isNotEmpty ? proofs : null;
  }

  // Soumission de l'alerte
  void _submitAlert(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      // Vérifier si la localisation a été faite
      if (_currentCoordinates == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez récupérer votre position avant de soumettre')),
        );
        return;
      }
      // Créer l'objet de requête d'alerte
      final alertRequest = CreateAlertRequestModel(
        serviceId: widget.service.id,
        category: _selectedCategory!.toLowerCase(),
        description: _descriptionController.text,
        coordinates: _currentCoordinates!,
        address: _currentAddress,
        isAnonymous: _isAnonymous,
        proofs: _processProofs(),
      );

      // Utiliser le BLoC pour envoyer l'alerte avec les fichiers sélectionnés
      BlocProvider.of<CreateAlertBloc>(context).add(
        CreateAlert(
          request: alertRequest,
          imagePaths: _selectedImagePaths.isNotEmpty ? _selectedImagePaths : null,
          videoPath: _selectedVideoPath,
          audioPath: _selectedAudioPath,
        ),
      );
    }
  }
  
  // Affichage des fichiers sélectionnés
  Widget _buildSelectedFilesPreview(String title, IconData icon, Color color, VoidCallback onClear) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear, size: 20),
            onPressed: onClear,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }
  
  // Bouton individuel pour chaque type de preuve
  Widget _buildProofButton({
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 110,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 32),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // Boutons pour ajouter des preuves
  Widget _buildProofButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildProofButton(
              backgroundColor: const Color(0xFFFFFDE7),
              icon: Icons.camera_alt,
              iconColor: Colors.amber,
              label: 'Ajouter\nune photo',
              onTap: () => _pickImage(),
              badgeCount: _selectedImagePaths.length,
            ),
            _buildProofButton(
              backgroundColor: const Color(0xFFE8F5E9),
              icon: Icons.videocam,
              iconColor: Colors.green,
              label: 'Ajouter\nune vidéo',
              onTap: () => _pickVideo(),
              badgeCount: _selectedVideoPath != null ? 1 : 0,
            ),
            _buildProofButton(
              backgroundColor: const Color(0xFFFBE9E7),
              icon: Icons.mic,
              iconColor: Colors.red,
              label: 'Ajouter un\nenregistrement\naudio',
              onTap: () => _pickAudio(),
              badgeCount: _selectedAudioPath != null ? 1 : 0,
            ),
          ],
        ),
        if (_selectedImagePaths.isNotEmpty || _selectedVideoPath != null || _selectedAudioPath != null)
          const SizedBox(height: 12),
        if (_selectedImagePaths.isNotEmpty)
          _buildSelectedFilesPreview(
            'Photos sélectionnées (${_selectedImagePaths.length})',
            Icons.image,
            Colors.amber,
            () => setState(() => _selectedImagePaths = []),
          ),
        if (_selectedVideoPath != null)
          _buildSelectedFilesPreview(
            'Vidéo sélectionnée',
            Icons.video_file,
            Colors.green,
            () => setState(() => _selectedVideoPath = null),
          ),
        if (_selectedAudioPath != null)
          _buildSelectedFilesPreview(
            'Audio sélectionné',
            Icons.audio_file,
            Colors.red,
            () => setState(() => _selectedAudioPath = null),
          ),
      ],
    );
  }
  
  // Récupération de la position actuelle sans carte
  Future<void> _getLocation() async {
    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission de localisation refusée')),
          );
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Les permissions de localisation sont refusées de façon permanente, nous ne pouvons pas demander les permissions.'),
          ),
        );
        return;
      }
      
      // Afficher un indicateur de chargement
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Récupération de votre position...')),
      );
      
      // Obtenir la position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Géocodage inverse pour obtenir l'adresse
      String address = "Adresse inconnue";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          address = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}';
        }
      } catch (e) {
        print('Erreur de géocodage: $e');
      }
      
      // Mettre à jour les coordonnées et l'adresse
      setState(() {
        _currentCoordinates = [position.longitude, position.latitude];
        _currentAddress = address;
      });
      
      // Afficher un message de succès
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Position récupérée avec succès')),
      );
      
    } catch (e) {
      // Gérer les erreurs
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de localisation: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
      // Définir des coordonnées par défaut pour Dakar
      setState(() {
        _currentCoordinates = [-17.4440, 14.6937]; // Dakar, Sénégal
        _currentAddress = "Dakar, Sénégal";
      });
    }
  }

  // Carte de localisation
  Widget _buildLocationCard() {
    return InkWell(
      onTap: _getLocation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Utilisation automatique',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Text(
                    'de la géolocalisation',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentAddress.isNotEmpty ? _currentAddress : 'Appuyez pour localiser',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.refresh, color: Colors.blue[700]),
          ],
        ),
      ),
    );
  }
  
  // Sélection d'images
  Future<void> _pickImage() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        setState(() {
          _selectedImagePaths.add(pickedFile.path);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission de photos refusée')),
      );
    }
  }

  // Sélection de vidéo
  Future<void> _pickVideo() async {
    final status = await Permission.videos.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        setState(() {
          _selectedVideoPath = pickedFile.path;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission de vidéos refusée')),
      );
    }
  }

  // Sélection d'audio
  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedAudioPath = result.files.first.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            _buildServiceIcon(),
            const SizedBox(width: 8),
            Text(widget.service.name),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocProvider(
        create: (_) => di.sl<CreateAlertBloc>(),
        child: BlocConsumer<CreateAlertBloc, CreateAlertState>(
          listener: (context, state) {
            setState(() {
              _isLoading = state is CreateAlertLoading;
            });

            if (state is CreateAlertSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Alerte créée avec succès!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else if (state is CreateAlertError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre principal
                    const Text(
                      'Lancer une alerte',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Catégorie d'anomalie
                    const Text(
                      'Catégorie d\'anomalie',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCategoryDropdown(),
                    
                    const SizedBox(height: 24),
                    
                    // Description du problème
                    const Text(
                      'Description du problème',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDescriptionField(),
                    
                    const SizedBox(height: 24),
                    
                    // Section des preuves
                    const Text(
                      'Preuves',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildProofButtons(),
                    
                    const SizedBox(height: 24),
                    
                    // Localisation
                    const Text(
                      'Localisation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildLocationCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Option d'anonymat
                    const Text(
                      'Anonymat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    _buildAnonymousOption(),
                    
                    const SizedBox(height: 32),
                    
                    // Bouton de soumission
                    _buildSubmitButton(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
