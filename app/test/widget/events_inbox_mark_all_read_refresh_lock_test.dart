import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/app/app.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_provider.dart';
import 'package:tipsterino/src/features/events/application/user_events_provider.dart';
import 'package:tipsterino/src/features/events/data/user_events_repository.dart';
import 'package:tipsterino/src/features/events/domain/user_event.dart';

class FakeMarkAllReadRefreshLockRepository implements UserEventsRepository {
  FakeMarkAllReadRefreshLockRepository(this._events)
      : _markReadCompleter = Completer<void>();

  final List<UserEvent> _events;
  final Completer<void> _markReadCompleter;
  final List<int> fetchOffsets = [];

  @override
  Future<List<UserEvent>> fetchPage({required int offset, required int limit}) async {
    fetchOffsets.add(offset);
    await Future<void>.delayed(Duration.zero);
    return List<UserEvent>.from(_events);
  }

  @override
  Future<void> markRead({required String id}) {
    return _markReadCompleter.future;
  }

  void completeMarkRead() {
    if (!_markReadCompleter.isCompleted) {
      _markReadCompleter.complete();
    }
  }
}

Widget _buildTestApp(FakeMarkAllReadRefreshLockRepository repo) {
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
      supabaseConfigProvider.overrideWithValue(const SupabaseConfiguration(isConfigured: true)),
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

UserEvent _exampleEvent(String id) {
  final now = DateTime.now();
  return UserEvent(
    id: id,
    type: 'message',
    code: '',
    amount: null,
    payload: null,
    createdAt: now,
    readAt: null,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('refresh controls disabled while markAllRead in progress', (tester) async {
    final repo = FakeMarkAllReadRefreshLockRepository([_exampleEvent('event-1')]);
    await tester.pumpWidget(_buildTestApp(repo));
    await _openEvents(tester);

    final loc = await AppLocalizations.delegate.load(const Locale('en'));
    final markAllButton = find.byTooltip(loc.eventsMarkAllReadTooltip);
    expect(markAllButton, findsOneWidget);

    await tester.tap(markAllButton);
    await tester.pump();

    final refreshButtonFinder = find.widgetWithIcon(IconButton, Icons.refresh);
    expect(refreshButtonFinder, findsOneWidget);
    final refreshButton = tester.widget<IconButton>(refreshButtonFinder);
    expect(refreshButton.onPressed, isNull);

    await tester.drag(find.byType(ListView), const Offset(0, 200));
    await tester.pump(const Duration(milliseconds: 500));
    expect(repo.fetchOffsets, equals([0]));

    repo.completeMarkRead();
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, 200));
    await tester.pump(const Duration(milliseconds: 500));
    expect(repo.fetchOffsets, equals([0, 0]));
  });
}
