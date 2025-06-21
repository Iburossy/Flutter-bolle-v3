import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  final String cloudName;
  final String uploadPreset;
  late CloudinaryPublic _cloudinary;

  CloudinaryService({
    required this.cloudName,
    required this.uploadPreset,
  }) {
    _cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);
  }

  /// Upload un fichier à Cloudinary
  /// Retourne un Map contenant l'URL et le public_id du fichier uploadé
  /// ou null en cas d'échec
  Future<Map<String, dynamic>?> uploadFile(String filePath, String fileType) async {
    try {
      print('DEBUG - CloudinaryService: Starting upload for $filePath');
      
      final file = File(filePath);
      if (!await file.exists()) {
        print('DEBUG - CloudinaryService: File not found at $filePath');
        return null;
      }

      // Déterminer le type de ressource en fonction du type de fichier
      CloudinaryResourceType resourceType;
      if (fileType == 'photo') {
        resourceType = CloudinaryResourceType.Image;
      } else if (fileType == 'video') {
        resourceType = CloudinaryResourceType.Video;
      } else if (fileType == 'audio') {
        resourceType = CloudinaryResourceType.Auto;
      } else {
        resourceType = CloudinaryResourceType.Auto;
      }

      // Upload du fichier
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: resourceType,
          folder: 'media', // Dossier configuré dans votre upload preset
        ),
      );

      print('DEBUG - CloudinaryService: File uploaded successfully to ${response.secureUrl}');
      print('DEBUG - CloudinaryService: Public ID: ${response.publicId}');
      
      return {
        'url': response.secureUrl,
        'public_id': response.publicId,
        'resource_type': resourceType.toString().split('.').last.toLowerCase(),
        'size': await file.length(),
      };
    } catch (e) {
      print('ERROR - CloudinaryService: Failed to upload file: $e');
      return null;
    }
  }
}
