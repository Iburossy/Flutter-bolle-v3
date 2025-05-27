import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../error/exceptions.dart';
import '../network/api_service.dart';

/// Service responsable de l'upload de fichiers vers le serveur
class FileUploadService {
  final ApiService apiService;
  final FlutterSecureStorage secureStorage;

  // Clé pour le token d'authentification
  static const String _tokenKey = 'auth_token';

  FileUploadService({
    required this.apiService,
    required this.secureStorage,
  });

  /// Upload un fichier image et retourne l'URL du fichier uploadé
  Future<String> uploadImage(File imageFile) async {
    return await _uploadFile(imageFile, '/uploads/images');
  }

  /// Upload un fichier vidéo et retourne l'URL du fichier uploadé
  Future<String> uploadVideo(File videoFile) async {
    return await _uploadFile(videoFile, '/uploads/videos');
  }

  /// Upload un fichier audio et retourne l'URL du fichier uploadé
  Future<String> uploadAudio(File audioFile) async {
    return await _uploadFile(audioFile, '/uploads/audios');
  }

  /// Méthode privée pour gérer l'upload de fichiers
  Future<String> _uploadFile(File file, String endpoint) async {
    try {
      // Récupérer le token d'authentification
      final token = await secureStorage.read(key: _tokenKey);
      
      if (token == null) {
        throw ServerException(message: 'User not authenticated');
      }

      // Préparer la requête multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${apiService.baseUrl}$endpoint'),
      );

      // Ajouter le fichier à la requête
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );

      // Ajouter les headers d'authentification
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Envoyer la requête
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        
        // Extraire l'URL du fichier uploadé
        if (responseData['url'] != null) {
          return responseData['url'];
        } else {
          throw ServerException(message: 'Invalid response format');
        }
      } else {
        throw ServerException(
          message: 'Failed to upload file: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
}
