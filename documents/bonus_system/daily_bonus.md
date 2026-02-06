# Daily bonus specifikáció

## Reward definition

- `code = 'daily_bonus'`
- `enabled = true` alapértelmezés szerint, értékét és engedélyező flag-jét kizárólag migrációk módosíthatják.
- Az `amount` változtatható `reward_definitions` migrációval; alapértelmezésben a napi jóváírás értékét tartalmazza.

## Gate-ek

Az alábbi állapotokkal egyeztetett logika dönti el, hogy a napi bónusz kiosztható:

1. `not_authenticated` – még nincs bejelentkezett/felhasználóhoz kötött session.
2. `not_verified` – a felhasználó e-mail címét nem igazolta.
3. `profile_incomplete` – hiányoznak a profil-kötelező mezők (pl. nickname, avatar), ugyanúgy, ahogy a signup bónusznál is ellenőrizzük.
4. `disabled` – a `reward_definitions` sor `enabled = false` állapotban van.

Ezek az esetek a standard grant pipeline pre-ellenőrzésében szerepelnek; a pipeline nem válaszol `false`-ra, csak akkor hajtja végre a grantot, ha egyik gate sem aktív.

## Napi limit

- A napi limitet az **UTC nap** határozza meg (00:00–23:59 UTC), a DB az igazságforrás.
- Javasolt modell: a `reward_grants` táblába bekerül egy `grant_day DATE` oszlop, amely a kiosztás napját tartalmazza UTC-ben.
- Ezen oszlopra opcionálisan partial unique index tehető, például (`user_id`, `grant_day`) komponensekkel, hogy a napi 1× kiosztást a DB szintjén is segítsük.
- A napi limit definícióját mindaddig le lehet írni a dokumentációban, amíg a konkrét migráció külön taskban jön létre.

## RPC contract

- `public.grant_daily_bonus_if_eligible()` – visszaadott típus: `jsonb`.
- Kötelező mezők:
  - `granted` (boolean) – jelzi, hogy a bónusz kiosztásra került-e.
  - `amount` (integer) – a kiosztott `tippcoins` mennyisége (ha nincs grant, akkor 0).
  - `reason` (text) – például `not_authenticated`, `not_verified`, `already_granted`, `granted`.
- Opcióként javasolt mező:
  - `next_eligible_at` (timestamptz) – az a következő UTC időpont, amikor a user újra igényelheti a bónuszt; UI szinten fontos mutató.

## Mellékhatások

Ha a grant megtörténik:

1. `reward_grants` – új rekord (`code = 'daily_bonus'`, `grant_day = DATE_TRUNC('day', NOW() AT TIME ZONE 'UTC')`, `amount` a definícióból).
2. `user_stats.tippcoins` – az adott user sorához hozzáadjuk az `amount` értéket, `updated_at` frissítése.
3. `user_events` – új esemény készül:
   - `type = 'tippcoin_credit'`
   - `code = 'daily_bonus'`
   - `amount` és `payload` megegyezik a grant mögötti adatcsoporttal
   - `read_at = NULL` – alapból olvasatlan.

## UI szerződés (szintű leírás)

- Home tile állapotok:
  - `available`: a user még nem kapta meg a napi bónuszt, `next_eligible_at` későbbi időpont.
  - `claimed`: a napi bónusz kiosztva, az inbox esemény `read_at` ellenőrzésével a tile jelezheti.
  - `offline`: nincs kapcsolat, de az előző `next_eligible_at` alapján jelezhető, hogy a bónusz már lejárt.
- A tile megjelenítéséhez a `next_eligible_at` mező elégséges, ha a mentett érték alapján a kliens kiszámolja az állapotot.

## Lokalizáció (kulcs-javaslatok)

### Tile

- `dailyBonusTitle`
- `dailyBonusClaim`
- `dailyBonusClaimed`
- `dailyBonusOffline`

### Inbox esemény

- `eventDailyBonusTitle`
- `eventDailyBonusBody(amount)`
- `eventDailyBonusBodyRead`

### Általános

- `dailyBonusNextEligible`
- `dailyBonusAlreadyClaimed`

Az ARB-állományokra eltérő feladat hivatkozhat; itt csak javaslatot teszünk.

## Teszt DoD (csak felsorolás)

### DB
- Reward definition létezik (daily_bonus code, enabled, amount becslés).
- `grant_day` + partial unique index vagy megfelelő constraint a napi limithez.
- `reward_grants`, `user_stats`, `user_events` összehangolt update (idempotens).
- RLS: kliens egyetlen user-t lásson (reward_grants read, user_stats read, user_events read/read_at update).

### Flutter/Frontend
- Daily bonus tile képes megjeleníteni available/claimed/offline állapotot a `next_eligible_at` alapján.
- RPC hívás eredménye (granted/amount/reason) helyes hibakezeléssel.
- Inbox event `type/code` alapján megjeleníti a `dailyBonus` szövegeket.
- `next_eligible_at` a kliens oldalon frissül és figyelembe veszi a napi limitet.
