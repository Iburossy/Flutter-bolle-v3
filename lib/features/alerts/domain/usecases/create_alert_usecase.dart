import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/alert_model.dart';
import '../../data/models/create_alert_request_model.dart';
import '../repositories/alert_repository.dart';

/// UseCase for creating a new alert
class CreateAlertUseCase implements UseCase<AlertModel, CreateAlertRequestModel> {
  final AlertRepository repository;

  CreateAlertUseCase(this.repository);

  @override
  Future<Either<Failure, AlertModel>> call(CreateAlertRequestModel params) async {
    return await repository.createAlert(params);
  }
}
