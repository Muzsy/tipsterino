import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tipsterino/src/app/app.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_provider.dart';
import 'package:tipsterino/src/features/events/application/user_events_provider.dart';
import 'package:tipsterino/src/features/events/data/user_events_repository.dart';
import 'package:tipsterino/src/features/events/domain/user_event.dart';
import 'package:tipsterino/src/features/events/presentation/screens/events_inbox_screen.dart';

class FakePollingRouteGuardRepository extends UserEventsRepository {
  FakePollingRouteGuardRepository(this._events)
      : super(
          SupabaseClient(
            'http://localhost',
            'anon',
            authOptions: const AuthClientOptions(autoRefreshToken: false),
          ),
        );

  final List<UserEvent> _events;
  final List<int> fetchOffsets = [];

  @override
  Future<List<UserEvent>> fetchPage({required int offset, required int limit}) async {
    fetchOffsets.add(offset);
    await Future<void>.delayed(Duration.zero);
    return List<UserEvent>.from(_events);
  }

  @override
  Future<void> markRead({required String id}) async {
    await Future<void>.delayed(Duration.zero);
  }
}

Widget _buildTestApp(FakePollingRouteGuardRepository repo) {
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

UserEvent _buildEvent(String id) {
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
  const pollingDuration = Duration(seconds: 45);

  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('polling refresh stops when route hidden behind dialog', (tester) async {
    final repo = FakePollingRouteGuardRepository([_buildEvent('event-1')]);
    await tester.pumpWidget(_buildTestApp(repo));
    await _openEvents(tester);

    expect(repo.fetchOffsets, equals([0]));

    await tester.pump(pollingDuration);
    expect(repo.fetchOffsets.length, greaterThanOrEqualTo(2));
    final afterVisible = repo.fetchOffsets.length;

    await tester.runAsync(() async {
      showDialog<void>(
        context: tester.element(find.byType(EventsInboxScreen)),
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (context) => AlertDialog(
          content: const Text('modal'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    });
    await tester.pumpAndSettle();

    await tester.pump(pollingDuration);
    expect(repo.fetchOffsets.length, equals(afterVisible));

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    await tester.pump(pollingDuration);
    expect(repo.fetchOffsets.length, greaterThan(afterVisible));
  });
}
