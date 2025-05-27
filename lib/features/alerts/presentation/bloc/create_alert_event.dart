import 'package:equatable/equatable.dart';
import '../../data/models/create_alert_request_model.dart';

/// Events for the CreateAlert bloc
abstract class CreateAlertEvent extends Equatable {
  const CreateAlertEvent();

  @override
  List<Object?> get props => [];
}

/// Event to create an alert
class CreateAlert extends CreateAlertEvent {
  final CreateAlertRequestModel request;
  final List<String>? imagePaths;
  final String? videoPath;
  final String? audioPath;

  const CreateAlert({
    required this.request,
    this.imagePaths,
    this.videoPath,
    this.audioPath,
  });

  @override
  List<Object?> get props => [request, imagePaths, videoPath, audioPath];
}

/// Event to reset the create alert state
class ResetCreateAlert extends CreateAlertEvent {}
