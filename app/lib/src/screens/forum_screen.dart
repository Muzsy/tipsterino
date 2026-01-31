import 'package:flutter/material.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.forumTab)),
      body: Center(
        child: Text(
          loc.forumTab,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
