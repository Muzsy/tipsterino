import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/src/core/clients/supabase_provider.dart';

import '../data/user_events_repository.dart';
import '../domain/user_event.dart';

class UserEventsState {
  const UserEventsState({
    this.items = const [],
    this.isNotConfigured = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
  });

  final List<UserEvent> items;
  final bool isNotConfigured;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;

  static const Object _undefined = Object();

  UserEventsState copyWith({
    List<UserEvent>? items,
    bool? isNotConfigured,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Object? errorMessage = _undefined,
  }) {
    return UserEventsState(
      items: items ?? this.items,
      isNotConfigured: isNotConfigured ?? this.isNotConfigured,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage:
          identical(errorMessage, _undefined) ? this.errorMessage : errorMessage as String?,
    );
  }
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
    );
  }
}

final userEventsProvider = StateNotifierProvider<UserEventsNotifier, UserEventsState>(
  (ref) => UserEventsNotifier(ref.watch(userEventsRepositoryProvider)),
);
