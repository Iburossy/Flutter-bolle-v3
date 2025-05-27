import 'package:equatable/equatable.dart';
import 'user_model.dart';

/// Model class representing an authentication response from the API
class AuthResponseModel extends Equatable {
  final UserModel user;
  final String token;
  final bool success;
  final String message;

  const AuthResponseModel({
    required this.user,
    required this.token,
    required this.success,
    required this.message,
  });

  /// Creates an AuthResponseModel from a JSON map
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Ajouter un log pour déboguer la structure de la réponse
    print('Auth Response JSON: $json');
    
    // Gérer différentes structures de réponse possibles du backend
    Map<String, dynamic> data = json;
    
    // Vérifier si les données sont dans un objet 'data'
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      data = json['data'];
      print('Using data field: $data');
    }
    
    // Pour le champ user, vérifier s'il est un objet ou une chaîne
    UserModel userModel;
    
    // Vérifier si l'utilisateur est dans la réponse
    if (data['user'] is Map<String, dynamic>) {
      userModel = UserModel.fromJson(data['user']);
      print('User found in response');
    } else {
      // Créer un modèle utilisateur minimal si aucun utilisateur n'est trouvé
      userModel = UserModel(
        id: 'temp-id',
        fullName: 'Utilisateur',
        createdAt: DateTime.now(),
      );
      print('No user found in response, using default');
    }
    
    // Pour le champ token, vérifier s'il est sous forme de 'token' ou 'tokens'
    String tokenValue = '';
    
    // Vérifier si le token est directement dans la réponse
    if (data['token'] != null) {
      tokenValue = data['token'];
      print('Token found directly: ${tokenValue.substring(0, 20)}...');
    } 
    // Vérifier si les tokens sont dans un objet 'tokens'
    else if (data['tokens'] != null) {
      // Si tokens est un objet avec accessToken
      if (data['tokens'] is Map<String, dynamic> && data['tokens']['accessToken'] != null) {
        tokenValue = data['tokens']['accessToken'];
        print('Token found in tokens.accessToken: ${tokenValue.substring(0, 20)}...');
      }
      // Si tokens est une chaîne
      else if (data['tokens'] is String) {
        tokenValue = data['tokens'];
        print('Token found in tokens string: ${tokenValue.substring(0, 20)}...');
      }
    }
    
    // Si aucun token n'a été trouvé
    if (tokenValue.isEmpty) {
      print('No token found in response');
    }
    
    return AuthResponseModel(
      user: userModel,
      token: tokenValue,
      success: json['success'] ?? true,
      message: json['message'] ?? 'Authentication successful',
    );
  }

  /// Converts this AuthResponseModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'success': success,
      'message': message,
    };
  }

  @override
  List<Object> get props => [user, token, success, message];
}
