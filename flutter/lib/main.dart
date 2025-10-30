import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pub_diferent/app/app.dart';
import 'package:pub_diferent/features/settings/presentation/controllers/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsController = await SettingsController.load();

  runApp(
    ProviderScope(
      child: PubDiferentApp(settingsController: settingsController),
    ),
  );
}