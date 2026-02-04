import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/l10n/app_localizations.dart';

import '../../application/user_events_provider.dart';
import '../../domain/user_event.dart';

class EventsInboxScreen extends ConsumerWidget {
  const EventsInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final state = ref.watch(userEventsProvider);
    final notifier = ref.read(userEventsProvider.notifier);

    Widget content;
    if (state.isNotConfigured) {
      content = _buildOfflineState(loc);
    } else if (state.isLoading && state.items.isEmpty) {
      content = const Center(child: CircularProgressIndicator());
    } else if (state.errorMessage != null && state.items.isEmpty) {
      content = _buildErrorState(state.errorMessage!);
    } else if (state.items.isEmpty) {
      content = _buildEmptyState(loc);
    } else {
      content = _buildList(context, state, loc, notifier);
    }

    return Scaffold(
      appBar: AppBar(title: Text(loc.eventsInboxTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: content,
      ),
    );
  }

  Widget _buildOfflineState(AppLocalizations loc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(loc.offlineNotice, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(loc.offlineDescription, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Text(message, textAlign: TextAlign.center),
    );
  }

  Widget _buildEmptyState(AppLocalizations loc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(loc.eventsEmptyTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(loc.eventsEmptyBody, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildList(
    BuildContext context,
    UserEventsState state,
    AppLocalizations loc,
    UserEventsNotifier notifier,
  ) {
    return ListView.separated(
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final event = state.items[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: _buildUnreadIndicator(event),
          title: Text(
            _mapTitle(event, loc),
            style: event.isUnread ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_mapBody(event, loc)),
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(event.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          onTap: event.isUnread ? () => notifier.markRead(event) : null,
        );
      },
    );
  }

  Widget _buildUnreadIndicator(UserEvent event) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: event.isUnread ? Colors.blue : Colors.transparent,
        shape: BoxShape.circle,
      ),
    );
  }

  String _mapTitle(UserEvent event, AppLocalizations loc) {
    if (event.type == 'tippcoin_credit' && event.code == 'signup_bonus') {
      return loc.eventSignupBonusTitle;
    }
    return _fallbackText(event);
  }

  String _mapBody(UserEvent event, AppLocalizations loc) {
    if (event.type == 'tippcoin_credit' && event.code == 'signup_bonus') {
      return loc.eventSignupBonusBody(event.amount?.toString() ?? '0');
    }
    return _fallbackText(event);
  }

  String _fallbackText(UserEvent event) {
    final codeSegment = event.code.isNotEmpty ? ':${event.code}' : '';
    return '${event.type}$codeSegment';
  }

  String _formatTimestamp(DateTime value) {
    final local = value.toLocal();
    final year = local.year.toString();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }
}
