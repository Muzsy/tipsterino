import 'package:flutter/material.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

class BetsScreen extends StatelessWidget {
  const BetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.betsTab)),
      body: Center(
        child: Text(
          loc.betsTab,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
