import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../error/exceptions.dart';

/// Service for handling API requests
class ApiService {
  final http.Client client;
  final String baseUrl;

  ApiService({
    required this.client,
    String? baseUrl,
  }) : baseUrl = baseUrl ?? '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}';

  /// Performs a GET request to the specified endpoint
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final Uri uri = Uri.parse('$baseUrl$endpoint');
      print('GET Request to: $uri');
      final response = await client.get(
        uri,
        headers: headers ?? {'Content-Type': 'application/json'},
      );

      return _processResponse(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Performs a POST request to the specified endpoint
  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final Uri uri = Uri.parse('$baseUrl$endpoint');
      print('DEBUG - POST Request details:');
      print('DEBUG - URL: $uri');
      print('DEBUG - Headers: ${headers ?? {'Content-Type': 'application/json'}}');
      print('DEBUG - Body: ${json.encode(body)}');
      
      try {
        final response = await client.post(
          uri,
          body: json.encode(body),
          headers: headers ?? {'Content-Type': 'application/json'},
        );
        print('DEBUG - Response received: ${response.statusCode}');
        return _processResponse(response);
      } catch (httpError) {
        print('DEBUG - HTTP ERROR: $httpError');
        print('DEBUG - Stack trace: ${StackTrace.current}');
        throw ServerException(message: 'HTTP request failed: $httpError');
      }
    } catch (e) {
      print('DEBUG - GENERAL ERROR: $e');
      print('DEBUG - Stack trace: ${StackTrace.current}');
      throw ServerException(message: e.toString());
    }
  }

  /// Processes the HTTP response and returns the JSON data or throws an exception
  Map<String, dynamic> _processResponse(http.Response response) {
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        // Vérifier si le corps de la réponse est vide
        if (response.body.isEmpty) {
          return {'success': true, 'message': 'Operation successful'};
        }
        
        // Essayer de décoder le JSON
        final decoded = json.decode(response.body);
        
        // Vérifier si le résultat est bien un Map<String, dynamic>
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          // Si ce n'est pas un Map, créer un Map avec le résultat
          return {'data': decoded, 'success': true};
        }
      } catch (e) {
        print('Error decoding JSON: $e');
        // En cas d'erreur de décodage, retourner un Map par défaut
        return {'success': true, 'message': response.body};
      }
    } else {
      try {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['message'] ?? 'Unknown error occurred';
        
        if (response.statusCode == 401 || response.statusCode == 403) {
          throw AuthException(message: errorMessage);
        } else {
          throw ServerException(message: errorMessage);
        }
      } catch (e) {
        // Si le corps de l'erreur n'est pas un JSON valide
        throw ServerException(message: 'Server error: ${response.body}');
      }
    }
  }
}
