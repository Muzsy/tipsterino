# Bonus system – MarkRead tesztek megerősítése (dedup hiba javítása)

**TASK_SLUG:** `bonus_system_events_markread_test_hardening`

---

## 🎯 Funkció

Javítsuk a MarkRead-idempotencia teszteket úgy, hogy ténylegesen lebuktassák a dupla `markRead()` hívást.

Jelenleg a fake repo **dedupolja** a `markReadIds` listát (`if (!contains) add`), ezért a teszt akkor is zöld maradna, ha a notifier hibásan kétszer hívná a `markRead`-ot.

---

## 🧠 Fejlesztési részletek

### Érintett fájlok (tény)

- Widget teszt: `app/test/widget/events_inbox_data_flow_test.dart`
- Unit teszt: `app/test/unit/user_events_provider_test.dart`

### Javítás elve

Mindkét fake repo-ban:

- **szedd ki a dedupolást** a `markRead` logból
- vezess be egy **hívásszámlálót**, pl. `int markReadCallCount = 0;`
- a `markRead` mindig:
  - `markReadCallCount++`
  - `markReadIds.add(id)` (duplikátum engedett)

### Elvárt assert változások

#### Widget teszt (idempotencia)

- első tap után:
  - `markReadCallCount == 1`
  - `markReadIds == ['e1']`
- második tap után:
  - **maradjon** `markReadCallCount == 1`
  - `markReadIds.length == 1`

#### Unit teszt (idempotencia)

- első `notifier.markRead(...)` után:
  - `markReadCallCount == 1`
  - `markReadIds == ['e1']`
- második `notifier.markRead(container.read(userEventsProvider).items.first)` után:
  - `markReadCallCount == 1`
  - `markReadIds.length == 1`

Megjegyzés: a második hívásnál **state-ből** vedd az eventet (ami már read), így a notifier idempotencia guardját a valós adat vezérli.

---

## 🧪 Tesztállapot

Kötelező:

- a két érintett teszt fájl frissül
- `./scripts/check.sh` PASS
- checklist + report készül

---

## 🌍 Lokalizáció

Nincs.

---

## 📎 Kapcsolódások

- `codex/codex_checklist/bonus_system/bonus_system_events_markread_test_hardening.md`
- `codex/reports/bonus_system/bonus_system_events_markread_test_hardening.md`
