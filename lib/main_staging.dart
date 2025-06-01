import 'package:flutter/material.dart';
import 'package:beardO/app/app.dart';
import 'package:beardO/bootstrap.dart';
import 'package:beardO/core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize dependency injection first
  await di.init();

  // Then bootstrap the app
  await bootstrap(() => const App());
}
