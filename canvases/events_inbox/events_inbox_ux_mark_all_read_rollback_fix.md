# Events Inbox – Mark all read rollback fix (UserEvent.copyWith null readAt + failure test)

**TASK_SLUG:** `events_inbox_ux_mark_all_read_rollback_fix`

## 🎯 Funkció
A markAllRead() rollback akkor is működjön, ha egy vagy több markRead hívás hibára fut.
Jelenleg a UserEvent.copyWith nem engedi a readAt nullára állítását, ezért a sikertelen elemek “read” állapotban maradnak.

## 🧠 Fejlesztési részletek

### 1) UserEvent.copyWith: explicit null támogatás
A `readAt` paramétert úgy kell kezelni, hogy:
- ha nincs megadva → marad a régi érték
- ha explicit `null` → ténylegesen nullára álljon

Javasolt megoldás: sentinel (mint a State copyWith-eknél).
Cél: `event.copyWith(readAt: null)` valóban unread legyen.

Érintett fájl:
- `app/lib/src/features/events/domain/user_event.dart`

### 2) markAllRead finomítás (opcionális, de ajánlott)
- `failed` kezelése Set-tel (ne `contains` listán)
- `isMarkingAllRead` reset biztosítása `try/finally`-val

Érintett fájl:
- `app/lib/src/features/events/application/user_events_provider.dart`

### 3) Új teszt: partial failure + UI állapot
Adj hozzá widget tesztet, ahol a repo 1 id-ra hibát dob:
- credits/all filter nem kötelező, elég “All” alatt
- tap done_all → snackbar partial
- a sikertelen event maradjon unread (pl. a hozzá tartozó ListTile `onTap` továbbra is nem-null)

Új fájl:
- `app/test/widget/events_inbox_mark_all_read_partial_failure_test.dart`

## 🧪 Tesztállapot
- `./scripts/check.sh` PASS

## 🌍 Lokalizáció
Nem szükséges új kulcs ehhez a fixhez.

## 📎 Kapcsolódások
- `docs/data_model/user_events_table_doc.md` (read_at-only update contract)
