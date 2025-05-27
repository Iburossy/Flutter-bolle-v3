import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/login_request_model.dart';
import '../repositories/auth_repository.dart';

/// Use case for logging in a user
class LoginUserUseCase {
  final AuthRepository repository;

  LoginUserUseCase(this.repository);

  /// Executes the login use case
  ///
  /// Takes a [LoginRequestModel] and returns an [AuthResponseModel] on success
  /// or a [Failure] on error
  Future<Either<Failure, AuthResponseModel>> call(LoginRequestModel params) {
    return repository.login(params);
  }
}
