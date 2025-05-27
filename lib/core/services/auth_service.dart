import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service pour gérer l'authentification et les tokens
class AuthService {
  final FlutterSecureStorage _secureStorage;
  
  // Constantes pour les clés de stockage sécurisé
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // Singleton pattern
  static final AuthService _instance = AuthService._internal(const FlutterSecureStorage());
  
  factory AuthService() => _instance;
  
  AuthService._internal(this._secureStorage);
  
  /// Stocke le token d'authentification
  Future<void> saveToken(String token) async {
    if (token.isNotEmpty) {
      print('Saving token: ${token.substring(0, min(20, token.length))}...');
      await _secureStorage.write(key: tokenKey, value: token);
    } else {
      print('Warning: Attempted to save empty token');
    }
  }
  
  /// Récupère le token d'authentification
  Future<String?> getToken() async {
    final token = await _secureStorage.read(key: tokenKey);
    if (token != null && token.isNotEmpty) {
      print('Retrieved token: ${token.substring(0, min(20, token.length))}...');
    } else {
      print('No token found or empty token');
    }
    return token;
  }
  
  /// Vérifie si l'utilisateur est authentifié
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  /// Supprime le token d'authentification (déconnexion)
  Future<void> clearToken() async {
    await _secureStorage.delete(key: tokenKey);
    print('Token cleared');
  }
  
  /// Stocke les données utilisateur
  Future<void> saveUserData(String userData) async {
    await _secureStorage.write(key: userKey, value: userData);
  }
  
  /// Récupère les données utilisateur
  Future<String?> getUserData() async {
    return await _secureStorage.read(key: userKey);
  }
  
  /// Supprime les données utilisateur
  Future<void> clearUserData() async {
    await _secureStorage.delete(key: userKey);
  }
  
  /// Déconnecte l'utilisateur (supprime token et données)
  Future<void> logout() async {
    await clearToken();
    await clearUserData();
  }
  
  /// Retourne les en-têtes d'authentification pour les requêtes API
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }
  
  // Helper function
  static int min(int a, int b) => a < b ? a : b;
}
