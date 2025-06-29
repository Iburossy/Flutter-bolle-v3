import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration des endpoints API
class ApiConfig {
  /// URL de base de l'API
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3001';
  
  /// Préfixe de l'API
  static String get apiPrefix => dotenv.env['API_PREFIX'] ?? '/api';
  
  /// Endpoints d'authentification
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/register';
  static const String loginAnonymousEndpoint = '/auth/login-anonymous';
  static const String verifyTokenEndpoint = '/auth/verify-token';
  static const String verifyAccountEndpoint = '/auth/verify-account';
  static const String resendVerificationCodesEndpoint = '/auth/resend-verification-codes';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  static const String logoutEndpoint = '/auth/logout';
  static const String profileEndpoint = '/auth/profile';
  static const String updateProfileEndpoint = '/auth/update-profile';
  
  /// Endpoints des alertes
  static const String alertsEndpoint = '/auth/alerts';
  static const String createAlertEndpoint = '/auth/alerts';
  
  /// Endpoints d'upload de fichiers
  static const String uploadFileEndpoint = '/auth/alerts/upload';
  static const String uploadMultipleFilesEndpoint = '/auth/alerts/uploads';
  static const String deleteFileEndpoint = '/auth/alerts/upload';
  
  /// Construit l'URL complète pour un endpoint donné
  static String getFullUrl(String endpoint) {
    return '$baseUrl$apiPrefix$endpoint';
  }
}
