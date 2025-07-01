import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';
import '../models/alert_history_model.dart';
import '../../../../core/config/api_config.dart';
import '../../../profile/domain/repositories/profile_repository.dart';

class AlertHistoryService {
  final FlutterSecureStorage _secureStorage = GetIt.instance<FlutterSecureStorage>();
  final String _baseUrl = ApiConfig.baseUrl;
  final String _apiPrefix = ApiConfig.apiPrefix;
  final ProfileRepository _profileRepository = GetIt.instance<ProfileRepository>();

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

  // Ajouter un commentaire à une alerte
Future<AlertHistoryModel> addComment(String alertId, String comment) async {
  try {
    // Récupérer le token d'authentification
    final token = await _secureStorage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('Non authentifié');
    }
    
    // Récupérer le profil utilisateur pour obtenir l'ID
    final profileResult = await _profileRepository.getUserProfile();
    
    String? userId;
    profileResult.fold(
      (failure) => throw Exception('Impossible de récupérer le profil utilisateur: ${failure.message}'),
      (profile) => userId = profile.id
    );
    
    if (userId == null) {
      throw Exception('Identifiant utilisateur manquant');
    }

    // Préparer les en-têtes avec le token ET la clé API pour l'authentification inter-service
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'x-service-key': 'bolle-inter-service-secure-key-2025',  // Ajout de la clé API requise
    };

    // Préparer les données du commentaire pour hygiene-service
    final data = {
      'text': comment,
      'authorType': 'citizen',
      'citizenId': userId,
    };
    
    // URL du service hygiene (port 3008)
    // Note: Utiliser 10.0.2.2 pour l'émulateur Android, localhost pour les tests réels
    final hygieneServiceUrl = 'http://10.0.2.2:3008'; 
    final commentUrl = '$hygieneServiceUrl/api/external/alerts/$alertId/comments';

    // Faire la requête directement au hygiene-service
    final response = await http.post(
      Uri.parse(commentUrl),
      headers: headers,
      body: json.encode(data),
    );
    
    print('URL d\'ajout de commentaire: $commentUrl');
    print('Payload: ${json.encode(data)}');
    print('Headers: ${headers.toString()}');  // Log pour vérifier que le header x-service-key est bien envoyé
    print('Statut de la réponse: ${response.statusCode}');
    print('Corps de la réponse: ${response.body}');

    // Vérifier le code de statut
    if (response.statusCode == 201 || response.statusCode == 200) {
      // Récupérer l'alerte mise à jour après l'ajout du commentaire
      // Comme nous avons envoyé directement à hygiene-service, on doit refaire
      // un appel pour récupérer l'alerte mise à jour via citizen-service
      final alertResponse = await getAlertDetails(alertId);
      return alertResponse;
    } else {
      throw Exception('Échec de l\'ajout du commentaire: ${response.statusCode}');
    }
  } catch (e) {
    print('Erreur lors de l\'ajout du commentaire: $e');
    throw Exception('Impossible d\'ajouter un commentaire: $e');
  }
}
}
