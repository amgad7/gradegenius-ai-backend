import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

import 'core/utils/input_validator.dart';
import 'core/network/api_client.dart';

// Data layer
import 'features/essay_grading/data/datasources/essay_remote_data_source.dart';
import 'features/essay_grading/data/datasources/essay_local_data_source.dart';
import 'features/essay_grading/data/repositories/essay_repository_impl.dart';

// Domain layer
import 'features/essay_grading/domain/repositories/essay_repository.dart';
import 'features/essay_grading/domain/usecases/submit_essay_usecase.dart';
import 'features/essay_grading/domain/usecases/get_history_usecase.dart';
import 'features/essay_grading/domain/usecases/delete_history_item_usecase.dart';

// Presentation layer (Cubits)
import 'features/essay_grading/presentation/cubit/essay_cubit.dart';
import 'features/essay_grading/presentation/cubit/history_cubit.dart';

final sl = GetIt.instance; // Service Locator

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initDependencies();

  runApp(const GradeGeniusApp());
}

Future<void> _initDependencies() async {
  // === Core ===
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPrefs);
  sl.registerLazySingleton(() => InputValidator());
  sl.registerLazySingleton(() => ApiClient.instance);
  // Custom NLP backend Dio (points to our Python server)
  sl.registerLazySingleton(() => ApiClient.customInstance,
      instanceName: 'customDio');

  // === Data Sources ===
  // ✅ Using our Custom NLP Model (Python FastAPI backend)
  sl.registerLazySingleton<EssayRemoteDataSource>(
    () => EssayRemoteDataSourceCustom(dio: sl(instanceName: 'customDio')),
  );

  sl.registerLazySingleton<EssayLocalDataSource>(
    () => EssayLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // === Repositories ===
  sl.registerLazySingleton<EssayRepository>(
    () => EssayRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // === Use Cases ===
  sl.registerLazySingleton(
    () => SubmitEssayUseCase(repository: sl(), validator: sl()),
  );
  sl.registerLazySingleton(() => GetHistoryUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteHistoryItemUseCase(repository: sl()));

  // === Cubits ===
  sl.registerFactory(() => EssayCubit(submitEssayUseCase: sl()));
  sl.registerFactory(
    () => HistoryCubit(getHistoryUseCase: sl(), deleteHistoryItemUseCase: sl()),
  );
}
