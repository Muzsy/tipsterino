# Bonus system – Events inbox UI javítás (P0+P1+P2)

**TASK_SLUG:** `bonus_system_events_inbox_ui_fix`

---

## 🎯 Funkció

Javítsuk a `EventsInboxScreen` működését és themingjét:

- **P0**: belépéskor induljon el az első betöltés (`loadInitial()`), ne maradjon “örök üres” állapotban.
- **P1**: a UI feleljen meg a `docs/architect/theme_rules.md` szabályainak:
  - ne legyen `Colors.*` hardcode (pl. `Colors.blue`)
  - ne legyen ad-hoc `TextStyle(fontSize/...)` és a címek/kiemelések is `TextTheme` alapúak legyenek
- **P2**: UX bővítés:
  - AppBar refresh ikon → `refresh()`
  - pull-to-refresh a listában
  - infinite scroll (scroll threshold → `loadMore()`)

---

## 🧠 Fejlesztési részletek

### Érintett fájl (tény)

- `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`

### P0 – initial load

- Alakítsd a képernyőt `ConsumerStatefulWidget`-té.
- `initState()`-ben **egyszer** hívd meg a `userEventsProvider.notifier.loadInitial()`-t (microtask), `mounted` guarddal.
- A betöltés ne build()-ből induljon, csak lifecycle-ból.

### P1 – Theme szabályok (elsődleges)

Kötelezően tartsd be:

- `docs/architect/theme_rules.md`
- Unread jelöléshez használd a `Theme.of(context).colorScheme.primary`-t (vagy hasonló token).
- Offline/Empty címsorokhoz használd a `Theme.of(context).textTheme.titleMedium`-et, és csak fontWeight finomhangolás legyen (ha kell).

### P2 – refresh + loadMore

- AppBar action refresh ikon:
  - `onPressed: state.isNotConfigured ? null : notifier.refresh`
- Listás állapot:
  - `RefreshIndicator(onRefresh: notifier.refresh, child: ListView...)`
  - `ScrollController` + listener:
    - ha `extentAfter < threshold` és `hasMore` és nem loading → `notifier.loadMore()`

---

## 🧪 Tesztállapot

Ebben a taskban **nem** bővítjük a teszteket.
A következő körben külön task lesz:
- configured state fetch bizonyítás (repo override / fake)
- loadMore trigger teszt
- markRead state update teszt

---

## 🌍 Lokalizáció

Nincs új kulcs.

---

## 📎 Kapcsolódások

- `docs/architect/theme_rules.md`
- `app/lib/src/features/events/application/user_events_provider.dart`
