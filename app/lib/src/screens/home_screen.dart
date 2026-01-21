import 'package:flutter/material.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.homeTab)),
      body: Center(child: Text(loc.homeTab)),
    );
  }
}
