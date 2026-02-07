import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/src/core/clients/supabase_provider.dart';

import '../data/user_events_repository.dart';
import '../domain/events_filter.dart';
import '../domain/user_event.dart';

class UserEventsState {
  const UserEventsState({
    this.items = const [],
    this.filter = EventsFilter.all,
    this.isNotConfigured = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
    this.isMarkingAllRead = false,
  });

  final List<UserEvent> items;
  final EventsFilter filter;
  final bool isNotConfigured;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final bool isMarkingAllRead;

  static const Object _undefined = Object();

  UserEventsState copyWith({
    List<UserEvent>? items,
    EventsFilter? filter,
    bool? isNotConfigured,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Object? errorMessage = _undefined,
    bool? isMarkingAllRead,
  }) {
    return UserEventsState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      isNotConfigured: isNotConfigured ?? this.isNotConfigured,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage:
          identical(errorMessage, _undefined) ? this.errorMessage : errorMessage as String?,
      isMarkingAllRead: isMarkingAllRead ?? this.isMarkingAllRead,
    );
  }

  List<UserEvent> get filteredItems => items.where(filter.matches).toList();
}

final userEventsRepositoryProvider = Provider<UserEventsRepository?>((ref) {
  final config = ref.watch(supabaseConfigProvider);
  if (!config.isConfigured || config.client == null) {
    return null;
  }

  return UserEventsRepository(config.client!);
});

class UserEventsNotifier extends StateNotifier<UserEventsState> {
  UserEventsNotifier(UserEventsRepository? repository)
      : _repository = repository,
        super(UserEventsState(isNotConfigured: repository == null));

  static const _pageSize = 20;

  final UserEventsRepository? _repository;

  Future<void> loadInitial() async {
    if (_repository == null) {
      _setNotConfigured();
      return;
    }

    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isNotConfigured: false,
    );

    try {
      final items = await _repository.fetchPage(offset: 0, limit: _pageSize);
      state = state.copyWith(
        items: items,
        hasMore: items.length == _pageSize,
        isLoading: false,
        isLoadingMore: false,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        errorMessage: error.toString(),
        isLoading: false,
        isLoadingMore: false,
      );
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (_repository == null) {
      _setNotConfigured();
      return;
    }

    if (!state.hasMore || state.isLoading || state.isLoadingMore) {
      return;
    }

    state = state.copyWith(
      isLoadingMore: true,
      errorMessage: null,
    );

    try {
      final nextItems = await _repository.fetchPage(
        offset: state.items.length,
        limit: _pageSize,
      );
      state = state.copyWith(
        items: [...state.items, ...nextItems],
        hasMore: nextItems.length == _pageSize,
        isLoadingMore: false,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        errorMessage: error.toString(),
        isLoadingMore: false,
      );
    }
  }

  Future<void> markRead(UserEvent event) async {
    if (_repository == null || event.readAt != null) {
      return;
    }

    try {
      await _repository.markRead(id: event.id);
      final updatedEvent = event.copyWith(readAt: DateTime.now().toUtc());
      final updatedItems = state.items
          .map((current) => current.id == updatedEvent.id ? updatedEvent : current)
          .toList();
      state = state.copyWith(items: updatedItems);
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  void _setNotConfigured() {
    if (state.isNotConfigured) return;
    state = state.copyWith(
      isNotConfigured: true,
      isLoading: false,
      isLoadingMore: false,
      errorMessage: null,
      isMarkingAllRead: false,
    );
  }

  void setFilter(EventsFilter value) {
    if (state.filter == value) {
      return;
    }
    state = state.copyWith(filter: value);
  }

  Future<MarkAllReadResult> markAllRead() async {
    final repository = _repository;
    if (repository == null || state.isMarkingAllRead) {
      return const MarkAllReadResult();
    }

    final targets = state.filteredItems.where((event) => event.isUnread).toList();
    if (targets.isEmpty) {
      return const MarkAllReadResult();
    }

    final nowUtc = DateTime.now().toUtc();
    final optimisticItems = state.items
        .map((event) => targets.any((target) => target.id == event.id) ? event.copyWith(readAt: nowUtc) : event)
        .toList();

    state = state.copyWith(items: optimisticItems, isMarkingAllRead: true);
    final succeeded = <String>[];
    final failed = <String>[];
    for (final event in targets) {
      try {
        await repository.markRead(id: event.id);
        succeeded.add(event.id);
      } catch (_) {
        failed.add(event.id);
      }
    }

    final finalItems = state.items.map((event) {
      if (failed.contains(event.id)) {
        return event.copyWith(readAt: null);
      }
      return event;
    }).toList();

    state = state.copyWith(items: finalItems, isMarkingAllRead: false);

    return MarkAllReadResult(succeeded: succeeded.length, failed: failed.length);
  }
}

class MarkAllReadResult {
  const MarkAllReadResult({this.succeeded = 0, this.failed = 0});

  final int succeeded;
  final int failed;
}

final userEventsProvider = StateNotifierProvider<UserEventsNotifier, UserEventsState>(
  (ref) => UserEventsNotifier(ref.watch(userEventsRepositoryProvider)),
);
