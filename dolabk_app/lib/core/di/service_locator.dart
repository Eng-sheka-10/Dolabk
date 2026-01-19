// lib/core/di/service_locator.dart
// Dependency Injection setup using GetIt (optional but recommended)
import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../../services/services.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Register DioClient
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // Register all services
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<ProductService>(
    () => ProductService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<OrderService>(
    () => OrderService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<AddressService>(
    () => AddressService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<ExchangeService>(
    () => ExchangeService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<MessageService>(
    () => MessageService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<ReviewService>(
    () => ReviewService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<UserService>(
    () => UserService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<AdminService>(
    () => AdminService(getIt<DioClient>()),
  );
}
