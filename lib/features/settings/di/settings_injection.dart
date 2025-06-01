import 'package:get_it/get_it.dart';
import 'package:beardO/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:beardO/features/settings/domain/repositories/settings_repository.dart';
import 'package:beardO/features/settings/presentation/bloc/settings_bloc.dart';

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
