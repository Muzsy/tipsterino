# Events Inbox – Mark all as read (összes olvasott)

**TASK_SLUG:** `events_inbox_ux_mark_all_read`

---

## 🎯 Funkció

Az `EventsInboxScreen` kapjon egy AppBar actiont, amivel a felhasználó az aktuálisan látható (szűrt) listában lévő **összes unread** eseményt „olvasottra” jelölheti.

Elvárások:
- AppBar gomb (ikon: pl. `done_all`)
- csak akkor aktív, ha:
  - nem `isNotConfigured`
  - **van legalább 1 unread event** az aktuális listában (a kiválasztott filter szerint)
  - és nincs futó „mark all” művelet
- működés: végigmegy az unread elemeken és `read_at` mezőt állít (a meglévő contract szerint csak `read_at` update)
- UX:
  - **optimista UI**: a UI azonnal read-re áll
  - siker: snackbar
  - részleges/hiba: snackbar + **rollback a sikertelen elemekre** (vagy legalább azok maradjanak unread)

Nem cél ebben a taskban:
- RPC/batch update (`mark_all_user_events_read()`), ez külön task később
- polling/realtime

---

## 🧠 Fejlesztési részletek

### Érintett valós fájlok
- `app/lib/src/features/events/application/user_events_provider.dart`
- `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`
- L10n:
  - `app/lib/l10n/app_en.arb`
  - `app/lib/l10n/app_hu.arb`
  - `app/lib/l10n/app_localizations*.dart` (commitolt generated)
- Teszt:
  - `app/test/widget/events_inbox_mark_all_read_test.dart` (új)

### Provider: `markAllRead()` (filter-aware)
- A művelet **a jelenleg kiválasztott filterre** vonatkozzon: azokat az eventeket kezelje, amik:
  - `state.filter.matches(event)` és
  - `event.isUnread`
- Javasolt state mező:
  - `isMarkingAllRead: bool` (default false), hogy a UI tudja tiltani a gombot és ne lehessen dupla trigger.
- Optimista UI:
  - a célzott eventek `readAt` mezőjét lokálisan állítsd be (egy közös `nowUtc` időpontra)
- Remote update:
  - hívd a meglévő `_repository.markRead(id: ...)`-t minden unread elemre (client loop)
- Hiba esetén:
  - a sikertelen id-kat állítsd vissza `readAt: null`-ra (rollback)
  - a method adjon vissza eredményt, amiből a UI snackbarral tud dönteni (pl. success vs partial)

### UI: AppBar action + snackbar
- AppBar actions:
  - legyen meg a refresh gomb változatlanul
  - új gomb: `Icons.done_all` (vagy ekvivalens)
- Enabled logika:
  - `hasUnreadInCurrentView = state.filteredItems.any((e) => e.isUnread)`
  - disabled, ha `!hasUnreadInCurrentView || state.isNotConfigured || state.isMarkingAllRead`
- Tap után:
  - await `notifier.markAllRead()`
  - snackbar:
    - success: „All marked as read”
    - partial/hiba: „Could not mark all as read” vagy „Marked X, failed Y”

---

## 🧪 Tesztállapot

Kötelező:
- új widget teszt lefedi:
  - credits filter aktív: csak a credits-be eső unread eventeket jelöli olvasottra
  - majd all filter: a maradék unread is kezelhető
  - success snackbar megjelenik
- `./scripts/check.sh` PASS
- checklist + report készül

---

## 🌍 Lokalizáció

Új kulcsok (EN/HU):
- `eventsMarkAllReadTooltip`
- `eventsMarkAllReadSuccess`
- `eventsMarkAllReadPartial` (paraméterekkel: `{succeeded}`, `{failed}`)

---

## 📎 Kapcsolódások

- `docs/data_model/user_events_table_doc.md` (read_at-only update contract)
- `docs/qa/testing_guidelines.md`
- `docs/localization/localization_logic.md`
- `docs/architect/theme_rules.md`
- Spec alap: `events_inbox_ux_finomitasok_specifikacio_do_d.md` (Mark all as read szakasz)
