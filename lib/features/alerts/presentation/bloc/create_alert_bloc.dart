import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/file_upload_service.dart';
import '../../domain/usecases/create_alert_usecase.dart';
import 'create_alert_event.dart';
import 'create_alert_state.dart';

/// BLoC for handling alert creation
class CreateAlertBloc extends Bloc<CreateAlertEvent, CreateAlertState> {
  final CreateAlertUseCase createAlertUseCase;
  final FileUploadService fileUploadService;

  CreateAlertBloc({
    required this.createAlertUseCase,
    required this.fileUploadService,
  }) : super(CreateAlertInitial()) {
    on<CreateAlert>(_onCreateAlert);
    on<ResetCreateAlert>(_onResetCreateAlert);
  }

  Future<void> _onCreateAlert(
    CreateAlert event,
    Emitter<CreateAlertState> emit,
  ) async {
    emit(CreateAlertLoading());

    try {
      // Liste pour stocker les preuves avec leurs URLs et types
      final List<Map<String, dynamic>> proofs = [];

      // Upload des images si présentes
      if (event.imagePaths != null && event.imagePaths!.isNotEmpty) {
        for (final imagePath in event.imagePaths!) {
          final imageFile = File(imagePath);
          // Utiliser la méthode qui retourne directement une chaîne
          final imageUrl = await fileUploadService.uploadImageAndGetUrl(imageFile);
          proofs.add({
            'type': 'photo',
            'url': imageUrl, // Maintenant c'est une chaîne simple
            'size': imageFile.lengthSync(),
          });
        }
      }

      // Upload de la vidéo si présente
      if (event.videoPath != null) {
        final videoFile = File(event.videoPath!);
        // Utiliser la méthode qui retourne directement une chaîne
        final videoUrl = await fileUploadService.uploadVideoAndGetUrl(videoFile);
        proofs.add({
          'type': 'video',
          'url': videoUrl, // Maintenant c'est une chaîne simple
          'size': videoFile.lengthSync(),
        });
      }

      // Upload de l'audio si présent
      if (event.audioPath != null) {
        final audioFile = File(event.audioPath!);
        // Utiliser la méthode qui retourne directement une chaîne
        final audioUrl = await fileUploadService.uploadAudioAndGetUrl(audioFile);
        proofs.add({
          'type': 'audio',
          'url': audioUrl, // Maintenant c'est une chaîne simple
          'size': audioFile.lengthSync(),
        });
      }

      // Créer une copie de la requête avec les preuves uploadées
      final updatedRequest = event.request.copyWith(
        proofs: proofs.isNotEmpty ? proofs : null,
      );

      // Envoyer la requête au backend
      final result = await createAlertUseCase(updatedRequest);

      result.fold(
        (failure) => emit(CreateAlertError(failure.message)),
        (alert) => emit(CreateAlertSuccess(alert)),
      );
    } catch (e) {
      emit(CreateAlertError(e.toString()));
    }
  }

  void _onResetCreateAlert(
    ResetCreateAlert event,
    Emitter<CreateAlertState> emit,
  ) {
    emit(CreateAlertInitial());
  }
}
