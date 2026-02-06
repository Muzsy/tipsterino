# Bonus system – Daily bonus specifikáció import + doksi bekötés

**TASK_SLUG:** `bonus_system_daily_bonus_docs_spec_sync`

## 🎯 Funkció

A daily bonus fejlesztésének “single source of truth” specifikációját beemeljük a repóba (documents/ alá),
és a meglévő bonus rendszer core doksiját (`docs/core_logic/bonus_system.md`) úgy frissítjük, hogy:

- egyértelműen hivatkozzon a daily bonus specifikációra,
- rögzítse a daily bonus helyét a standard grant pipeline-ban,
- ne állítson olyat, ami még nincs implementálva DB-ben / app-ban.

**Nem cél ebben a taskban:**
- DB migrációk írása
- RPC implementáció
- Flutter UI / l10n módosítás

## 🧠 Fejlesztési részletek

### Kiinduló állapot (repo alapján)
- Bonus rendszer core doksi: `docs/core_logic/bonus_system.md`
- Reward tábladokuk:
  - `docs/data_model/reward_definitions_table_doc.md`
  - `docs/data_model/reward_grants_table_doc.md`
  - `docs/data_model/user_stats_table_doc.md`
  - `docs/data_model/user_events_table_doc.md`
- A privilege contract fix már reapply-olva van migrációval:
  - `supabase/migrations/20260207000000_bonus_system_privilege_contract_reapply.sql`

### Új specifikáció helye (döntés)
- A daily bonus részletes specifikáció a `documents/` alá kerüljön, mert ez üzleti/termék-spec:
  - `documents/bonus_system/daily_bonus.md`

### Mit tartalmazzon a `documents/bonus_system/daily_bonus.md`
A specifikáció rögzítse, hogy:

- Reward definition:
  - `code='daily_bonus'`, `enabled`, `amount` (repo+migrációval változtatható)
- Gate-ek (konzisztencia a signup bónusszal):
  - `not_authenticated`, `not_verified`, `profile_incomplete`, `disabled`
- Napi limit definíció:
  - **UTC nap (00:00–23:59 UTC)** a DB igazságforrás
  - Ajánlott DB megoldás: `reward_grants.grant_day DATE` + partial unique index
- RPC contract:
  - `public.grant_daily_bonus_if_eligible() -> jsonb`
  - kötelező mezők: `granted`, `amount`, `reason`
  - UI támogatás: `next_eligible_at` (timestamptz) opcionálisan, de javasolt
- Mellékhatások:
  - grant → `reward_grants`
  - stat → `user_stats.tippcoins += amount`
  - inbox → `user_events` (`type='tippcoin_credit'`, `code='daily_bonus'`)
- UI elvárás (csak szerződés szinten):
  - Home tile: available/claimed/offline
  - claimed állapothoz elég a `next_eligible_at`
- Lokalizáció (kulcsok javaslat):
  - tile: `dailyBonusTitle`, `dailyBonusClaim`, `dailyBonusClaimed`, stb. (HU/EN)
  - inbox: `eventDailyBonusTitle`, `eventDailyBonusBody(amount)` (HU/EN)
- Teszt DoD (DB + Flutter) csak felsorolás szinten.

### `docs/core_logic/bonus_system.md` módosítás
- Adj hozzá egy rövid “Daily bonus” szekciót:
  - link a `documents/bonus_system/daily_bonus.md` fájlra
  - rögzítsd, hogy daily bonus = standard grant pipeline + napi (UTC) idempotencia
  - jelezd, hogy az implementáció külön taskokban történik (migráció/RPC/UI)

### Pipálható teendők
- [ ] `documents/bonus_system/daily_bonus.md` létrehozása a specifikációval
- [ ] `docs/core_logic/bonus_system.md` frissítése (daily bonus link + rövid összefoglaló)
- [ ] Nincs “kész” állítás DB/UI kapcsán ebben a taskban
- [ ] Checklist + report elkészítése, repo gate futtatása

### Kockázatok / rollback
- Kockázat: a core doksi túl konkrét lesz és ellentmond a jelenlegi implementációnak.
- Mitigáció: a módosítások “spec link + contract summary” szinten maradnak.
- Rollback: a két markdown commit visszavonható mellékhatás nélkül.

## 🧪 Tesztállapot

Ebben a taskban csak repo gate:
- `./scripts/check.sh`

(DB push / psql checks nem része ennek a tasknak.)

## 🌍 Lokalizáció

Csak specifikációs szinten rögzítjük a javasolt kulcsokat.
ARB módosítás külön taskban történik.

## 📎 Kapcsolódások

Következő várható taskok (külön canvas+yaml):
- DB séma: `reward_grants.grant_day` + indexek + schema checks
- Migráció: `reward_definitions` daily_bonus rekord
- RPC: `grant_daily_bonus_if_eligible()` + privilege
- DB behavior checks
- Flutter: daily bonus RPC wrapper + home tile + inbox mapping + l10n + tesztek
