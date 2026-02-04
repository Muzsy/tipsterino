# Bonus system – Events / In‑app inbox UI

**TASK_SLUG:** `bonus_system_events_inbox_ui`

---

## 🎯 Funkció

Készüljön el az alkalmazásban az **Events / In‑app inbox** felület, ami a `public.user_events` táblából olvassa a felhasználó saját eseményeit, és lehetővé teszi a **read_at** jelölést.

Minimum funkciók:

1. **Lista nézet**

* események időrendben (legújabb elöl)
* olvasatlan / olvasott megkülönböztetés (read_at null → olvasatlan)
* alap megjelenítés: title + timestamp + (ha van) amount

2. **Olvasottra jelölés**

* elemre tap: `read_at = now()` update (csak ha eddig null)
* update kizárólag `read_at`-ra (DB GRANT is így van)

3. **Offline / nincs Supabase konfiguráció**

* ha `supabaseConfigProvider.isConfigured == false`, a screen nem próbál DB-t hívni, hanem offline nézetet mutat.

4. **Elérés a UI-ban**

* új route: `/events`
* settings screenről bejárat (ListTile)
* a bottom nav nem bővül (events nem tab)

### Nem cél

* push notification
* real-time stream (Supabase Realtime)
* “mark all as read” (opcionális későbbi task)
* részletes event-detail képernyő (opcionális)

---

## 🧠 Fejlesztési részletek

### Forrás-igazság

* DB tábla + RLS/grant:

  * `supabase/migrations/20260203000000_bonus_system_db_schema_rls.sql`
  * `docs/data_model/user_events_table_doc.md`
* Bonus event szerződés:

  * `docs/core_logic/bonus_system.md`
  * signup bónusz event: `type='tippcoin_credit'`, `code='signup_bonus'`, `amount=<int>`

### Meglévő app struktúra (tény)

* Router: `app/lib/src/app/router/app_router.dart` (go_router)
* Shell: `app/lib/src/app/router/app_shell.dart` (auth/guest tabok)
* Settings screen: `app/lib/src/screens/settings_screen.dart`
* Supabase config: `app/lib/src/core/clients/supabase_provider.dart` (jelenleg stub, offline is lehetséges)
* Riverpod: StateNotifier mintázat (lásd auth_provider, post_auth_init_provider)

### Javasolt implementáció

**Új feature:** `app/lib/src/features/events/`

* `domain/user_event.dart` – típusos model (id, type, code, amount, payload, createdAt, readAt)
* `data/user_events_repository.dart` – Supabase query/update
* `application/user_events_provider.dart` – StateNotifier (load/refresh/pagination/markRead)
* `presentation/screens/events_inbox_screen.dart` – UI

**Query szabályok:**

* select: `from('user_events').select().order('created_at', ascending: false)`
* paging: `.range(offset, offset + limit - 1)` (limit pl. 30)
* mark read: `from('user_events').update({'read_at': nowIso}).eq('id', id)`

**Fallback viselkedés:**

* ha `supabaseConfigProvider` nincs konfigurálva → offline UI (ne dobjon kivételt)
* ha query fail → error state + retry gomb

### Pipálható teendők

* [ ] Új route `/events` felvétele az AppShell alá (nem tab)
* [ ] Settings screen: navigáció a route-ra routerrel (ne Navigator.push)
* [ ] Events feature: domain+repo+notifier+screen
* [ ] Lokalizáció: új kulcsok EN+HU
* [ ] Widget smoke teszt az `/events` route-ra (offline állapotban is renderel)
* [ ] `./scripts/check.sh` PASS

---

## 🧪 Tesztállapot

Kötelező:

* 1 db widget teszt: `/events` route renderel + offline állapot megjelenik
* `./scripts/check.sh`

---

## 🌍 Lokalizáció

Új kulcsok (minimum):

* `eventsInboxTitle`
* `eventsInboxEntry`
* `eventsEmptyTitle`
* `eventsEmptyBody`
* `eventSignupBonusTitle`
* `eventSignupBonusBody` (param: `{amount}`)

Mindkét fájlban:

* `app/lib/l10n/app_en.arb`
* `app/lib/l10n/app_hu.arb`

---

## 📎 Kapcsolódások

Érintett / új fájlok (várható):

* `app/lib/src/app/router/app_router.dart`
* `app/lib/src/screens/settings_screen.dart`
* `app/lib/src/features/events/domain/user_event.dart`
* `app/lib/src/features/events/data/user_events_repository.dart`
* `app/lib/src/features/events/application/user_events_provider.dart`
* `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`
* `app/lib/l10n/app_en.arb`
* `app/lib/l10n/app_hu.arb`
* `app/test/widget/events_inbox_route_test.dart`
* `codex/codex_checklist/bonus_system/bonus_system_events_inbox_ui.md`
* `codex/reports/bonus_system/bonus_system_events_inbox_ui.md`
