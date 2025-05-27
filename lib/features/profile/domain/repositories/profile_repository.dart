import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/profile_model.dart';

/// Interface pour le repository de profil
abstract class ProfileRepository {
  /// Récupère le profil de l'utilisateur actuellement connecté
  Future<Either<Failure, ProfileModel>> getUserProfile();
  
  /// Met à jour le profil de l'utilisateur
  Future<Either<Failure, ProfileModel>> updateUserProfile(ProfileModel profile);
  
  /// Met à jour la photo de profil de l'utilisateur
  Future<Either<Failure, ProfileModel>> updateProfilePicture(String imagePath);
}
