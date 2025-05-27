import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/auth_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/signup_request_model.dart';

/// Implementation of the AuthRepository interface
class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;
  final NetworkInfo networkInfo;
  final FlutterSecureStorage secureStorage;
  final AuthService authService = AuthService();

  // Constants for secure storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthRepositoryImpl({
    required this.apiService,
    required this.networkInfo,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, AuthResponseModel>> login(LoginRequestModel loginRequest) async {
    if (await networkInfo.isConnected) {
      try {
        // Utiliser l'endpoint de login de la configuration API
        final response = await apiService.post(
          ApiConfig.loginEndpoint,
          body: loginRequest.toJson(),
        );

        final authResponse = AuthResponseModel.fromJson(response);

        // Store the token and user data in secure storage
        await secureStorage.write(key: _tokenKey, value: authResponse.token);
        await secureStorage.write(
          key: _userKey,
          value: authResponse.user.toString(), // In a real app, you'd want to use json.encode here
        );

        return Right(authResponse);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, AuthResponseModel>> signup(SignupRequestModel signupRequest) async {
    if (await networkInfo.isConnected) {
      try {
        // Utiliser l'endpoint d'inscription de la configuration API
        final response = await apiService.post(
          ApiConfig.signupEndpoint,
          body: signupRequest.toJson(),
        );

        final authResponse = AuthResponseModel.fromJson(response);

        // Store the token and user data in secure storage
        await secureStorage.write(key: _tokenKey, value: authResponse.token);
        await secureStorage.write(
          key: _userKey,
          value: authResponse.user.toString(), // In a real app, you'd want to use json.encode here
        );

        return Right(authResponse);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      // Clear the stored token and user data
      await secureStorage.delete(key: _tokenKey);
      await secureStorage.delete(key: _userKey);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to clear user data'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: _tokenKey);
  }
}
