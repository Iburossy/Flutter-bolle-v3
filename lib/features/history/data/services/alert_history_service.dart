import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';
import '../models/alert_history_model.dart';
import '../../../../core/config/api_config.dart';

class AlertHistoryService {
  final FlutterSecureStorage _secureStorage = GetIt.instance<FlutterSecureStorage>();
  final String _baseUrl = ApiConfig.baseUrl;
  final String _apiPrefix = ApiConfig.apiPrefix;

  // Récupérer toutes les alertes de l'utilisateur connecté
  Future<List<AlertHistoryModel>> getMyAlerts() async {
    try {
      print('DEBUG - AlertHistoryService: Début de getMyAlerts');
      // Récupérer le token d'authentification
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Non authentifié');
      }
      
      // Afficher les 20 premiers caractères du token pour débogage
      print('DEBUG - Token (premiers 20 caractères): ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      
      // Décoder le token JWT pour vérifier s'il contient bien l'ID utilisateur
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          // Décoder la partie payload (deuxième partie)
          String normalizedPayload = base64Url.normalize(parts[1]);
          final payloadJson = utf8.decode(base64Url.decode(normalizedPayload));
          final payload = json.decode(payloadJson);
          print('DEBUG - Token payload: $payload');
          print('DEBUG - User ID dans le token: ${payload['sub']}');
        }
      } catch (e) {
        print('DEBUG - Erreur lors du décodage du token: $e');
      }

      // Préparer les en-têtes avec le token
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Faire la requête à l'API
      final response = await http.get(
        Uri.parse('$_baseUrl$_apiPrefix/auth/alerts/me'),
        headers: headers,
      );
      
      print('URL de récupération des alertes: $_baseUrl$_apiPrefix/auth/alerts/me');
      print('Statut de la réponse: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');

      // Vérifier le code de statut
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> alertsJson = responseData['data'];
          return alertsJson
              .map((json) => AlertHistoryModel.fromJson(json))
              .toList();
        } else {
          throw Exception('Format de réponse invalide');
        }
      } else {
        throw Exception('Échec de la récupération des alertes: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des alertes: $e');
      throw Exception('Impossible de récupérer les alertes: $e');
    }
  }

  // Récupérer les détails d'une alerte spécifique
  Future<AlertHistoryModel> getAlertDetails(String alertId) async {
    try {
      // Récupérer le token d'authentification
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Non authentifié');
      }

      // Préparer les en-têtes avec le token
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Faire la requête à l'API
      final response = await http.get(
        Uri.parse('$_baseUrl$_apiPrefix/auth/alerts/$alertId'),
        headers: headers,
      );
      
      print('URL de récupération du détail de l\'alerte: $_baseUrl$_apiPrefix/auth/alerts/$alertId');
      print('Statut de la réponse: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');

      // Vérifier le code de statut
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          return AlertHistoryModel.fromJson(responseData['data']);
        } else {
          throw Exception('Format de réponse invalide');
        }
      } else {
        throw Exception('Échec de la récupération des détails de l\'alerte: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des détails de l\'alerte: $e');
      throw Exception('Impossible de récupérer les détails de l\'alerte: $e');
    }
  }
}
