import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/profile_model.dart';

/// Implémentation du repository de profil
class ProfileRepositoryImpl implements ProfileRepository {
  final ApiService apiService;
  final NetworkInfo networkInfo;
  final FlutterSecureStorage secureStorage;

  // Constantes pour les clés de stockage sécurisé
  static const String _tokenKey = 'auth_token';

  ProfileRepositoryImpl({
    required this.apiService,
    required this.networkInfo,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, ProfileModel>> getUserProfile() async {
    if (await networkInfo.isConnected) {
      try {
        // Récupérer le token d'authentification du stockage sécurisé
        final token = await secureStorage.read(key: _tokenKey);
        print('Profile - Token récupéré: ${token != null ? (token.length > 20 ? token.substring(0, 20) + "..." : token) : "null"}');
        
        if (token == null || token.isEmpty) {
          print('Profile - Token manquant ou vide');
          return Left(AuthFailure(message: 'Utilisateur non authentifié'));
        }

        // Endpoint pour récupérer le profil utilisateur
        print('Profile - Envoi de requête GET à: ${ApiConfig.profileEndpoint}');
        print('Profile - Headers: Content-Type: application/json, Authorization: Bearer ${token.substring(0, min(20, token.length))}...');
        
        final response = await apiService.get(
          ApiConfig.profileEndpoint,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        
        print('Profile - Réponse reçue: $response');

        // Vérifier la structure de la réponse et extraire les données de l'utilisateur
        Map<String, dynamic> userData;
        
        if (response['data'] != null && response['data']['user'] != null) {
          // Structure: { data: { user: {...} } }
          userData = response['data']['user'];
          print('Profile - Données utilisateur trouvées dans data.user');
        } else if (response['user'] != null) {
          // Structure: { user: {...} }
          userData = response['user'];
          print('Profile - Données utilisateur trouvées dans user');
        } else if (response['data'] != null) {
          // Structure: { data: {...} }
          userData = response['data'];
          print('Profile - Données utilisateur trouvées dans data');
        } else {
          // Aucune structure reconnue, utiliser la réponse complète
          userData = response;
          print('Profile - Structure de réponse non reconnue, utilisation de la réponse complète');
        }
        
        print('Profile - Données utilisateur: $userData');
        
        final profile = ProfileModel.fromJson(userData);
        print('Profile - Profil extrait: ${profile.fullName}');

        return Right(profile);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'Pas de connexion internet'));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> updateUserProfile(ProfileModel profile) async {
    if (await networkInfo.isConnected) {
      try {
        // Récupérer le token d'authentification du stockage sécurisé
        final token = await secureStorage.read(key: _tokenKey);
        
        if (token == null) {
          return Left(AuthFailure(message: 'Utilisateur non authentifié'));
        }

        // Endpoint pour mettre à jour le profil utilisateur
        final response = await apiService.post(
          ApiConfig.updateProfileEndpoint,
          body: profile.toJson(),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        final updatedProfile = ProfileModel.fromJson(response['data'] ?? response);

        return Right(updatedProfile);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'Pas de connexion internet'));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> updateProfilePicture(String imagePath) async {
    if (await networkInfo.isConnected) {
      try {
        // Récupérer le token d'authentification du stockage sécurisé
        final token = await secureStorage.read(key: _tokenKey);
        
        if (token == null) {
          return Left(AuthFailure(message: 'Utilisateur non authentifié'));
        }

        // Ici, nous devrions implémenter le téléchargement de l'image
        // Cela nécessiterait une méthode multipart/form-data qui n'est pas encore implémentée
        // dans notre ApiService. Pour l'instant, nous retournons une erreur.
        
        return Left(ServerFailure(message: 'Fonctionnalité non implémentée'));
        
        // Une implémentation future pourrait ressembler à ceci:
        /*
        final response = await apiService.uploadFile(
          '/users/profile/picture',
          filePath: imagePath,
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        final updatedProfile = ProfileModel.fromJson(response['data'] ?? response);

        return Right(updatedProfile);
        */
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'Pas de connexion internet'));
    }
  }
}
