import 'package:equatable/equatable.dart';
import '../../data/models/alert_model.dart';

/// States for the CreateAlert bloc
abstract class CreateAlertState extends Equatable {
  const CreateAlertState();

  @override
  List<Object?> get props => [];
}

/// Initial state for create alert
class CreateAlertInitial extends CreateAlertState {}

/// Loading state during alert creation
class CreateAlertLoading extends CreateAlertState {}

/// Success state after alert is created
class CreateAlertSuccess extends CreateAlertState {
  final AlertModel alert;

  const CreateAlertSuccess(this.alert);

  @override
  List<Object?> get props => [alert];
}

/// Error state when alert creation fails
class CreateAlertError extends CreateAlertState {
  final String message;

  const CreateAlertError(this.message);

  @override
  List<Object?> get props => [message];
}
