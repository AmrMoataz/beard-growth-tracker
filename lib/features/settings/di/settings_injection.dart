import 'package:get_it/get_it.dart';
import 'package:progress_tracker/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:progress_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:progress_tracker/features/settings/presentation/bloc/settings_bloc.dart';

Future<void> initSettingsInjection(GetIt sl) async {
  // BLoC
  sl.registerFactory(
    () => SettingsBloc(sl()),
  );

  // Repository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl()),
  );

    // Use the existing SharedPreferences instance from the main container
  // No need to register it again
}
