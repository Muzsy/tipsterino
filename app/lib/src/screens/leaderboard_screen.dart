import 'package:flutter/material.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.leaderboardTab)),
      body: Center(child: Text(loc.leaderboardTab)),
    );
  }
}
