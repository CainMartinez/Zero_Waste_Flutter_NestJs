import 'package:flutter/material.dart';
import 'package:pub_diferent/app/theme/app_theme.dart';
import 'package:pub_diferent/features/settings/presentation/widgets/settings_switch_tile.dart';

class ShowcaseScaffold extends StatefulWidget {
  const ShowcaseScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showThemeToggle = true,
  });

  final String title;
  final Widget body;
  final bool showThemeToggle;

  @override
  State<ShowcaseScaffold> createState() => _ShowcaseScaffoldState();
}

class _ShowcaseScaffoldState extends State<ShowcaseScaffold> {
  bool _dark = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _dark = Theme.of(context).brightness == Brightness.dark;
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _dark ? AppTheme.dark : AppTheme.light;

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title), centerTitle: true),
        body: Column(
          children: [
            if (widget.showThemeToggle)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SwitchListTile usado en SettingsPage',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SettingsSwitchTile(
                      label: 'Modo oscuro',
                      value: _dark,
                      onChanged: (value) => setState(() => _dark = value),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            Expanded(child: widget.body),
          ],
        ),
      ),
    );
  }
}
