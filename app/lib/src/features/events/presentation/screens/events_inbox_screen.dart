import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/features/events/domain/events_filter.dart';

import '../../application/user_events_provider.dart';
import '../../domain/user_event.dart';

class EventsInboxScreen extends ConsumerStatefulWidget {
  const EventsInboxScreen({super.key});

  @override
  ConsumerState<EventsInboxScreen> createState() => _EventsInboxScreenState();
}

class _EventsInboxScreenState extends ConsumerState<EventsInboxScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;
  bool _isAppResumed = true;
  static const _pollingInterval = Duration(seconds: 45);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    _isAppResumed =
        lifecycleState == null || lifecycleState == AppLifecycleState.resumed;
    _startPollingTimer();
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
    _stopPollingTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final extentAfter = _scrollController.position.extentAfter;
    final state = ref.read(userEventsProvider);
    if (extentAfter >= 300) return;
    if (state.isNotConfigured ||
        state.isLoading ||
        state.isLoadingMore ||
        state.isMarkingAllRead ||
        !state.hasMore) {
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
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final bodyStyle = theme.textTheme.bodyMedium;
    final filteredItems = state.filteredItems;
    final hasUnreadInView = filteredItems.any((event) => event.isUnread);
    final canMarkAll =
        !state.isNotConfigured && !state.isMarkingAllRead && hasUnreadInView;
    final canRefresh = !state.isNotConfigured && !state.isMarkingAllRead;

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
      content = _buildList(
        context,
        state,
        filteredItems,
        loc,
        notifier,
        state.isMarkingAllRead,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.eventsInboxTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: canRefresh ? notifier.refresh : null,
          ),
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: loc.eventsMarkAllReadTooltip,
            onPressed: canMarkAll
                ? () async {
                    final result = await notifier.markAllRead();
                    if (!context.mounted) {
                      return;
                    }
                    final messenger = ScaffoldMessenger.of(context);
                    if (result.failed == 0) {
                      messenger.showSnackBar(
                        SnackBar(content: Text(loc.eventsMarkAllReadSuccess)),
                      );
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            loc.eventsMarkAllReadPartial(
                              result.succeeded,
                              result.failed,
                            ),
                          ),
                        ),
                      );
                    }
                  }
                : null,
          ),
        ],
      ),
      body: Padding(padding: const EdgeInsets.all(16), child: content),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _isAppResumed = true;
      _startPollingTimer();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _isAppResumed = false;
      _stopPollingTimer();
    }
  }

  void _startPollingTimer() {
    if (!_isAppResumed) {
      return;
    }
    if (_pollingTimer != null) {
      return;
    }
    _pollingTimer = Timer.periodic(_pollingInterval, (_) => _pollRefresh());
  }

  void _stopPollingTimer() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void _pollRefresh() {
    if (!mounted) {
      return;
    }
    if (!_isRouteVisibleForPolling()) {
      return;
    }
    final state = ref.read(userEventsProvider);
    if (state.isNotConfigured ||
        state.isLoading ||
        state.isLoadingMore ||
        state.isMarkingAllRead) {
      return;
    }
    ref.read(userEventsProvider.notifier).refresh();
  }

  bool _isRouteVisibleForPolling() {
    if (!mounted) {
      return false;
    }
    final tickerMode = TickerMode.of(context);
    if (!tickerMode) {
      return false;
    }
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) {
      return false;
    }
    return true;
  }

  Widget _buildOfflineState(
    AppLocalizations loc,
    TextStyle? titleStyle,
    TextStyle? bodyStyle,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(loc.offlineNotice, style: titleStyle),
        const SizedBox(height: 8),
        Text(
          loc.offlineDescription,
          style: bodyStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorState(String message, TextStyle? bodyStyle) {
    return Center(
      child: Text(message, textAlign: TextAlign.center, style: bodyStyle),
    );
  }

  Widget _buildEmptyState(
    AppLocalizations loc,
    TextStyle? titleStyle,
    TextStyle? bodyStyle,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(loc.eventsEmptyTitle, style: titleStyle),
        const SizedBox(height: 8),
        Text(
          loc.eventsEmptyBody,
          style: bodyStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildList(
    BuildContext context,
    UserEventsState state,
    List<UserEvent> filteredItems,
    AppLocalizations loc,
    UserEventsNotifier notifier,
    bool isMarkingAllRead,
  ) {
    final listPhysics = isMarkingAllRead
        ? const NeverScrollableScrollPhysics()
        : const AlwaysScrollableScrollPhysics();
    final theme = Theme.of(context);
    final hasItems = filteredItems.isNotEmpty;
    final loadingExtras = hasItems && state.isLoadingMore ? 1 : 0;
    final itemCount = hasItems ? filteredItems.length + loadingExtras : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFilterBar(loc, state.filter, notifier.setFilter),
        const SizedBox(height: 12),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              if (isMarkingAllRead) {
                return;
              }
              await notifier.refresh();
            },
            child: ListView.separated(
              controller: _scrollController,
              physics: listPhysics,
              itemCount: itemCount,
              separatorBuilder: (context, index) =>
                  Divider(color: theme.dividerColor, height: 1),
              itemBuilder: (context, index) {
                if (!hasItems) {
                  return Column(
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        loc.eventsEmptyBody,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }

                if (index >= filteredItems.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final event = filteredItems[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: _buildUnreadIndicator(event, theme),
                  title: Text(
                    _mapTitle(event, loc),
                    style: event.isUnread
                        ? theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          )
                        : null,
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
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(
    AppLocalizations loc,
    EventsFilter selected,
    void Function(EventsFilter) onFilterChanged,
  ) {
    final segments = EventsFilter.values
        .map(
          (filter) => ButtonSegment<EventsFilter>(
            value: filter,
            label: Text(_filterLabel(filter, loc)),
          ),
        )
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<EventsFilter>(
        segments: segments,
        selected: <EventsFilter>{selected},
        onSelectionChanged: (selection) {
          if (selection.isEmpty) return;
          onFilterChanged(selection.first);
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
    if (event.type == 'tippcoin_credit') {
      if (event.code == 'signup_bonus') {
        return loc.eventSignupBonusTitle;
      }
      if (event.code == 'daily_bonus') {
        return loc.event_daily_bonus_title;
      }
    }
    return _fallbackText(event);
  }

  String _mapBody(UserEvent event, AppLocalizations loc) {
    if (event.type == 'tippcoin_credit') {
      if (event.code == 'signup_bonus') {
        return loc.eventSignupBonusBody(event.amount?.toString() ?? '0');
      }
      if (event.code == 'daily_bonus') {
        return loc.event_daily_bonus_body(event.amount?.toString() ?? '0');
      }
    }
    return _fallbackText(event);
  }

  String _fallbackText(UserEvent event) {
    final code = event.code;
    final codeSegment = (code != null && code.isNotEmpty) ? ':$code' : '';
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

  String _filterLabel(EventsFilter filter, AppLocalizations loc) {
    switch (filter) {
      case EventsFilter.all:
        return loc.eventsFilterAll;
      case EventsFilter.credits:
        return loc.eventsFilterCredits;
      case EventsFilter.social:
        return loc.eventsFilterSocial;
      case EventsFilter.challenges:
        return loc.eventsFilterChallenges;
      case EventsFilter.system:
        return loc.eventsFilterSystem;
    }
  }
}
