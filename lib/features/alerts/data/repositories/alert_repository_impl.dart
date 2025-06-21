import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/alert_repository.dart';
import '../models/alert_model.dart';
import '../models/create_alert_request_model.dart';

/// Implementation of the AlertRepository interface
class AlertRepositoryImpl implements AlertRepository {
  final ApiService apiService;
  final NetworkInfo networkInfo;
  final FlutterSecureStorage secureStorage;
  final CloudinaryService cloudinaryService;
  
  // Flag pour désactiver temporairement l'upload pendant le débogage
  final bool uploadEnabled = true;

  // Constants for secure storage keys
  static const String _tokenKey = 'auth_token';

  AlertRepositoryImpl({
    required this.apiService,
    required this.networkInfo,
    required this.secureStorage,
    required this.cloudinaryService,
  });

  @override
  Future<Either<Failure, AlertModel>> createAlert(CreateAlertRequestModel alertRequest) async {
    print('DEBUG - AlertRepositoryImpl.createAlert - Starting');
    
    // Check network connectivity
    final isConnected = await networkInfo.isConnected;
    print('DEBUG - Network connected: $isConnected');
    
    if (!isConnected) {
      print('DEBUG - No internet connection');
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    
    try {
      // Get the auth token from secure storage
      print('DEBUG - Reading token from secure storage');
      final token = await secureStorage.read(key: _tokenKey);
      
      print('DEBUG - Token present: ${token != null}');
      if (token == null) {
        print('DEBUG - Authentication failure: No token found');
        return Left(AuthFailure(message: 'User not authenticated'));
      }

      // Logs pour le débogage
      print('DEBUG - Preparing alert submission');
      print('DEBUG - Token (first 10 chars): ${token.substring(0, token.length > 10 ? 10 : token.length)}...');
      final payload = alertRequest.toJson();
      print('DEBUG - Payload: $payload');
      print('DEBUG - Endpoint: ${ApiConfig.createAlertEndpoint}');
      print('DEBUG - Full URL: ${ApiConfig.getFullUrl(ApiConfig.createAlertEndpoint)}');

      // Vérifier s'il y a des preuves à télécharger
      print('DEBUG - Checking for proofs to upload');
      List<Map<String, dynamic>> proofs = [];
      
      if (payload.containsKey('proofs') && payload['proofs'] is List && (payload['proofs'] as List).isNotEmpty) {
        print('DEBUG - Found ${(payload['proofs'] as List).length} proofs to upload');
        
        // Télécharger chaque fichier de preuve
        for (var proof in payload['proofs']) {
          try {
            if (proof['url'] != null && proof['type'] != null) {
              // Chemin local du fichier
              final String localPath = proof['url'];
              final String proofType = proof['type'];
              
              print('DEBUG - Uploading file: $localPath of type: $proofType');
              
              // Télécharger le fichier avec Cloudinary
              final uploadResult = uploadEnabled 
                  ? await cloudinaryService.uploadFile(localPath, proofType)
                  : null;
              
              if (uploadResult != null) {
                // Ajouter les informations du fichier téléchargé à la liste des preuves
                // S'assurer que url est une chaîne de caractères et non un objet
                proofs.add({
                  'type': proofType,
                  'url': uploadResult['url'], // Déjà une chaîne de caractères
                  'size': uploadResult['size'] ?? proof['size'] ?? 0,
                });
                print('DEBUG - File uploaded successfully: ${uploadResult['url']}');
              } else {
                print('DEBUG - Failed to upload file: $localPath');
              }
            }
          } catch (e) {
            print('DEBUG - Error uploading file: $e');
          }
        }
      } else {
        print('DEBUG - No proofs to upload');
      }
      
      // Utiliser l'endpoint défini dans ApiConfig
      print('DEBUG - Sending POST request');
      try {
        print('DEBUG - About to send HTTP request to: ${ApiConfig.getFullUrl(ApiConfig.createAlertEndpoint)}');
        
        // Préparer le payload final avec les preuves téléchargées (s'il y en a)
        var finalPayload = Map<String, dynamic>.from(payload);
        
        if (proofs.isNotEmpty) {
          finalPayload['proofs'] = proofs;
          print('DEBUG - Including ${proofs.length} uploaded proofs in request');
        } else {
          // Si aucune preuve n'a été téléchargée avec succès, supprimer le champ proofs
          finalPayload.remove('proofs');
          print('DEBUG - No proofs included in request');
        }
        
        print('DEBUG - Sending request with final payload');
        final response = await apiService.post(
          ApiConfig.createAlertEndpoint,
          body: finalPayload,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        print('DEBUG - POST request completed successfully');
        print('DEBUG - Response from server: $response');
        
        // Si nous arrivons ici, la requête a réussi
        final alert = AlertModel.fromJson(response['data'] ?? response);
        return Right(alert);
      } catch (httpError) {
        print('DEBUG - HTTP request failed with error: $httpError');
        print('DEBUG - Try using direct http client');
        
        try {
          // Essayer avec le client http directement
          var client = http.Client();
          var uri = Uri.parse(ApiConfig.getFullUrl(ApiConfig.createAlertEndpoint));
          print('DEBUG - Sending direct HTTP request to $uri');
          
          // Utiliser le même traitement des preuves que dans la requête principale
          var directPayload = Map<String, dynamic>.from(payload);
          
          if (proofs.isNotEmpty) {
            directPayload['proofs'] = proofs;
            print('DEBUG - Including ${proofs.length} uploaded proofs in direct request');
          } else {
            directPayload.remove('proofs');
            print('DEBUG - No proofs included in direct request');
          }
          
          var directResponse = await client.post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(directPayload),
          ).timeout(Duration(seconds: 30));
          
          print('DEBUG - Direct HTTP response status: ${directResponse.statusCode}');
          print('DEBUG - Direct HTTP response body: ${directResponse.body}');
          client.close();
          
          // Si nous arrivons ici, la requête directe a réussi
          if (directResponse.statusCode >= 200 && directResponse.statusCode < 300) {
            try {
              final responseData = json.decode(directResponse.body);
              final alert = AlertModel.fromJson(responseData['data'] ?? responseData);
              return Right(alert);
            } catch (jsonError) {
              print('DEBUG - JSON decode error: $jsonError');
              throw ServerException(message: 'Failed to decode response: $jsonError');
            }
          } else {
            throw ServerException(message: 'HTTP error: ${directResponse.statusCode}');
          }
        } catch (directError) {
          print('DEBUG - Direct HTTP request failed: $directError');
          throw ServerException(message: 'Direct HTTP request failed: $directError');
        }
      }
      
    } on ServerException catch (e) {
      print('DEBUG - Server exception: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      print('DEBUG - General exception: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AlertModel>>> getAlerts() async {
    if (await networkInfo.isConnected) {
      try {
        // Get the auth token from secure storage
        final token = await secureStorage.read(key: _tokenKey);
        
        if (token == null) {
          return Left(AuthFailure(message: 'User not authenticated'));
        }

        // Assuming your API endpoint for getting alerts is '/alerts'
        final response = await apiService.get(
          '/alerts',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        final alertsJson = response['data'] as List<dynamic>? ?? [];
        final alerts = alertsJson
            .map((alertJson) => AlertModel.fromJson(alertJson))
            .toList();

        return Right(alerts);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, AlertModel>> getAlertById(String alertId) async {
    if (await networkInfo.isConnected) {
      try {
        // Get the auth token from secure storage
        final token = await secureStorage.read(key: _tokenKey);
        
        if (token == null) {
          return Left(AuthFailure(message: 'User not authenticated'));
        }

        // Assuming your API endpoint for getting an alert by ID is '/alerts/:id'
        final response = await apiService.get(
          '/alerts/$alertId',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        final alert = AlertModel.fromJson(response['data'] ?? response);

        return Right(alert);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }
  
  // La méthode _uploadFile a été remplacée par CloudinaryService.uploadFile
}
