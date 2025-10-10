import 'package:flutter/material.dart';
import 'package:pub_diferent/app/theme/app_theme.dart';
import 'package:pub_diferent/features/home/presentation/pages/home_page.dart';
import 'package:pub_diferent/features/settings/presentation/controllers/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsController = await SettingsController.load();
  runApp(MainApp(settingsController: settingsController));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settingsController.themeMode,
          home: HomePage(settingsController: settingsController),
        );
      },
    );
  }
}
