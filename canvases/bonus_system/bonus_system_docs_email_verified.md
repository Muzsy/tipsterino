# 🎯 Funkció

A bónuszrendszer (Rewards) dokumentációját kell **rendszerszinten rögzíteni és szinkronizálni** úgy, hogy mindenhol konzisztensen szerepeljen:

* a jutalomösszegek **csak repo + migrációval** módosíthatók,
* a kiosztások ledger-szerűen naplózódnak,
* a felhasználó felé minden releváns jóváírás **user_events** formában (in-app inbox) megjelenik,
* a **signup bónusz kizárólag email verifikáció után** jár.

**Fontos:** a `docs/core_logic/bonus_system.md` fájl **már létezik** (a felhasználó létrehozta és tartalommal feltöltötte). Ebben a taskban **nem** módosítjuk, csak a többi doksit igazítjuk hozzá, és hivatkozunk rá.

### Nem cél

* DB migrációk, RLS policy-k implementálása
* RPC/Edge Function megírása
* Flutter-kód és UI (Events screen, SnackBar stb.)

---

## 🧠 Fejlesztési részletek

### Talált releváns fájlok

* `docs/core_logic/bonus_system.md` – **már létezik**, a bónuszrendszer single source of truth dokumentuma (ehhez igazítunk mindent).
* `docs/data_model/reward_definitions_table_doc.md` – jutalomkatalógus (összeg/engedélyezés, kliens tiltás).
* `docs/data_model/reward_grants_table_doc.md` – ledger (kiosztások naplója, idempotencia).
* `docs/data_model/user_stats_table_doc.md` – TippCoin snapshot (kliens nem írhatja).
* `docs/data_model/user_events_table_doc.md` – in-app inbox (jóváírás események + read_at).
* `docs/core_logic/registration_flow.md` – reg flow; itt minden „signup bónusz” triggerpont legyen összhangban a verifikáció utáni kiosztással.

### Pipálható teendők

* [ ] A 4 data_model doksiban **minden** olyan szövegrész ki van javítva, ami a signup bónuszt „profiles insert” vagy „regisztráció lezárása” pillanathoz köti.
* [ ] Mindenhol rögzítve van az új triggerpont: **email verified + első authenticated session** (post-auth init jellegű szerveroldali döntéssel).
* [ ] Mind a 4 data_model doksi tartalmaz kereszthivatkozást a `docs/core_logic/bonus_system.md` fájlra (single source of truth).
* [ ] A data_model doksik elején szereplő „Fájl helye a repóban” sor **nem félrevezető** (valós útvonalra igazított vagy eltávolított).
* [ ] Készült `codex/codex_checklist/bonus_system/bonus_system_docs_email_verified.md` és `codex/reports/bonus_system/bonus_system_docs_email_verified.md`, benne a futtatásokkal és a módosított fájlok listájával.
* [ ] Lefutott a repo standard minőségkapu: `./scripts/check.sh` (vagy dokumentált okból nem), és az eredmény a reportban szerepel.

### Kockázatok + rollback

* **Kockázat:** a tábladokukban marad egy eldugott „regisztráció végén jár” mondat, és a csapat később rossz triggerpontot implementál. **Rollback:** vissza a korábbi verzióra + újra teljes szövegkeresés `signup_bonus`, `registration bonus`, `email verified` kulcsokra.
* **Kockázat:** a `docs/core_logic/bonus_system.md` és a data_model doksik eltérnek egymástól. **Rollback:** a data_model doksikban csak hivatkozás + 1-2 mondatos összefoglaló marad, a részletek kizárólag a core_logic doksiban.

---

## 🧪 Tesztállapot

* `./scripts/check.sh` – repository standard gate (analyze + test).

---

## 🌍 Lokalizáció

* A feladat nem érinti ARB fájlokat.
* A dokumentációban rögzítendő elv: UI megjelenítés `user_events.type + user_events.code` alapján (kulcs-struktúra: `events.<type>.<code>.*`).

---

## 📎 Kapcsolódások

* `docs/core_logic/bonus_system.md` (single source of truth; **nem módosítjuk ebben a taskban**)
* `docs/data_model/reward_definitions_table_doc.md`
* `docs/data_model/reward_grants_table_doc.md`
* `docs/data_model/user_stats_table_doc.md`
* `docs/data_model/user_events_table_doc.md`
* `docs/core_logic/registration_flow.md`

Következő (külön taskok):

* DB schema + RLS migrációk (reward/user_stats/user_events táblák)
* RPC: `grant_signup_bonus_if_eligible()` (verified + idempotens)
* Flutter: post-auth init (RPC meghívás) + Events screen
