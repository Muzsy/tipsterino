import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/app/app.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/events/application/user_events_provider.dart';
import 'package:tipsterino/src/features/events/domain/user_event.dart';
import 'package:tipsterino/src/features/events/data/user_events_repository.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_provider.dart';

class FakeUserEventsRepository implements UserEventsRepository {
  FakeUserEventsRepository(this._pages);

  final Map<int, List<UserEvent>> _pages;
  final List<int> fetchOffsets = [];
  final List<String> markReadIds = [];
  int markReadCallCount = 0;

  @override
  Future<List<UserEvent>> fetchPage({
    required int offset,
    required int limit,
  }) async {
    fetchOffsets.add(offset);
    await Future.delayed(Duration.zero);
    return List<UserEvent>.from(_pages[offset] ?? const []);
  }

  @override
  Future<void> markRead({required String id}) async {
    await Future.delayed(Duration.zero);
    markReadCallCount++;
    markReadIds.add(id);
  }
}

Widget _buildTestApp(FakeUserEventsRepository repo) {
  return ProviderScope(
    overrides: [
      authNotifierProvider.overrideWith(
        (ref) => AuthNotifier(
          ref,
          initialState: const AuthViewState(status: AuthStatus.authenticated),
          autoListen: false,
        ),
      ),
      userEventsRepositoryProvider.overrideWithValue(repo),
      supabaseConfigProvider.overrideWithValue(
        const SupabaseConfiguration(isConfigured: false),
      ),
    ],
    child: const TipsterinoApp(),
  );
}

Future<void> _openEvents(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
  final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
  router.go('/events');
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

List<UserEvent> _buildEvents({required int count, String prefix = 'e'}) {
  final now = DateTime.now();
  return List.generate(count, (index) {
    return UserEvent(
      id: '$prefix$index',
      type: 'tippcoin_credit',
      code: 'signup_bonus',
      amount: 100 + index,
      payload: null,
      createdAt: now.subtract(Duration(minutes: index)),
      readAt: null,
    );
  });
}

void main() {
  testWidgets('Initial load shows signup bonus and fetches page 0', (
    tester,
  ) async {
    final repo = FakeUserEventsRepository({
      0: [
        UserEvent(
          id: 'e1',
          type: 'tippcoin_credit',
          code: 'signup_bonus',
          amount: 100,
          payload: null,
          createdAt: DateTime.now(),
          readAt: null,
        ),
      ],
    });
    await tester.pumpWidget(_buildTestApp(repo));
    await _openEvents(tester);

    final loc = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(loc.eventSignupBonusTitle), findsOneWidget);
    expect(find.text(loc.eventSignupBonusBody('100')), findsOneWidget);
    expect(repo.fetchOffsets, contains(0));
  });

  testWidgets('Null code event renders fallback text without crash', (
    tester,
  ) async {
    final repo = FakeUserEventsRepository({
      0: [
        UserEvent(
          id: 'null-code',
          type: 'custom_event',
          code: null,
          amount: null,
          payload: null,
          createdAt: DateTime.now(),
          readAt: null,
        ),
      ],
    });
    await tester.pumpWidget(_buildTestApp(repo));
    await _openEvents(tester);

    expect(find.text('custom_event'), findsWidgets);
    expect(repo.fetchOffsets, contains(0));
  });

  testWidgets(
    'RefreshIndicator present and AppBar refresh triggers fetch again',
    (tester) async {
      final repo = FakeUserEventsRepository({
        0: [
          UserEvent(
            id: 'e1',
            type: 'tippcoin_credit',
            code: 'signup_bonus',
            amount: 100,
            payload: null,
            createdAt: DateTime.now(),
            readAt: null,
          ),
        ],
      });
      await tester.pumpWidget(_buildTestApp(repo));
      await _openEvents(tester);

      expect(find.byType(RefreshIndicator), findsOneWidget);
      final refreshFinder = find.widgetWithIcon(IconButton, Icons.refresh);
      final refreshOutlinedFinder = find.widgetWithIcon(
        IconButton,
        Icons.refresh_outlined,
      );
      if (refreshFinder.evaluate().isNotEmpty) {
        await tester.tap(refreshFinder);
      } else if (refreshOutlinedFinder.evaluate().isNotEmpty) {
        await tester.tap(refreshOutlinedFinder);
      } else {
        fail('Refresh action not found');
      }
      await tester.pumpAndSettle();
      expect(
        repo.fetchOffsets.where((offset) => offset == 0).length,
        greaterThanOrEqualTo(2),
      );
    },
  );

  testWidgets('Scrolling near end triggers loadMore (fetch page 20)', (
    tester,
  ) async {
    final twentyEvents = _buildEvents(count: 20);
    final repo = FakeUserEventsRepository({
      0: twentyEvents,
      20: [
        UserEvent(
          id: 'e20',
          type: 'tippcoin_credit',
          code: 'signup_bonus',
          amount: 999,
          payload: null,
          createdAt: DateTime.now(),
          readAt: null,
        ),
      ],
    });
    await tester.pumpWidget(_buildTestApp(repo));
    await _openEvents(tester);

    final listFinder = find.byType(RefreshIndicator);
    await tester.fling(listFinder, const Offset(0, -1000), 2000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
    expect(repo.fetchOffsets, contains(20));
  });

  testWidgets('MarkRead is idempotent (called once)', (tester) async {
    final repo = FakeUserEventsRepository({
      0: [
        UserEvent(
          id: 'e1',
          type: 'tippcoin_credit',
          code: 'signup_bonus',
          amount: 100,
          payload: null,
          createdAt: DateTime.now(),
          readAt: null,
        ),
      ],
    });
    await tester.pumpWidget(_buildTestApp(repo));
    await _openEvents(tester);

    final loc = await AppLocalizations.delegate.load(const Locale('en'));
    final tileFinder = find.text(loc.eventSignupBonusTitle);
    await tester.tap(tileFinder);
    await tester.pumpAndSettle();
    expect(repo.markReadIds, equals(['e1']));
    expect(repo.markReadCallCount, 1);

    await tester.tap(tileFinder);
    await tester.pumpAndSettle();
    expect(repo.markReadCallCount, 1);
    expect(repo.markReadIds.length, 1);
  });
}
