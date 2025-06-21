import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../error/exceptions.dart';
import './cloudinary_service.dart';

/// Service responsable de l'upload de fichiers vers Cloudinary
class FileUploadService {
  final CloudinaryService cloudinaryService;
  final FlutterSecureStorage secureStorage;

  // Clé pour le token d'authentification
  static const String _tokenKey = 'auth_token';

  FileUploadService({
    required this.cloudinaryService,
    required this.secureStorage,
  });

  /// Upload un fichier image et retourne l'URL du fichier uploadé
  Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    return await _uploadFile(imageFile, 'photo');
  }

  /// Upload un fichier vidéo et retourne l'URL du fichier uploadé
  Future<Map<String, dynamic>> uploadVideo(File videoFile) async {
    return await _uploadFile(videoFile, 'video');
  }

  /// Upload un fichier audio et retourne l'URL du fichier uploadé
  Future<Map<String, dynamic>> uploadAudio(File audioFile) async {
    return await _uploadFile(audioFile, 'audio');
  }

  /// Méthode privée pour gérer l'upload de fichiers via Cloudinary
  Future<Map<String, dynamic>> _uploadFile(File file, String fileType) async {
    try {
      print('DEBUG - FileUploadService: Starting upload of $fileType file');
      
      // Vérifier l'authentification (optionnel, car Cloudinary utilise un preset public)
      final token = await secureStorage.read(key: _tokenKey);
      
      if (token == null) {
        print('WARNING - FileUploadService: User not authenticated but proceeding');
      }

      // Upload via CloudinaryService
      final uploadResult = await cloudinaryService.uploadFile(file.path, fileType);
      
      if (uploadResult != null) {
        print('DEBUG - FileUploadService: File uploaded successfully to ${uploadResult['url']}');
        return uploadResult;
      } else {
        throw ServerException(message: 'Failed to upload file to Cloudinary');
      }
    } catch (e) {
      print('ERROR - FileUploadService: Upload failed - $e');
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  /// Méthode pour extraire uniquement l'URL d'un résultat d'upload (pour compatibilité avec code existant)
  Future<String> uploadImageAndGetUrl(File imageFile) async {
    final result = await uploadImage(imageFile);
    return result['url'];
  }

  /// Méthode pour extraire uniquement l'URL d'un résultat d'upload (pour compatibilité avec code existant)
  Future<String> uploadVideoAndGetUrl(File videoFile) async {
    final result = await uploadVideo(videoFile);
    return result['url'];
  }

  /// Méthode pour extraire uniquement l'URL d'un résultat d'upload (pour compatibilité avec code existant)
  Future<String> uploadAudioAndGetUrl(File audioFile) async {
    final result = await uploadAudio(audioFile);
    return result['url'];
  }
}


