import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/l10n/app_localizations.dart';

import '../../application/user_events_provider.dart';
import '../../domain/user_event.dart';

class EventsInboxScreen extends ConsumerStatefulWidget {
  const EventsInboxScreen({super.key});

  @override
  ConsumerState<EventsInboxScreen> createState() => _EventsInboxScreenState();
}

class _EventsInboxScreenState extends ConsumerState<EventsInboxScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    Future.microtask(() {
      if (!mounted) return;
      ref.read(userEventsProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final extentAfter = _scrollController.position.extentAfter;
    final state = ref.read(userEventsProvider);
    if (extentAfter >= 300) return;
    if (state.isNotConfigured || state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }
    ref.read(userEventsProvider.notifier).loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final state = ref.watch(userEventsProvider);
    final notifier = ref.read(userEventsProvider.notifier);
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);
    final bodyStyle = theme.textTheme.bodyMedium;

    Widget content;
    if (state.isNotConfigured) {
      content = _buildOfflineState(loc, titleStyle, bodyStyle);
    } else if (state.isLoading && state.items.isEmpty) {
      content = const Center(child: CircularProgressIndicator());
    } else if (state.errorMessage != null && state.items.isEmpty) {
      content = _buildErrorState(state.errorMessage!, bodyStyle);
    } else if (state.items.isEmpty) {
      content = _buildEmptyState(loc, titleStyle, bodyStyle);
    } else {
      content = _buildList(context, state, loc, notifier);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.eventsInboxTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isNotConfigured ? null : notifier.refresh,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: content,
      ),
    );
  }

  Widget _buildOfflineState(AppLocalizations loc, TextStyle? titleStyle, TextStyle? bodyStyle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(loc.offlineNotice, style: titleStyle),
        const SizedBox(height: 8),
        Text(loc.offlineDescription, style: bodyStyle, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildErrorState(String message, TextStyle? bodyStyle) {
    return Center(
      child: Text(message, textAlign: TextAlign.center, style: bodyStyle),
    );
  }

  Widget _buildEmptyState(AppLocalizations loc, TextStyle? titleStyle, TextStyle? bodyStyle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(loc.eventsEmptyTitle, style: titleStyle),
        const SizedBox(height: 8),
        Text(loc.eventsEmptyBody, style: bodyStyle, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildList(
    BuildContext context,
    UserEventsState state,
    AppLocalizations loc,
    UserEventsNotifier notifier,
  ) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => Divider(color: theme.dividerColor, height: 1),
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
            leading: _buildUnreadIndicator(event, theme),
            title: Text(
              _mapTitle(event, loc),
              style: event.isUnread ? theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600) : null,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_mapBody(event, loc)),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(event.createdAt),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            onTap: event.isUnread ? () => notifier.markRead(event) : null,
          );
        },
      ),
    );
  }

  Widget _buildUnreadIndicator(UserEvent event, ThemeData theme) {
    final primary = theme.colorScheme.primary;
    final transparentIndicator = theme.colorScheme.onSurface.withAlpha(0);
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: event.isUnread ? primary : transparentIndicator,
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
