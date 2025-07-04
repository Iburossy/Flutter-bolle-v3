import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../core/constants/api_paths.dart';
import '../../../alerts/data/models/alert_model.dart';
import '../../../services/data/models/service_model.dart';
import '../../../auth/data/models/user_model.dart';

/// Service pour récupérer des données dynamiques pour le chatbot
class ChatbotDataService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  /// Récupérer le profil utilisateur connecté
  Future<UserModel?> getUserProfile() async {
    try {
      final token = await _secureStorage.read(key: 'token');
      if (token == null) return null;
      
      final response = await http.get(
        Uri.parse('${ApiPaths.baseUrl}${ApiPaths.profile}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserModel.fromJson(data);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Récupérer la liste des services disponibles
  Future<List<ServiceModel>> getAvailableServices() async {
    try {
      final token = await _secureStorage.read(key: 'token');
      if (token == null) return [];
      
      final response = await http.get(
        Uri.parse('${ApiPaths.baseUrl}${ApiPaths.services}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((item) => ServiceModel.fromJson(item)).toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
  
  /// Récupérer les alertes de l'utilisateur
  /// Retourne toutes les alertes de l'utilisateur
  Future<List<AlertModel>> getUserAlerts() async {
    try {
      final token = await _secureStorage.read(key: 'token');
      if (token == null) return [];
      
      final response = await http.get(
        Uri.parse('${ApiPaths.baseUrl}${ApiPaths.alertsMe}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((item) => AlertModel.fromJson(item)).toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
  
  /// Récupérer les détails d'une alerte spécifique
  Future<AlertModel?> getAlertDetails(String alertId) async {
    try {
      final token = await _secureStorage.read(key: 'token');
      if (token == null) return null;
      
      final response = await http.get(
        Uri.parse('${ApiPaths.baseUrl}${ApiPaths.alerts}/$alertId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AlertModel.fromJson(data);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Récupérer le nombre d'alertes signalées aujourd'hui
  Future<int> getTodaysAlertsCount() async {
    // Donnée statique pour le développement
    await Future.delayed(const Duration(milliseconds: 300));
    return 5; 
  }

  /// Récupérer les types d'alertes les plus fréquents
  Future<List<String>> getFrequentAlerts({String? location}) async {
    // Donnée statique pour le développement
    await Future.delayed(const Duration(milliseconds: 400));
    if (location != null && location.toLowerCase().contains('parcelles')) {
      return ['insécurité', 'coupures d\'eau'];
    }
    return ['déchets', 'bruits', 'stationnement illégal'];
  }

  /// Récupérer les zones avec une concentration d'accidents
  Future<List<String>> getAccidentZones() async {
    // Donnée statique pour le développement
    await Future.delayed(const Duration(milliseconds: 500));
    return ['Vdn', 'Autoroute à péage', 'Rond-point Liberté 6'];
  }

  /// Récupérer des informations sur la sécurité et l'eau pour une zone
  Future<String> getSecurityAndWaterInfo(String location) async {
    // Donnée statique pour le développement
    await Future.delayed(const Duration(milliseconds: 350));
    if (location.toLowerCase().contains('parcelles')) {
      return "À Parcelles Assainies, des patrouilles de police ont été renforcées récemment. Cependant, des coupures d'eau sont souvent signalées dans le secteur.";
    }
    return "Je n'ai pas d'informations spécifiques sur la sécurité ou l'eau pour $location.";
  }

  // --- Nouvelles méthodes pour les réponses dynamiques ---

  /// Trouver le service compétent pour un type de problème
  Future<String> getServiceForProblem(String problemType) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final problem = problemType.toLowerCase();
    if (problem.contains('vol') || problem.contains('agression')) {
      return 'Police';
    } else if (problem.contains('déchet') || problem.contains('insalubrité')) {
      return 'Service d\'hygiène';
    } else if (problem.contains('incendie')) {
      return 'Sapeurs-pompiers';
    }
    return 'Je ne suis pas sûr, mais vous pouvez contacter le service d\'assistance générale.';
  }

  /// Récupérer les compétences d'un service
  Future<String> getServiceCompetence(String serviceName) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final service = serviceName.toLowerCase();
    if (service.contains('police')) {
      return 'La Police gère la sécurité publique, les vols, les agressions et la circulation.';
    } else if (service.contains('hygiène')) {
      return 'Le service d\'hygiène s\'occupe de la propreté, de la gestion des déchets et de la salubrité publique.';
    } else if (service.contains('gendarmerie')) {
      return 'La Gendarmerie assure la sécurité dans les zones rurales et périurbaines.';
    }
    return 'Je n\'ai pas d\'informations sur les compétences de ce service.';
  }

  /// Récupérer les horaires d'un service
  Future<String> getServiceHours(String serviceName) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final service = serviceName.toLowerCase();
    if (service.contains('police') || service.contains('gendarmerie')) {
      return 'Les services de police et de gendarmerie sont disponibles 24h/24 et 7j/7.';
    } else if (service.contains('hygiène')) {
      return 'Le service d\'hygiène est généralement ouvert de 8h à 17h, du lundi au vendredi.';
    }
    return 'Je ne connais pas les horaires de ce service.';
  }

  /// Récupérer le statut d'une alerte par sa date
  Future<String> getAlertStatusByDate(String date) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simule une recherche d'alerte
    return 'L\'alerte que vous avez mentionnée pour le $date est actuellement en cours de traitement par nos équipes.';
  }
  
  /// Récupérer les informations d'un service spécifique
  Future<ServiceModel?> getServiceDetails(String serviceId) async {
    try {
      final token = await _secureStorage.read(key: 'token');
      if (token == null) return null;
      
      final response = await http.get(
        Uri.parse('${ApiPaths.baseUrl}${ApiPaths.services}/$serviceId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ServiceModel.fromJson(data);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Récupérer les alertes récentes à proximité
  Future<List<AlertModel>> getNearbyAlerts(double latitude, double longitude, double radius) async {
    try {
      final token = await _secureStorage.read(key: 'token');
      if (token == null) return [];
      
      final response = await http.get(
        Uri.parse('${ApiPaths.baseUrl}${ApiPaths.alerts}/nearby?lat=$latitude&lng=$longitude&radius=$radius'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((item) => AlertModel.fromJson(item)).toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
  
  /// Récupérer les statistiques des alertes de l'utilisateur
  /// Retourne un Map avec le nombre d'alertes par statut
  Future<Map<String, dynamic>> getUserAlertStats() async {
    try {
      final userAlerts = await getUserAlerts();
      if (userAlerts.isEmpty) {
        return {
          'total': 0,
          'pending': 0,
          'inProgress': 0,
          'resolved': 0,
        };
      }
      
      // Calculer les statistiques
      int pending = 0;
      int inProgress = 0;
      int resolved = 0;
      
      for (final alert in userAlerts) {
        switch (alert.status) {
          case 'pending':
            pending++;
            break;
          case 'in_progress':
            inProgress++;
            break;
          case 'resolved':
            resolved++;
            break;
        }
      }
      
      return {
        'total': userAlerts.length,
        'pending': pending,
        'inProgress': inProgress,
        'resolved': resolved,
        'lastAlert': userAlerts.isNotEmpty ? userAlerts.first : null,
      };
    } catch (e) {
      return {
        'total': 0,
        'pending': 0,
        'inProgress': 0,
        'resolved': 0,
      };
    }
  }
  
  /// Récupérer les données de conversation précédentes
  /// Permet de maintenir un contexte conversationnel
  Future<List<Map<String, dynamic>>> getConversationHistory() async {
    try {
      final String? history = await _secureStorage.read(key: 'chatbot_history');
      if (history == null) return [];
      
      final List<dynamic> data = json.decode(history);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  /// Sauvegarder l'historique des conversations
  /// Permet de maintenir le contexte entre les sessions
  Future<bool> saveConversationHistory(List<Map<String, dynamic>> history) async {
    try {
      // Limiter l'historique aux 20 derniers messages pour éviter un stockage trop important
      final limitedHistory = history.length > 20 ? history.sublist(history.length - 20) : history;
      await _secureStorage.write(key: 'chatbot_history', value: json.encode(limitedHistory));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Récupérer les préférences utilisateur pour le chatbot
  Future<Map<String, dynamic>> getChatbotPreferences() async {
    try {
      final String? prefs = await _secureStorage.read(key: 'chatbot_preferences');
      if (prefs == null) {
        // Préférences par défaut
        return {
          'useUserName': true,
          'suggestionsEnabled': true,
          'showAlertUpdates': true,
          'preferredTopics': [],
        };
      }
      
      return Map<String, dynamic>.from(json.decode(prefs));
    } catch (e) {
      // Préférences par défaut en cas d'erreur
      return {
        'useUserName': true,
        'suggestionsEnabled': true,
        'showAlertUpdates': true,
        'preferredTopics': [],
      };
    }
  }

  /// Sauvegarder les préférences utilisateur pour le chatbot
  Future<bool> saveChatbotPreferences(Map<String, dynamic> preferences) async {
    try {
      await _secureStorage.write(key: 'chatbot_preferences', value: json.encode(preferences));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Récupérer les sujets d'intérêt basés sur l'historique des alertes
  Future<List<String>> getUserInterests() async {
    try {
      final alerts = await getUserAlerts();
      final Map<String, int> categories = {};
      
      // Compter les occurrences des catégories d'alertes
      for (final alert in alerts) {
        final category = alert.category ?? "Autre";
        categories[category] = (categories[category] ?? 0) + 1;
      }
      
      // Trier les catégories par nombre d'occurrences
      final sortedCategories = categories.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      // Retourner les 3 catégories les plus fréquentes
      return sortedCategories.take(3).map((e) => e.key).toList();
    } catch (e) {
      return [];
    }
  }
}
