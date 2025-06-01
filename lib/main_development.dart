import 'package:flutter/widgets.dart';
import 'package:progress_tracker/app/app.dart';
import 'package:progress_tracker/bootstrap.dart';
import 'package:progress_tracker/core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection first
  await di.init();

  // Then bootstrap the app
  await bootstrap(() => const App());
}
