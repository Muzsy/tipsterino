import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/events/application/user_events_provider.dart';
import 'package:tipsterino/src/features/events/data/user_events_repository.dart';
import 'package:tipsterino/src/features/events/domain/user_event.dart';
import 'package:tipsterino/src/features/events/presentation/screens/events_inbox_screen.dart';

class FakeUserEventsRepository implements UserEventsRepository {
  FakeUserEventsRepository(this._events);

  final List<UserEvent> _events;

  @override
  Future<List<UserEvent>> fetchPage({required int offset, required int limit}) async {
    await Future<void>.delayed(Duration.zero);
    return List<UserEvent>.from(_events);
  }

  @override
  Future<void> markRead({required String id}) async {
    await Future<void>.delayed(Duration.zero);
  }
}

Widget _buildTestScreen(FakeUserEventsRepository repository) {
  return ProviderScope(
    overrides: [
      userEventsRepositoryProvider.overrideWithValue(repository),
      supabaseConfigProvider.overrideWithValue(const SupabaseConfiguration(isConfigured: true)),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const EventsInboxScreen(),
    ),
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

UserEvent _signupBonusEvent() {
  final now = DateTime.now();
  return UserEvent(
    id: 'bonus-1',
    type: 'tippcoin_credit',
    code: 'signup_bonus',
    amount: 100,
    payload: null,
    createdAt: now,
    readAt: null,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('filter bar toggles events', (tester) async {
    final repo = FakeUserEventsRepository([
      _signupBonusEvent(),
      _messageEvent(),
    ]);

    await tester.pumpWidget(_buildTestScreen(repo));
    await tester.pumpAndSettle();

    final loc = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(loc.eventSignupBonusTitle), findsOneWidget);
    expect(find.text('message'), findsWidgets);

    final creditsFilter = find.text(loc.eventsFilterCredits);
    await tester.tap(creditsFilter);
    await tester.pumpAndSettle();

    expect(find.text(loc.eventSignupBonusTitle), findsOneWidget);
    expect(find.text('message'), findsNothing);
  });
}
