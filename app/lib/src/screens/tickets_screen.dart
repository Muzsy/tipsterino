import 'package:flutter/material.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.ticketsTab)),
      body: Center(child: Text(loc.ticketsTab)),
    );
  }
}
