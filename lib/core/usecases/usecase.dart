import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Abstract class for a Use Case
///
/// [Type] is the return type of the use case
/// [Params] is the parameter type for the use case
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Represents no parameters for a use case
class NoParams {
  const NoParams();
}
