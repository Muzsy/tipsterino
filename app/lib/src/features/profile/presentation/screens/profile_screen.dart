import 'package:flutter/material.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.profileTab)),
      body: Center(
        child: Text(
          loc.profileTab,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
