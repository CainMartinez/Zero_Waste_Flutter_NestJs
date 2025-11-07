import 'package:flutter/material.dart';

class ShowcaseScaffold extends StatelessWidget {
  const ShowcaseScaffold({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: body,
    );
  }
}
