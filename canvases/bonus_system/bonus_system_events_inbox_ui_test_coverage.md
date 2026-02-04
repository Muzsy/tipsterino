# Bonus system – Events inbox UI tesztlefedettség bővítés

**TASK_SLUG:** `bonus_system_events_inbox_ui_test_coverage`

---

## 🎯 Funkció

Bővítsük a widget tesztlefedettséget az Events inboxhoz úgy, hogy a **fő működési útvonalak** bizonyítva legyenek:

1) **Configured + data fetch**: /events nyitáskor lefut a loadInitial és megjelenik a lista tartalma (signup bonus mapping).
2) **Refresh**: a képernyőn van `RefreshIndicator`, és az AppBar refresh action újra meghívja a fetch-et.
3) **Load more**: scroll a lista végére → meghívódik a `loadMore()` és új page fetch történik.
4) **Mark read**: unread eventre tap → `markRead` meghívódik **pont egyszer**, majd második tap már nem hívja újra.

---

## 🧠 Fejlesztési részletek

### Meglévő minták (tény)

- App összeállítás tesztekben: `ProviderScope(overrides: ...)` + `TipsterinoApp()`  
  Példa: `app/test/widget/guest_routing_shells_test.dart`
- /events offline teszt: `app/test/widget/events_inbox_route_test.dart`

### Tesztelési stratégia (nincs külső mock lib)

A `userEventsRepositoryProvider` típusa `Provider<UserEventsRepository?>`, ezért a tesztben **override-oljuk** egy fake repo példánnyal:

- `FakeUserEventsRepository extends UserEventsRepository`
  - super-nek adunk egy dummy `SupabaseClient('http://localhost', 'anon')`-t,
  - felülírjuk a `fetchPage` és `markRead` metódusokat,
  - logoljuk a hívásokat (offset lista, markRead id lista).

### Navigáció

- `TipsterinoApp` render után:
  - `final router = GoRouter.of(tester.element(find.byType(Scaffold).first));`
  - `router.go('/events');`

### Bizonyítandó viselkedések

1) **Initial load + mapping**
   - fake page(0) tartalmaz 1 eventet: `type=tippcoin_credit`, `code=signup_bonus`, `amount=100`, `readAt=null`
   - elvárás: `loc.eventSignupBonusTitle` és `loc.eventSignupBonusBody('100')` megjelenik
   - elvárás: fake repo fetch offsets tartalmazza `0`

2) **Refresh**
   - elvárás: `RefreshIndicator` widget létezik a listás állapotban
   - AppBar refresh gomb tap → fake repo fetch offsetsben megjelenik **másodszor** a `0`
   - a refresh ikon keresése legyen rugalmas (`Icons.refresh` / `Icons.refresh_outlined`), és ha egyik sincs, a teszt bukjon.

3) **Load more**
   - fake page(0) pontosan 20 itemet ad vissza (hogy `hasMore=true` legyen)
   - fake page(20) ad vissza 1 itemet
   - scroll a lista végére → elvárás: fetch offsets tartalmazza `20`

4) **Mark read idempotens**
   - 1 unread event (id: e.g. `e1`)
   - tap a tile-on → elvárás: fake.markReadIds == ['e1']
   - pump, majd tap újra ugyanarra a tile-ra → elvárás: fake.markReadIds továbbra is csak 1 elem (nem duplázódik)

---

## 🧪 Tesztállapot

Kötelező:

- új widget teszt fájl: `app/test/widget/events_inbox_data_flow_test.dart`
- `./scripts/check.sh` PASS
- checklist + report elkészítése

---

## 🌍 Lokalizáció

Nincs új kulcs.
A tesztek `AppLocalizations.delegate.load(Locale('en'))` alapján ellenőrizzenek stringeket.

---

## 📎 Kapcsolódások

- `docs/architect/theme_rules.md` (indirekt: a képernyő UI-ja már ehhez igazítva)
- `app/lib/src/features/events/application/user_events_provider.dart` (provider override)
- `app/test/widget/events_inbox_route_test.dart` (korábbi offline teszt)
- `app/test/widget/guest_routing_shells_test.dart` (ProviderScope + TipsterinoApp minta)
