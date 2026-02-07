# Events Inbox – Polling alapú automatikus frissítés (minimal safe)

**TASK_SLUG:** `events_inbox_ux_polling_refresh`

## 🎯 Funkció

Az Events Inbox automatikusan frissüljön, ha új esemény érkezik (pl. jóváírás), minimál invazív és stabil módon.

Cél:
- Polling alapú refresh (30–60s intervallum) **csak akkor**, ha:
  - az EventsInboxScreen látható (widget mounted)
  - az app foregroundban van (resumed)
  - Supabase konfigurált (nem `isNotConfigured`)
- A polling hívás a meglévő `UserEventsNotifier.refresh()`-t használja (nem új query út).

Nem cél ebben a taskban:
- Supabase Realtime csatorna (külön task)
- Repo/query átalakítás “head check”-re vagy server-side filterre
- Új UI elemek / új l10n kulcsok

## 🧠 Fejlesztési részletek

### Kötelezően figyelembe vett doksik
- `docs/codex/overview.md` + `docs/codex/yaml_schema.md` (workflow + outputs szabály)
- `AGENTS.md` (wrapper scriptek, app/ az egyetlen célpont)
- `docs/data_model/user_events_table_doc.md` (szerződés: only read_at update, paging, ordering)
- `docs/core_logic/bonus_system.md` (in-app inbox szerepe)

### Érintett valós fájlok
- `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`
- Teszt: `app/test/widget/events_inbox_polling_refresh_test.dart`

### Előzetes helyzetfelmérés
- Az `EventsInboxScreen` jelenleg `ConsumerStatefulWidget`, és az `initState`-ben (Future.microtask) behívja `userEventsProvider.notifier.loadInitial()`-t.
- A `RefreshIndicator` és az AppBar `refresh` gombja az `notifier.refresh()`-re mutat, és a `UserEventsNotifier` loadMore/refresh guardjai (`isNotConfigured`, `isLoading`, `isLoadingMore`, `hasMore`) biztosítják, hogy egyszerre ne fusson több frissítés.
- A `loadMore`-ban a `state.filteredItems` alapján vizsgáljuk az `isNotConfigured`, `isLoading`, `isLoadingMore`, `!hasMore` állapotokat, így a pollingnak ezzel nem szabad versenyeznie.

### Implementációs terv (minimal safe polling)
1) `EventsInboxScreen` legyen `ConsumerStatefulWidget`, és kezeljen egy `Timer.periodic` pollingot.
2) Polling intervallum: 45s (a spec 30–60s sávjában).
3) Timer tick logika:
   - olvasd a `userEventsProvider` state-et
   - ha `isNotConfigured` vagy `isLoading` vagy `isLoadingMore` vagy `isMarkingAllRead` → skip
   - különben `ref.read(userEventsProvider.notifier).refresh()`
4) App lifecycle:
   - `WidgetsBindingObserver`:
     - `resumed` → polling indul/folytatódik
     - `inactive/paused/detached` → polling leáll (timer cancel)
5) `dispose()`-ban mindig cancel + observer remove (timer leak tilos).

### Kockázatok / mitigáció
- Tesztekben Timer leak → kötelező dispose cancel + olyan teszt, ami route váltással igazolja a cancel-t.
- Felesleges refresh spam → tick skip guardok a state alapján.

## 🧪 Tesztállapot

Kötelező widget teszt:
- Fake repo számolja a `fetchPage` hívásokat.
- Events route megnyitásakor 1× loadInitial (fetchPage).
- Virtuális idő léptetés (>= polling intervallum) után újabb `fetchPage` történik (refresh).
- Navigáció el a képernyőről → újabb időléptetés után **nem nő** tovább a fetchPage számláló (timer cancel igazolás).

Repo gate:
- `./scripts/check.sh` PASS

## 🌍 Lokalizáció
Nincs új UI szöveg → nincs új ARB kulcs.

## 📎 Kapcsolódások
- `canvases/events_inbox/events_inbox_ux_filter_bar.md`
- `canvases/events_inbox/events_inbox_ux_mark_all_read.md`
- `docs/data_model/user_events_table_doc.md`
- `docs/core_logic/bonus_system.md`
