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
  final List<String> markReadIds = [];

  @override
  Future<List<UserEvent>> fetchPage({required int offset, required int limit}) async {
    await Future.delayed(Duration.zero);
    return List<UserEvent>.from(_events);
  }

  @override
  Future<void> markRead({required String id}) async {
    await Future.delayed(Duration.zero);
    markReadIds.add(id);
  }
}

Widget _buildTestScreen(FakeUserEventsRepository repository) {
  return ProviderScope(
    overrides: [
      userEventsRepositoryProvider.overrideWithValue(repository),
      supabaseConfigProvider.overrideWithValue(const SupabaseConfiguration(isConfigured: false)),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: const EventsInboxScreen(),
    ),
  );
}

Future<void> _pumpInitialScreen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

UserEvent _dailyBonusEvent() {
  final now = DateTime.now();
  return UserEvent(
    id: 'daily-1',
    type: 'tippcoin_credit',
    code: 'daily_bonus',
    amount: 50,
    payload: null,
    createdAt: now,
    readAt: null,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('daily bonus events render localized copy and mark read flows', (tester) async {
    final repository = FakeUserEventsRepository([_dailyBonusEvent()]);
    await tester.pumpWidget(_buildTestScreen(repository));
    await _pumpInitialScreen(tester);

    final loc = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(loc.event_daily_bonus_title), findsOneWidget);
    expect(find.text(loc.event_daily_bonus_body(50)), findsOneWidget);

    final tileFinder = find.byType(ListTile);
    expect(tileFinder, findsOneWidget);
    expect(tester.widget<ListTile>(tileFinder).onTap, isNotNull);

    await tester.tap(tileFinder);
    await tester.pumpAndSettle();

    expect(repository.markReadIds, equals(['daily-1']));
    expect(tester.widget<ListTile>(tileFinder).onTap, isNull);
  });
}
