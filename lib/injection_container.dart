import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Feature: Auth
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_user_usecase.dart';
import 'features/auth/domain/usecases/signup_user_usecase.dart';

// Feature: Profile
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';

// Feature: Alerts
import 'features/alerts/data/repositories/alert_repository_impl.dart';
import 'features/alerts/domain/repositories/alert_repository.dart';
import 'features/alerts/domain/usecases/create_alert_usecase.dart';
import 'features/alerts/presentation/bloc/create_alert_bloc.dart';

// Core
import 'core/network/api_service.dart';
import 'core/network/network_info.dart';
import 'core/services/file_upload_service.dart';
import 'core/services/cloudinary_service.dart';
import 'core/services/location_service.dart';

// Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Use cases
  sl.registerLazySingleton(() => LoginUserUseCase(sl()));
  sl.registerLazySingleton(() => SignupUserUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      apiService: sl(),
      networkInfo: sl(),
      secureStorage: sl(),
    ),
  );
  
  //! Features - Profile
  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      apiService: sl(),
      networkInfo: sl(),
      secureStorage: sl(),
    ),
  );

  //! Features - Alerts
  // Bloc
  sl.registerFactory(() => CreateAlertBloc(
    createAlertUseCase: sl(),
    fileUploadService: sl(),
  ));
  
  // Use cases
  sl.registerLazySingleton(() => CreateAlertUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AlertRepository>(
    () => AlertRepositoryImpl(
      apiService: sl(),
      networkInfo: sl(),
      secureStorage: sl(),
      cloudinaryService: sl(),
    ),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton(() => ApiService(client: sl()));
  sl.registerLazySingleton(() => FileUploadService(
    cloudinaryService: sl(),
    secureStorage: sl(),
  ));
  
  // Service Cloudinary
  sl.registerLazySingleton(() => CloudinaryService(
    cloudName: 'dpqayer6b', // Corrigé: nom du cloud correct
    uploadPreset: 'bolleMedia', // Corrigé: preset d'upload correct
  ));
  
  // Service de localisation Google Maps
  sl.registerLazySingleton(() => LocationService(
    apiKey: 'AIzaSyCAmPMShcxxhCDSpSv3lD5Ioq98sDqeyYY',
  ));

  //! External
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => const FlutterSecureStorage());

}
