# Events Inbox – UX finomítások docs sync + DoD

**TASK_SLUG:** `events_inbox_ux_finomitasok_docs_sync`

## 🎯 Funkció
Készüljön egy stabil, repóban tárolt dokumentum az Events Inbox UX finomításokról (filter bar, mark all read, polling + route visibility guard), és rögzítsük a DoD-t egy helyen.

## 🧠 Fejlesztési részletek

### 1) Preflight: meglévő doksik és implementáció összerendezése
Kötelezően vedd figyelembe:
- `docs/data_model/user_events_table_doc.md` (type/read_at contract)
- Implementáció:
  - `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`
  - `app/lib/src/features/events/application/user_events_provider.dart`
  - `app/lib/src/features/events/domain/events_filter.dart`
  - `app/lib/src/features/events/domain/user_event.dart`

### 2) Új docs fájl létrehozása
Hozz létre (ha nincs) `docs/screens/` mappát, és készítsd el:
- `docs/screens/events_inbox_screen.md`

Tartalom minimum:
- Cél és scope (mi van kész, mi nincs)
- UI elemek: filter bar (SegmentedButton), mark all read gomb, empty states, load-more
- Filter logika: `EventsFilter` enum + jelenlegi mapping (credits = tippcoin_credit; social/challenges/system jelenleg “empty by design”)
- Mark all read: csak a *jelenlegi filter* alatti unread-ekre, optimista + partial rollback
- Polling: 45s, lifecycle guardok + route visibility guard (TickerMode + ModalRoute.isCurrent), dispose cleanup
- State machine röviden (`isLoading`, `isLoadingMore`, `isMarkingAllRead`, `isNotConfigured`, `hasMore`)
- Tesztek: felsorolni a kapcsolódó widget teszteket
- DoD: egy pipálható lista “mi számít késznek” (UI + l10n + teszt + check.sh)

### 3) docs/README.md frissítés (link)
A `docs/README.md`-ben a kapcsolódó anyagokhoz adj hozzá egy link-szerű hivatkozást (szövegesen) az új Events Inbox screen doksira.

### 4) Mit dokumentálunk
- A filter sávot és a `EventsFilter` enum véges térképét, plusz hogy a `credits` filter a `tippcoin_credit` típusokra szűr, míg a többi filter (social/challenges/system) jelenleg “empty by design”.
- A „mark all read” gomb működését (csak az aktuális filter alatti unread-ekre), az optimista frissítést és a rollback logikát, valamint a `isMarkingAllRead` jelző szerepét az UI/guardok mellett.
- A 45 másodperces polling biztosítását, a lifecycle + route visibility guardokat (`TickerMode`, `ModalRoute.isCurrent`) és a `userEventsProvider` state machine állapotait (`isLoading`, `isLoadingMore`, `isMarkingAllRead`, `isNotConfigured`, `hasMore`).
- Kapcsolódó widget teszteket (filter, polling guard, daily bonus) és a DoD pipálható pontjait (UI, lokalizáció, teszt, `./scripts/check.sh`).

## 🧪 Tesztállapot
- `./scripts/check.sh` futtatása (PASS vagy dokumentált ok, ha nem futtatható adott környezetben)

## 🌍 Lokalizáció
A doksiban sorold fel a jelenleg használt kulcsokat (legalább):
- `eventsFilterAll`, `eventsFilterCredits`, `eventsFilterSocial`, `eventsFilterChallenges`, `eventsFilterSystem`
- `eventsMarkAllReadTooltip`, `eventsMarkAllReadSuccess`, `eventsMarkAllReadPartial`
- `eventsEmptyTitle`, `eventsEmptyBody`

## 📎 Kapcsolódások
- Data model: `docs/data_model/user_events_table_doc.md`
- Bonus system: `docs/core_logic/bonus_system.md` (új credit események tipikus forrása)
- Canvases: az eddigi Events Inbox UX vásznak (filter/mark-all/polling) mint történeti nyomvonal
