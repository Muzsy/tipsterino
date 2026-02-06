# Events Inbox – Filter bar (stabil UI enum + client-side szűrés)

**TASK_SLUG:** `events_inbox_ux_filter_bar`

## 🎯 Funkció

Az `EventsInboxScreen` kapjon egy eseménytípus szerinti **szűrő sort** (Material 3 kompatibilisen), úgy hogy:
- a UI **nem DB `type` stringeket** kezel, hanem egy stabil `EventsFilter` enumot
- MVP-ben a szűrés **client-side** legyen (`items.where(...)`)
- a jelenlegi funkciók **nem sérülhetnek**: initial load, refresh, load-more, read/unread, daily bonus mapping, offline/not_configured állapot

Szűrők (a meglévő specifikáció alapján):
- `all`
- `credits` (TippCoin jóváírások → `type == 'tippcoin_credit'`)
- `social`
- `challenges`
- `system`

Nem cél ebben a taskban:
- “Mark all as read”
- polling / realtime
- repo query átállítás server-side filterre

## 🧠 Fejlesztési részletek

### Valós repo – érintett fájlok (kötelezően ezekre építs)
- `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`
- `app/lib/src/features/events/application/user_events_provider.dart`
- `app/lib/src/features/events/data/user_events_repository.dart` (csak ha muszáj; client-side filterhez nem kell)
- `app/lib/src/features/events/domain/user_event.dart`
- Új fájl: `app/lib/src/features/events/domain/events_filter.dart`

### 1) EventsFilter modell (stabil UI enum)
- Hozd létre az `EventsFilter` enumot.
- Adj hozzá mapping segédet (pl. `bool matches(UserEvent e)`), ami:
  - `all` → mindig true
  - `credits` → `e.type == 'tippcoin_credit'`
  - `social/challenges/system` → jelenleg üres (vagy explicit típuslista), de legyen bővíthető (ne “varázssztringek” szanaszét).

### 2) Provider state: kiválasztott filter tárolása
- A `UserEventsState` kapjon `filter` mezőt (default: `EventsFilter.all`).
- Legyen derived lista (pl. getter): `filteredItems`, ami a filter alapján szűr.
- Legyen `setFilter(EventsFilter value)` a notifierben.
- A `loadInitial/loadMore/refresh` ne nullázza a filtert.

### 3) UI: filter bar az AppBar alatt
- Az `EventsInboxScreen` body elejére tegyél filter UI-t.
- UI komponens: **SegmentedButton** javasolt, de legyen **horizontal scroll**-ba téve, hogy HU feliratoknál se törjön szét.
- A feliratok l10n-ből jönnek (nincs hardcode string).
- A lista renderelése a `state.filteredItems` alapján történjen.
- Empty state: ha a szűrt lista üres, maradhat a meglévő “No events yet” (külön filter-empty copy nem része ennek a tasknak).

### 4) Lokalizáció (HU/EN)
Új kulcsok minimum (a specifikáció alapján):
- `eventsFilterAll`
- `eventsFilterCredits`
- `eventsFilterChallenges`
- `eventsFilterSocial`
- `eventsFilterSystem`

Frissítendő fájlok:
- `app/lib/l10n/app_en.arb`
- `app/lib/l10n/app_hu.arb`
- és a commitolt generated lokalizációs dartok:
  - `app/lib/l10n/app_localizations.dart`
  - `app/lib/l10n/app_localizations_en.dart`
  - `app/lib/l10n/app_localizations_hu.dart`

### 5) Teszt (widget – stabil)
Adj hozzá egy új widget tesztet:
- tölts be 2 eventet: 1) `tippcoin_credit` + `signup_bonus`, 2) pl. `message` (fallback szöveggel)
- default filter (`all`) → mindkettő látszik
- `credits` filterre váltás → csak a tippcoin event marad
- a teszt provider override + fake repository mintára épüljön (ahogy a meglévő `events_inbox_*_test` fájlokban)

## 🧪 Tesztállapot
Kötelező:
- `./scripts/check.sh`

## 🌍 Lokalizáció
- Új filter kulcsok HU/EN + generated frissítés.

## 📎 Kapcsolódások
- `docs/data_model/user_events_table_doc.md` (read_at contract – nem módosítjuk, de nem szabad megsérteni)
- `docs/architect/theme_rules.md` (nincs hardcode szín)
- `docs/localization/localization_logic.md` (ARB + generated frissítés kötelező)
- `docs/qa/testing_guidelines.md` (check.sh kötelező)
- Külső alap spec: `events_inbox_ux_finomitasok_specifikacio_do_d.md` (ennek megfelelő filter modell)
