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

class FakeMarkAllReadPartialFailureRepository implements UserEventsRepository {
  FakeMarkAllReadPartialFailureRepository(this._events, {required this.failureIds});

  final List<UserEvent> _events;
  final Set<String> failureIds;
  final List<String> markReadIds = [];

  @override
  Future<List<UserEvent>> fetchPage({required int offset, required int limit}) async {
    await Future<void>.delayed(Duration.zero);
    return List<UserEvent>.from(_events);
  }

  @override
  Future<void> markRead({required String id}) async {
    await Future<void>.delayed(Duration.zero);
    markReadIds.add(id);
    if (failureIds.contains(id)) {
      throw Exception('Simulated failure for $id');
    }
  }
}

Widget _buildTestApp(FakeMarkAllReadPartialFailureRepository repo) {
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

UserEvent _tippcoinEvent() {
  final now = DateTime.now();
  return UserEvent(
    id: 'credits-1',
    type: 'tippcoin_credit',
    code: 'signup_bonus',
    amount: 25,
    payload: null,
    createdAt: now,
    readAt: null,
  );
}

UserEvent _messageEvent() {
  final now = DateTime.now();
  return UserEvent(
    id: 'message-1',
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

  testWidgets('mark all read partial failure keeps failed items unread', (tester) async {
    final repo = FakeMarkAllReadPartialFailureRepository(
      [_tippcoinEvent(), _messageEvent()],
      failureIds: {'message-1'},
    );
    await tester.pumpWidget(_buildTestApp(repo));
    await _openEvents(tester);

    final loc = await AppLocalizations.delegate.load(const Locale('en'));

    final markAllButton = find.byTooltip(loc.eventsMarkAllReadTooltip);
    expect(markAllButton, findsOneWidget);

    await tester.tap(markAllButton);
    await tester.pumpAndSettle();

    expect(repo.markReadIds, containsAll(<String>['credits-1', 'message-1']));
    expect(find.text(loc.eventsMarkAllReadPartial(1, 1)), findsOneWidget);

    final failedTile = tester.widget<ListTile>(find.widgetWithText(ListTile, 'message').first);
    expect(failedTile.onTap, isNotNull);
  });
}
