import 'package:flutter/material.dart';

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.contentPadding,
    this.secondary,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      title: Text(label),
      subtitle: subtitle == null ? null : Text(subtitle!),
      contentPadding: contentPadding,
      secondary: secondary,
      onChanged: onChanged,
    );
  }
}
