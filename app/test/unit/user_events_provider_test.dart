import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tipsterino/src/features/events/application/user_events_provider.dart';
import 'package:tipsterino/src/features/events/domain/user_event.dart';
import 'package:tipsterino/src/features/events/data/user_events_repository.dart';

class FakeUserEventsRepository extends UserEventsRepository {
  FakeUserEventsRepository._(
    this._client, {
    required this.pages,
    this.throwOnFetch = false,
    this.throwOnMarkRead = false,
  }) : super(_client);

  factory FakeUserEventsRepository({
    required Map<int, List<UserEvent>> pages,
    bool throwOnFetch = false,
    bool throwOnMarkRead = false,
  }) {
    final client = SupabaseClient(
      'http://localhost',
      'anon',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    return FakeUserEventsRepository._(
      client,
      pages: pages,
      throwOnFetch: throwOnFetch,
      throwOnMarkRead: throwOnMarkRead,
    );
  }

  final SupabaseClient _client;
  final Map<int, List<UserEvent>> pages;
  final List<int> fetchOffsets = [];
  final List<String> markReadIds = [];
  int markReadCallCount = 0;
  bool throwOnFetch;
  bool throwOnMarkRead;

  Future<void> dispose() => _client.dispose();

  @override
  Future<List<UserEvent>> fetchPage({required int offset, required int limit}) async {
    fetchOffsets.add(offset);
    await Future.delayed(Duration.zero);
    if (throwOnFetch) {
      throw StateError('fetch failure');
    }
    return List<UserEvent>.from(pages[offset] ?? const []);
  }

  @override
  Future<void> markRead({required String id}) async {
    await Future.delayed(Duration.zero);
    if (throwOnMarkRead) {
      throw StateError('markRead failure');
    }
    markReadCallCount++;
    markReadIds.add(id);
  }
}

ProviderContainer _createContainer(UserEventsRepository? repo) {
  return ProviderContainer(
    overrides: [
      userEventsRepositoryProvider.overrideWithValue(repo),
    ],
  );
}

UserEvent _buildEvent(String id, {bool read = false}) {
  return UserEvent(
    id: id,
    type: 'tippcoin_credit',
    code: 'signup_bonus',
    amount: 100,
    payload: null,
    createdAt: DateTime.utc(2024, 1, 1),
    readAt: read ? DateTime.utc(2024, 1, 1, 0, 1) : null,
  );
}

List<UserEvent> _buildEvents(int count, {String prefix = 'e'}) {
  return List.generate(count, (index) => _buildEvent('$prefix$index'));
}

void main() {
  test('not_configured guard keeps state offline', () async {
    final container = _createContainer(null);
    addTearDown(container.dispose);

    final notifier = container.read(userEventsProvider.notifier);
    final initial = container.read(userEventsProvider);

    expect(initial.isNotConfigured, isTrue);

    await notifier.loadInitial();

    final after = container.read(userEventsProvider);
    expect(after.isNotConfigured, isTrue);
    expect(after.items, isEmpty);
    expect(after.isLoading, isFalse);
    expect(after.errorMessage, isNull);
  });

  test('loadInitial loads items and toggles hasMore', () async {
    final repo = FakeUserEventsRepository(pages: {
      0: [_buildEvent('a'), _buildEvent('b')],
    });
    final container = _createContainer(repo);
    addTearDown(() async {
      await repo.dispose();
      container.dispose();
    });

    final notifier = container.read(userEventsProvider.notifier);
    await notifier.loadInitial();

    final state = container.read(userEventsProvider);
    expect(repo.fetchOffsets, [0]);
    expect(state.items.length, 2);
    expect(state.hasMore, isFalse);
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, isNull);
  });

  test('refresh reloads page 0', () async {
    final repo = FakeUserEventsRepository(pages: {
      0: [_buildEvent('first')],
    });
    final container = _createContainer(repo);
    addTearDown(() async {
      await repo.dispose();
      container.dispose();
    });

    final notifier = container.read(userEventsProvider.notifier);
    await notifier.loadInitial();
    repo.pages[0] = [_buildEvent('second')];

    await notifier.refresh();

    final state = container.read(userEventsProvider);
    expect(repo.fetchOffsets.where((offset) => offset == 0).length, greaterThanOrEqualTo(2));
    expect(state.items.map((event) => event.id), equals(['second']));
  });

  test('loadMore appends next page and stops when hasMore false', () async {
    final repo = FakeUserEventsRepository(pages: {
      0: _buildEvents(20),
      20: [_buildEvent('twenty')],
    });
    final container = _createContainer(repo);
    addTearDown(() async {
      await repo.dispose();
      container.dispose();
    });

    final notifier = container.read(userEventsProvider.notifier);
    await notifier.loadInitial();
    await notifier.loadMore();

    final state = container.read(userEventsProvider);
    expect(repo.fetchOffsets, [0, 20]);
    expect(state.items.length, 21);
    expect(state.hasMore, isFalse);
  });

  test('loadMore guard stops fetching when no more pages', () async {
    final repo = FakeUserEventsRepository(pages: {
      0: [_buildEvent('once')],
    });
    final container = _createContainer(repo);
    addTearDown(() async {
      await repo.dispose();
      container.dispose();
    });

    final notifier = container.read(userEventsProvider.notifier);
    await notifier.loadInitial();
    await notifier.loadMore();

    expect(repo.fetchOffsets, [0]);
  });

  test('markRead updates state once and remains idempotent', () async {
    final repo = FakeUserEventsRepository(pages: {
      0: [_buildEvent('e1')],
    });
    final container = _createContainer(repo);
    addTearDown(() async {
      await repo.dispose();
      container.dispose();
    });

    final notifier = container.read(userEventsProvider.notifier);
    await notifier.loadInitial();

    final firstEvent = container.read(userEventsProvider).items.first;
    await notifier.markRead(firstEvent);
    expect(repo.markReadIds, ['e1']);
    expect(repo.markReadCallCount, 1);
    expect(container.read(userEventsProvider).items.first.readAt, isNotNull);

    await notifier.markRead(container.read(userEventsProvider).items.first);
    expect(repo.markReadCallCount, 1);
    expect(repo.markReadIds.length, 1);
  });

  group('error handling', () {
    test('fetch failure sets errorMessage without mutating loading flag', () async {
      final repo = FakeUserEventsRepository(pages: {
        0: [],
      }, throwOnFetch: true);
      final container = _createContainer(repo);
      addTearDown(() async {
        await repo.dispose();
        container.dispose();
      });

      final notifier = container.read(userEventsProvider.notifier);
      await notifier.loadInitial();

      final state = container.read(userEventsProvider);
      expect(state.errorMessage, contains('fetch failure'));
      expect(state.isLoading, isFalse);
    });

    test('loadMore failure leaves existing items and clears loadingMore', () async {
      final repo = FakeUserEventsRepository(pages: {
        0: _buildEvents(20),
        20: [_buildEvent('more')],
      });
      final container = _createContainer(repo);
      addTearDown(() async {
        await repo.dispose();
        container.dispose();
      });

      final notifier = container.read(userEventsProvider.notifier);
      await notifier.loadInitial();
      repo.throwOnFetch = true;

      await notifier.loadMore();

      final state = container.read(userEventsProvider);
      expect(state.errorMessage, contains('fetch failure'));
      expect(state.isLoadingMore, isFalse);
      expect(state.items.length, 20);
    });

    test('markRead failure keeps readAt null and surfaces error', () async {
      final repo = FakeUserEventsRepository(pages: {
        0: [_buildEvent('e1')],
      }, throwOnMarkRead: true);
      final container = _createContainer(repo);
      addTearDown(() async {
        await repo.dispose();
        container.dispose();
      });

      final notifier = container.read(userEventsProvider.notifier);
      await notifier.loadInitial();

      final ev = container.read(userEventsProvider).items.first;
      await notifier.markRead(ev);

      final state = container.read(userEventsProvider);
      expect(state.errorMessage, contains('markRead failure'));
      expect(state.items.first.readAt, isNull);
    });
  });
}
