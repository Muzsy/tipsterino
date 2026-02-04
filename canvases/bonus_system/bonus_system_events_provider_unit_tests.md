# Bonus system – Events provider unit tesztek (UserEventsNotifier)

**TASK_SLUG:** `bonus_system_events_provider_unit_tests`

---

## 🎯 Funkció

Készüljön el **provider-szintű unit tesztlefedettség** a `UserEventsNotifier` logikájára (UI nélkül).

Bizonyítandó minimum:

1) **not_configured**: repo = null → state.isNotConfigured igaz, `loadInitial/loadMore` nem fut DB-hívásra.
2) **loadInitial**: sikeres első page → items betölt, hasMore helyes (pageSize=20 logika), loading flag visszaáll.
3) **refresh**: `refresh()` ugyanazt csinálja mint `loadInitial()` (page 0 újrahúzás), items felülíródik.
4) **loadMore**: pageSize esetén `loadMore()` fetch offset = items.length, append, hasMore frissül.
5) **markRead**: unread esemény → repo `markRead` 1×, state-ben `readAt` nem null; ismételt hívás **state-ből vett** eventtel nem hívja újra.
6) **error handling**:
   - fetch hiba → `errorMessage` beáll, loading flag reset
   - loadMore hiba → `errorMessage` beáll, `isLoadingMore=false`, items nem vesznek el
   - markRead hiba → `errorMessage` beáll, readAt nem változik

---

## 🧠 Fejlesztési részletek

### Érintett források (tény)

- `app/lib/src/features/events/application/user_events_provider.dart`
- `app/lib/src/features/events/data/user_events_repository.dart`
- `app/lib/src/features/events/domain/user_event.dart`
- unit teszt minta: `app/test/unit/bonusubsx_system_post_auth_init_test.dart`

### Fake repo (mock lib nélkül)

A tesztben készíts `FakeUserEventsRepository extends UserEventsRepository` osztályt:

- super-nek `SupabaseClient('http://localhost', 'anon')` dummy kliens
- override:
  - `fetchPage({offset, limit})` → előre beállított page map alapján ad vissza listát, és logolja az offseteket
  - `markRead({id})` → logolja az id-ket
- támogatott hibaszimuláció:
  - fetch dobjon exceptiont
  - markRead dobjon exceptiont

### Tesztfájl helye

- `app/test/unit/user_events_provider_test.dart`

---

## 🧪 Tesztállapot

Kötelező:

- új unit teszt fájl létrejön, és része a `flutter test` futásnak
- `./scripts/check.sh` PASS
- checklist + report elkészül

---

## 🌍 Lokalizáció

Nincs.

---

## 📎 Kapcsolódások

- `codex/codex_checklist/bonus_system/bonus_system_events_provider_unit_tests.md`
- `codex/reports/bonus_system/bonus_system_events_provider_unit_tests.md`
