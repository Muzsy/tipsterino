# Bonus system – Events inbox UI: screen + routing + settings entry + l10n

**TASK_SLUG:** `bonus_system_events_inbox_ui_shell`

---

## 🎯 Funkció

Készüljön el az **Events / In-app inbox** minimum UI és bekötés:

- új route: `/events` a ShellRoute alatt
- Settings screenről belépési pont (ListTile), **routerrel**
- EventsInboxScreen: offline / empty / loading / lista alap megjelenítés
- lokalizáció (EN+HU) az events inbox minimum szövegekhez

### Nem cél

- widget teszt (külön task)
- realtime / push
- event detail screen
- mark all as read

---

## 🧠 Fejlesztési részletek

### Előfeltétel

A core feature már létezik:

- `app/lib/src/features/events/...` (domain+repo+provider)

### Router / Shell / Settings (tény)

- router: `app/lib/src/app/router/app_router.dart`
- shell: `app/lib/src/app/router/app_shell.dart` (bottom nav változatlan)
- settings: `app/lib/src/screens/settings_screen.dart`
- supabase offline szövegek már vannak: `offlineNotice`, `offlineDescription`

### Screen: `EventsInboxScreen`

Követelmények:

- AppBar: `loc.eventsInboxTitle`
- offline/not_configured: mutassa `loc.offlineNotice` + `loc.offlineDescription`
- empty: `loc.eventsEmptyTitle` + `loc.eventsEmptyBody`
- lista: olvasatlan jelölés (pl. félkövér / kis dot), timestamp megjelenítés egyszerűen
- tap: `markRead` csak ha unread
- title/body mapping minimum:
  - type=`tippcoin_credit` + code=`signup_bonus` → `eventSignupBonusTitle` + `eventSignupBonusBody(amount)`
  - fallback: `"$type${code != null ? ':$code' : ''}"`

### Routing + Settings entry

- `app_router.dart`: új GoRoute `path: /events`, `name: events`, builder: `EventsInboxScreen()`
- `settings_screen.dart`: új belépési pont `loc.eventsInboxEntry` címkével
- bottom nav nem bővül

---

## 🧪 Tesztállapot

Nincs ebben a taskban (külön task).

---

## 🌍 Lokalizáció

Új kulcsok minimum:

- `eventsInboxTitle`
- `eventsInboxEntry`
- `eventsEmptyTitle`
- `eventsEmptyBody`
- `eventSignupBonusTitle`
- `eventSignupBonusBody` (param: `{amount}`)

Fájlok:

- `app/lib/l10n/app_en.arb`
- `app/lib/l10n/app_hu.arb`

---

## 📎 Kapcsolódások

Érintett / új fájlok:

- `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart` (új)
- `app/lib/src/app/router/app_router.dart` (módosítás)
- `app/lib/src/screens/settings_screen.dart` (módosítás)
- `app/lib/l10n/app_en.arb` (módosítás)
- `app/lib/l10n/app_hu.arb` (módosítás)
