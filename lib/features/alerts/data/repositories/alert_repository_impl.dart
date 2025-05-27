import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
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

  // Constants for secure storage keys
  static const String _tokenKey = 'auth_token';

  AlertRepositoryImpl({
    required this.apiService,
    required this.networkInfo,
    required this.secureStorage,
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

      // Utiliser l'endpoint défini dans ApiConfig
      print('DEBUG - Sending POST request');
      try {
        print('DEBUG - About to send HTTP request to: ${ApiConfig.getFullUrl(ApiConfig.createAlertEndpoint)}');
        
        // Essayer avec une requête simplifiée sans les preuves pour tester
        var simplifiedPayload = Map<String, dynamic>.from(payload);
        simplifiedPayload.remove('proofs'); // Retirer les preuves pour tester
        
        print('DEBUG - Sending simplified request without proofs first');
        final response = await apiService.post(
          ApiConfig.createAlertEndpoint,
          body: simplifiedPayload,
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
          
          // Utiliser le même payload simplifié que précédemment
          var simplifiedPayload = Map<String, dynamic>.from(payload);
          simplifiedPayload.remove('proofs');
          
          var directResponse = await client.post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(simplifiedPayload),
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
}
