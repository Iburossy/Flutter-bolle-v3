import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/login_request_model.dart';
import '../../data/models/signup_request_model.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Logs in a user with the provided credentials
  ///
  /// Returns an [AuthResponseModel] on success or a [Failure] on error
  Future<Either<Failure, AuthResponseModel>> login(LoginRequestModel loginRequest);

  /// Signs up a new user with the provided information
  ///
  /// Returns an [AuthResponseModel] on success or a [Failure] on error
  Future<Either<Failure, AuthResponseModel>> signup(SignupRequestModel signupRequest);

  /// Logs out the current user
  ///
  /// Returns true on success or a [Failure] on error
  Future<Either<Failure, bool>> logout();

  /// Checks if a user is currently logged in
  ///
  /// Returns true if a user is logged in, false otherwise
  Future<bool> isLoggedIn();

  /// Gets the current user's authentication token
  ///
  /// Returns the token if available, null otherwise
  Future<String?> getToken();
}
