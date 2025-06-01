import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:beardO/core/utils/notification_service.dart';
import 'package:beardO/features/settings/di/settings_injection.dart';
import 'package:beardO/features/tracker/data/datasources/progress_local_data_source.dart';
import 'package:beardO/features/tracker/data/datasources/progress_notion_data_source.dart';
import 'package:beardO/features/tracker/data/repositories/progress_repository_impl.dart';
import 'package:beardO/features/tracker/domain/repositories/progress_repository.dart';
import 'package:beardO/features/tracker/domain/usecases/get_completion_rate.dart';
import 'package:beardO/features/tracker/domain/usecases/get_progress_entries.dart';
import 'package:beardO/features/tracker/domain/usecases/get_progress_entry_by_date.dart';
import 'package:beardO/features/tracker/domain/usecases/save_progress_entry.dart';
import 'package:beardO/features/tracker/domain/usecases/save_progress_photo.dart';
import 'package:beardO/features/tracker/domain/usecases/update_progress_entry.dart';
import 'package:beardO/features/tracker/presentation/bloc/progress_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialize Settings feature
  await initSettingsInjection(sl);

  // Features - Progress Tracker

  // Bloc
  sl
    ..registerFactory(
      () => ProgressBloc(
        getProgressEntries: sl(),
        getProgressEntryByDate: sl(),
        saveProgressEntry: sl(),
        updateProgressEntry: sl(),
        saveProgressPhoto: sl(),
        getCompletionRate: sl(),
      ),
    )

    // Use cases
    ..registerLazySingleton(() => GetProgressEntries(sl()))
    ..registerLazySingleton(() => GetProgressEntryByDate(sl()))
    ..registerLazySingleton(() => SaveProgressEntry(sl()))
    ..registerLazySingleton(() => UpdateProgressEntry(sl()))
    ..registerLazySingleton(() => SaveProgressPhoto(sl()))
    ..registerLazySingleton(() => GetCompletionRate(sl()))
    ..registerLazySingleton(NotificationService.new)

    // Repository
    ..registerLazySingleton<ProgressRepository>(
      () => ProgressRepositoryImpl(localDataSource: sl()),
    )

    // Data sources
    ..registerLazySingleton<ProgressLocalDataSource>(
      () => ProgressLocalDataSourceImpl(sharedPreferences: sl()),
    );

  // External - SharedPreferences for local storage
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Ensure directory for photos exists
  final appDir = await getApplicationDocumentsDirectory();
  sl.registerLazySingleton(() => appDir);
}
