/// Constantes pour les chemins d'API
class ApiPaths {
  /// URL de base de l'API
  static const String baseUrl = 'http://localhost:3005/api';
  
  /// Authentification
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/profile';
  static const String updateProfile = '/auth/update-profile';
  
  /// Services
  static const String services = '/services';
  
  /// Alertes
  static const String alerts = '/alerts';
  static const String alertsMe = '/alerts/me';
  static const String alertsNearby = '/alerts/nearby';
  
  /// Commentaires
  static const String comments = '/comments';
}
