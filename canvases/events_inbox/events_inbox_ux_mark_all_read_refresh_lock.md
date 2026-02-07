# Events Inbox – Mark all read refresh lock

**TASK_SLUG:** `events_inbox_ux_mark_all_read_refresh_lock`

## 🎯 Funkció
Addig tartsuk inaktívnak a refresh kontrollokat (ikon gomb + pull-to-refresh), amíg a `markAllRead()` zajlik, hogy a felhasználó ne tudja újraindítani a teljes listát egy közben futó bulk művelet alatt.

## 🧠 Fejlesztési részletek

### 1) UI guard
- Az AppBar refresh gombja csak akkor aktív, ha nincs offline állapot, nincs már futó markAllRead és van konfigurált repo.
- A `RefreshIndicator` `onRefresh`-e először ellenőrzi az `isMarkingAllRead` zászlót, és csak akkor hívja meg a notifier `refresh()`-et, ha nem fut már bulk read.
- Érintett fájl: `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart`

### 2) Widget teszt
- Szimulálj egy `markAllRead()`-ot, amíg az első `markRead` hívás nem fejeződik be (Completer), és ellenőrizd:
  * Az AppBar refresh ikon gombja `onPressed == null`.
  * A pull-to-refresh nem indít új `fetchPage` hívást (repo fetch offset listája marad `[0]`), amíg `isMarkingAllRead` true.
- Az új tesztre új fájl: `app/test/widget/events_inbox_mark_all_read_refresh_lock_test.dart`

### 3) Tesztállapot
- `./scripts/check.sh` – PASS

