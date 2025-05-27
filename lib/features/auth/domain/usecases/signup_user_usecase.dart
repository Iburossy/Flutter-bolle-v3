import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/signup_request_model.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing up a new user
class SignupUserUseCase {
  final AuthRepository repository;

  SignupUserUseCase(this.repository);

  /// Executes the signup use case
  ///
  /// Takes a [SignupRequestModel] and returns an [AuthResponseModel] on success
  /// or a [Failure] on error
  Future<Either<Failure, AuthResponseModel>> call(SignupRequestModel params) {
    return repository.signup(params);
  }
}
