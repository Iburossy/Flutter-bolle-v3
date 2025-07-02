import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../injection_container.dart' as di;
import '../../../alerts/data/models/create_alert_request_model.dart';
import '../../../alerts/presentation/bloc/create_alert_bloc.dart';
import '../../../alerts/presentation/bloc/create_alert_event.dart';
import '../../../alerts/presentation/bloc/create_alert_state.dart';
import '../../data/models/available_service_model.dart';

class ServiceDetailScreen extends StatefulWidget {
  final AvailableServiceModel service;

  const ServiceDetailScreen({
    super.key,
    required this.service,
  });

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
  
  // Localisation
  List<double> _currentCoordinates = [0.0, 0.0]; // [longitude, latitude]
  String _currentAddress = "Adresse inconnue";
  
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _initAudio();
  }
  
  // Initialiser les instances audio
  Future<void> _initAudio() async {
    try {
      // Vérifier et demander les permissions nécessaires
      PermissionStatus microphoneStatus = await Permission.microphone.status;
      PermissionStatus storageStatus = await Permission.storage.status;
      
      if (!microphoneStatus.isGranted) {
        microphoneStatus = await Permission.microphone.request();
      }
      
      if (!storageStatus.isGranted) {
        storageStatus = await Permission.storage.request();
      }
      
      // Vérifier si les permissions ont été accordées
      if (!microphoneStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission de microphone refusée. L\'enregistrement audio ne sera pas disponible.'))
        );
        return;
      }
      
      // Obtenir le répertoire temporaire pour sauvegarder l'audio
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      // Initialiser le contrôleur d'enregistrement
      _audioRecorder = RecorderController()
        ..androidEncoder = AndroidEncoder.aac
        ..androidOutputFormat = AndroidOutputFormat.mpeg4
        ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
        ..sampleRate = 44100;
        
      // Initialiser le contrôleur de lecture
      _audioPlayer = PlayerController();
      
      // Définir le chemin d'enregistrement
      _recordedPath = path;
      
      // Marquer les contrôleurs comme initialisés
      _isRecorderInitialized = true;
      _isPlayerInitialized = true;
      
      print('Audio initialization successful');
    } catch (e) {
      print('Error initializing audio: $e');
      _isRecorderInitialized = false;
      _isPlayerInitialized = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'initialisation de l\'audio: $e'))
      );
    }
  }
  
  @override
  void dispose() {
    _descriptionController.dispose();
    
    // Libération des ressources audio
    if (_isPlayerInitialized) {
      _audioPlayer.dispose();
    }
    if (_isRecorderInitialized) {
      _audioRecorder.dispose();
    }
    
    super.dispose();
  }
  
  // Sélection d'images avec choix entre appareil photo et galerie
  Future<void> _pickImages() async {
    try {
      // Afficher une boîte de dialogue pour choisir la source
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Prendre une photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _getImageFromSource(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choisir depuis la galerie'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _getImageFromGallery();
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      
      print('Erreur lors de la sélection de photos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de sélectionner des photos: $e')),
      );
    }
  }
  
  // Sélection d'une image depuis l'appareil photo
  Future<void> _getImageFromSource(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      
      if (!mounted) return;
      
      if (pickedFile != null) {
        setState(() {
          _selectedImagePaths.add(pickedFile.path);
        });
        // Confirmation visuelle à l'utilisateur
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo ajoutée avec succès')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      print('Erreur lors de la prise de photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de prendre une photo: $e')),
      );
    }
  }
  
  // Sélection de plusieurs images depuis la galerie
  Future<void> _getImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage();
      
      if (!mounted) return;
      
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImagePaths.addAll(pickedFiles.map((file) => file.path));
        });
        // Confirmation visuelle à l'utilisateur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${pickedFiles.length} photo(s) sélectionnée(s)')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      print('Erreur lors de la sélection de photos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de sélectionner des photos: $e')),
      );
    }
  }

  // Sélection de vidéo avec choix entre appareil photo et galerie
  Future<void> _pickVideo() async {
    try {
      // Afficher une boîte de dialogue pour choisir la source
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.videocam),
                  title: const Text('Enregistrer une vidéo'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _getVideoFromSource(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_library),
                  title: const Text('Choisir depuis la galerie'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _getVideoFromSource(ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      
      print('Erreur lors de la sélection de vidéo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de sélectionner une vidéo: $e')),
      );
    }
  }
  
  // Sélection d'une vidéo depuis une source spécifiée (appareil photo ou galerie)
  Future<void> _getVideoFromSource(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickVideo(source: source);
      
      if (!mounted) return;
      
      if (pickedFile != null) {
        setState(() {
          _selectedVideoPath = pickedFile.path;
        });
        // Confirmation visuelle à l'utilisateur
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vidéo sélectionnée avec succès')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      print('Erreur lors de la sélection de vidéo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de sélectionner une vidéo: $e')),
      );
    }
  }

  // Variables pour l'enregistrement audio
  late final RecorderController _audioRecorder;
  late final PlayerController _audioPlayer;
  bool _isRecorderInitialized = false;
  bool _isPlayerInitialized = false;
  String _recordedPath = '';
  String _audioFileName = '';

  // Sélection d'audio avec choix entre enregistrement et galerie
  Future<void> _pickAudio() async {
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Choisir une source audio'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.mic),
                title: const Text('Enregistrer'),
                onTap: () => Navigator.pop(context, 'record'),
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Galerie'),
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
            ],
          ),
        ),
      );

      if (result == 'record') {
        await _showAudioRecordingDialog();
      } else if (result == 'gallery') {
        await _selectAudioFromGallery();
      }
    } catch (e) {
      if (!mounted) return;
      
      print('Erreur lors de la sélection audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de sélectionner un audio: $e')),
      );
    }
  }
  
  // Sélection d'un fichier audio depuis la galerie
  Future<void> _selectAudioFromGallery() async {
    try {
      // Vérifier et demander les permissions nécessaires
      PermissionStatus storageStatus = await Permission.storage.status;
      
      if (!storageStatus.isGranted) {
        storageStatus = await Permission.storage.request();
      }
      
      if (!storageStatus.isGranted) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission d\'accès au stockage requise pour sélectionner un fichier audio')),
        );
        return;
      }

      // Utiliser FilePicker pour sélectionner un fichier audio
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowCompression: true,
      );
      
      if (!mounted) return;
      
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedAudioPath = result.files.first.path!;
          _audioFileName = result.files.first.name;
        });
        
        // Initialiser le lecteur pour la prévisualisation
        if (_isPlayerInitialized && _selectedAudioPath != null) {
          await _audioPlayer.preparePlayer(
            path: _selectedAudioPath!,
            shouldExtractWaveform: true,
          );
        }
        
        // Confirmation visuelle à l'utilisateur
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fichier audio sélectionné avec succès')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      print('Erreur lors de la sélection d\'audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de sélectionner un fichier audio: $e')),
      );
    }
  }
  
  // Afficher la boîte de dialogue d'enregistrement audio
  Future<void> _showAudioRecordingDialog() async {
    if (!await Permission.microphone.isGranted) {
      await Permission.microphone.request();
      if (!await Permission.microphone.isGranted) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission du microphone requise pour enregistrer'))
        );
        return;
      }
    }

    if (!mounted) return;
    
    // Vérifier si les contrôleurs sont initialisés
    if (!_isRecorderInitialized || !_isPlayerInitialized) {
      await _initAudio();
    }

    // Afficher la boîte de dialogue d'enregistrement
    final recordingResult = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        bool isRecording = false;
        bool hasRecorded = false;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Enregistrement Audio'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isRecording 
                        ? 'Enregistrement en cours...' 
                        : (hasRecorded ? 'Enregistrement terminé' : 'Prêt à enregistrer'),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  if (isRecording || hasRecorded)
                    AudioWaveforms(
                      size: Size(MediaQuery.of(context).size.width * 0.7, 100),
                      recorderController: _audioRecorder,
                      waveStyle: const WaveStyle(
                        waveColor: Colors.blue,
                        extendWaveform: true,
                        showMiddleLine: false,
                      ),
                      padding: const EdgeInsets.only(left: 18),
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                    ),
                  if (!isRecording && hasRecorded)
                    IconButton(
                      onPressed: () async {
                        try {
                          if (_audioPlayer.playerState == PlayerState.playing) {
                            await _audioPlayer.pausePlayer();
                          } else {
                            await _audioPlayer.preparePlayer(
                              path: _recordedPath,
                              shouldExtractWaveform: true,
                            );
                            await _audioPlayer.startPlayer();
                          }
                          setDialogState(() {});
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur de lecture: $e')),
                          );
                        }
                      },
                      icon: Icon(_audioPlayer.playerState == PlayerState.playing 
                          ? Icons.pause : Icons.play_arrow),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop('cancel');
                  },
                  child: const Text('Annuler'),
                ),
                if (!isRecording && hasRecorded)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop('confirm');
                    },
                    child: const Text('Confirmer'),
                  ),
                IconButton(
                  icon: Icon(isRecording ? Icons.stop : Icons.mic),
                  color: isRecording ? Colors.red : Colors.blue,
                  onPressed: () async {
                    try {
                      if (isRecording) {
                        final path = await _audioRecorder.stop();
                        setDialogState(() {
                          isRecording = false;
                          hasRecorded = true;
                        });

                        // Initialiser le lecteur avec l'audio enregistré
                        await _audioPlayer.preparePlayer(
                          path: path!,
                          shouldExtractWaveform: true,
                        );

                        setState(() {
                          _recordedPath = path;
                          _audioFileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
                        });
                      } else {
                        await _audioRecorder.record(path: _recordedPath);
                        setDialogState(() {
                          isRecording = true;
                        });
                      }
                    } catch (e) {
                      print('Erreur lors de l\'enregistrement: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur d\'enregistrement: $e')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (recordingResult == 'confirm') {
      setState(() {
        _selectedAudioPath = _recordedPath;
      });
      // Message de confirmation pour l'utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enregistrement audio ajouté avec succès')),
      );
    }
  }
  
  // Note: La méthode dispose() a été déplacée en haut de la classe
  
  // Méthode pour obtenir l'icône appropriée en fonction de l'ID du service
  IconData _getIconForService(String serviceId) {
    switch (serviceId) {
      case 'police-service':
        return Icons.local_police;
      case 'hygiene-service':
        return Icons.cleaning_services;
      case 'customs-service':
        return Icons.business_center;
      case 'gendarmerie-service':
        return Icons.security;
      default:
        return Icons.report_problem;
    }
  }
  
  // Construction de l'icône du service
  Widget _buildServiceIcon() {
    // Conversion de la couleur hexadécimale en Color
    final Color serviceColor = Color(int.parse(widget.service.color.replaceAll('#', '0xFF')));
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: serviceColor.withAlpha(51), // 0.2 * 255 = ~51
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getIconForService(widget.service.id),
        color: Colors.white,
        size: 20,
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
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Veuillez entrer une description';
        } else if (value.length < 10) {
          return 'La description doit contenir au moins 10 caractères';
        }
        return null;
      },
    );
  }
  
  // Option d'anonymat (radio buttons)
  Widget _buildAnonymousOption() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<bool>(
            title: const Text('Oui'),
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
            title: const Text('Non'),
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
                'Envoyer l\'alerte',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
  
  // Cette méthode n'est plus nécessaire car la localisation est gérée par le widget LocationMapWidget
  // Nous la gardons comme méthode de secours au cas où
  Future<void> _getCurrentLocation() async {
    try {
      // Vérification de la disponibilité des services de localisation
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Services de localisation désactivés. Veuillez les activer dans les paramètres.')),
        );
        return;
      }

      // Gestion des permissions de localisation
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission de localisation refusée')),
          );
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Les permissions de localisation sont définitivement refusées. Veuillez les autoriser dans les paramètres.'),
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }
      
      // Obtenir la position avec un timeout raisonnable
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15)
      );
      
      // Mettre à jour les coordonnées [longitude, latitude] (format demandé par le backend)
      setState(() {
        _currentCoordinates = [position.longitude, position.latitude];
      });
      
      try {
        // Obtenir l'adresse à partir des coordonnées avec un format plus complet
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude
        );
        
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            // Format d'adresse plus complet
            _currentAddress = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}';
          });
        }
      } catch (geocodeError) {
        print('Erreur de géocodage: $geocodeError');
        // On garde les coordonnées même si le géocodage échoue
      }
      
      // Informer l'utilisateur que la localisation a réussi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Localisation récupérée avec succès')),
      );
    } catch (e) {
      print('Erreur de localisation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de localisation: $e')),
      );
      // Définir des valeurs par défaut en cas d'échec
      setState(() {
        // Coordonnées par défaut pour Dakar
        _currentCoordinates = [-17.4440, 14.6937];
        _currentAddress = "Dakar, Sénégal";
      });
    }
  }

  // Traiter les fichiers pour les preuves
  List<Map<String, dynamic>>? _processProofs() {
    List<Map<String, dynamic>> proofs = [];
    
    // Ajouter les images
    for (String imagePath in _selectedImagePaths) {
      proofs.add({
        'type': 'photo',
        'url': imagePath,
        'size': File(imagePath).lengthSync(),
      });
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
      // Désactiver temporairement la validation des preuves pour le débogage
      // if (_selectedImagePaths.isEmpty && _selectedVideoPath == null && _selectedAudioPath == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Veuillez ajouter au moins une preuve (photo, vidéo ou audio)')),
      //   );
      //   return;
      // }
      
      print('DEBUG - Submitting alert');
      print('DEBUG - Service ID: ${widget.service.id}');
      print('DEBUG - Selected category: $_selectedCategory');
      print('DEBUG - Coordinates: $_currentCoordinates');
      
      // Créer l'objet de requête d'alerte au format attendu par le backend
      final alertRequest = CreateAlertRequestModel(
        // L'ID du service est déjà l'ID MongoDB (_id) récupéré du backend
        // Le constructeur AvailableServiceModel.fromJson assigne json['_id'] à la propriété id
        serviceId: widget.service.id,
        category: _selectedCategory!.toLowerCase(), // Assurez-vous que la catégorie est en minuscules pour correspondre au backend
        description: _descriptionController.text,
        coordinates: _currentCoordinates,
        address: _currentAddress,
        isAnonymous: _isAnonymous,
        proofs: _processProofs(), priority: '', title: '',
      );

      print('DEBUG - Alert request created: ${alertRequest.toJson()}');
      
      // Afficher un message pour indiquer que l'alerte est en cours d'envoi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Envoi de l\'alerte en cours...')),
      );

      // Utiliser le BLoC pour envoyer l'alerte avec les fichiers
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
              onTap: () => _pickImages(),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission de localisation refusée')),
          );
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Les permissions de localisation sont refusées de façon permanente, nous ne pouvons pas demander les permissions.'),
          ),
        );
        return;
      }
      
      // Afficher un indicateur de chargement
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Position récupérée avec succès')),
      );
      
      print('DEBUG - Position récupérée: ${position.latitude}, ${position.longitude}');
      print('DEBUG - Adresse: $address');
      
    } catch (e) {
      // Gérer les erreurs
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

  // Carte de localisation sans affichage de carte (pour éviter les plantages)
  Widget _buildLocationCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: _getLocation, // Récupérer la position au clic
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
                      // Afficher l'adresse actuelle si disponible
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // S'assurer que les catégories sont disponibles
    if (widget.service.categories.isNotEmpty && _selectedCategory == null) {
      _selectedCategory = widget.service.categories.first;
    }
    
    return BlocProvider(
      create: (_) => di.sl<CreateAlertBloc>(),
      child: BlocConsumer<CreateAlertBloc, CreateAlertState>(
        listener: (context, state) {
          if (state is CreateAlertLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });

            if (state is CreateAlertSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Alerte envoyée avec succès !'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else if (state is CreateAlertError) {
              // Gérer de manière plus conviviale les erreurs de validation spécifiques
              String userFriendlyMessage = state.message;
              
              // Vérifier si c'est une erreur de validation des preuves
              if (state.message.contains('Au moins une preuve') ||
                  state.message.contains('proof') ||
                  state.message.toLowerCase().contains('validation') ||
                  state.message.contains('ServerException')) {
                userFriendlyMessage = 'Veuillez ajouter au moins une preuve (photo, vidéo ou audio) avant de soumettre votre alerte.';
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(userFriendlyMessage),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                  action: _selectedImagePaths.isEmpty && _selectedVideoPath == null && _selectedAudioPath == null
                    ? SnackBarAction(
                        label: 'Ajouter',
                        textColor: Colors.white,
                        onPressed: () {
                          // Scroll vers la section des preuves
                          Scrollable.ensureVisible(
                            context,
                            duration: const Duration(milliseconds: 500),
                            alignment: 0.5,
                          );
                        },
                      )
                    : null,
                ),
              );
            }
          }
        },
        builder: (context, state) {
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
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
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
                    const SizedBox(height: 16),
                    _buildProofButtons(),
                    
                    const SizedBox(height: 24),
                    
                    // Section de localisation
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
                    
                    // Option anonyme
                    const Text(
                      'Souhaitez-vous rester anonyme ?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildAnonymousOption(),
                    
                    const SizedBox(height: 32),
                    
                    // Bouton d'envoi
                    _buildSubmitButton(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}