import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/alert_model.dart';
import '../../data/models/create_alert_request_model.dart';

/// Interface for the alert repository
abstract class AlertRepository {
  /// Creates a new alert
  Future<Either<Failure, AlertModel>> createAlert(CreateAlertRequestModel alertRequest);
  
  /// Gets all alerts for the authenticated user
  Future<Either<Failure, List<AlertModel>>> getAlerts();
  
  /// Gets an alert by its ID
  Future<Either<Failure, AlertModel>> getAlertById(String alertId);
}
