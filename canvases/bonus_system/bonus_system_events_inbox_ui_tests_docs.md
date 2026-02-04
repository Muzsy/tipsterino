# Bonus system – Events inbox UI: widget test + docs + gate

**TASK_SLUG:** `bonus_system_events_inbox_ui_tests_docs`

---

## 🎯 Funkció

Kerüljön be a minimum bizonyítás, hogy a `/events` route elérhető és **offline (not_configured)** állapotban stabilan renderel.

Emellett készüljön Codex checklist + report, és fusson a repo gate.

---

## 🧠 Fejlesztési részletek

### Teszt minta (tény)

A repóban van minta auth override-ra:
- `app/test/widget/guest_routing_shells_test.dart`

### Widget teszt elvárás

- új teszt: `app/test/widget/events_inbox_route_test.dart`
- ProviderScope overrides:
  - `authNotifierProvider` → AuthViewState(status: authenticated), autoListen=false
  - `supabaseConfigProvider` → isConfigured=false
- routerrel `router.go('/events')`
- assert:
  - `loc.eventsInboxTitle` megjelenik
  - `loc.offlineNotice` megjelenik

---

## 🧪 Tesztállapot

Kötelező:

- `flutter test` részeként lefutó widget teszt
- `./scripts/check.sh` PASS

---

## 🌍 Lokalizáció

Nincs új kulcs.

---

## 📎 Kapcsolódások

Új / érintett fájlok:

- `app/test/widget/events_inbox_route_test.dart`
- `codex/codex_checklist/bonus_system/bonus_system_events_inbox_ui_tests_docs.md`
- `codex/reports/bonus_system/bonus_system_events_inbox_ui_tests_docs.md`
