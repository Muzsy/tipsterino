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

- Az **UTC nap** (00:00–23:59 UTC) határozza meg az idempotens napi kiosztást, a DB-ben tartjuk nyilván.
- A `reward_grants.grant_day DATE` mező tartalmazza a kiosztás napját: `(now() AT TIME ZONE 'UTC')::date`.
- A `daily_bonus` esetén a `grant_day` mező nem lehet NULL (a migráció egy CHECK constrainttel biztosítja).
- A `reward_grants_user_daily_bonus_day_unique` partial unique index (user_id, code, grant_day WHERE code = 'daily_bonus') garantálja, hogy minden user naponta egyszer kaphat `daily_bonus`-t.

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

1. `reward_grants` – új rekord (`code = 'daily_bonus'`, `grant_day = (now() AT TIME ZONE 'UTC')::date`, `amount` a definícióból).
2. `user_stats.tippcoins` – az adott user sorához hozzáadjuk az `amount` értéket, `updated_at` frissítése.
3. `user_events` – új esemény készül:
   - `type = 'tippcoin_credit'`
   - `code = 'daily_bonus'`
   - `amount` és `payload` megegyezik a grant mögötti adatcsoporttal
   - `read_at = NULL` – alapból olvasatlan.

## UI szerződés (szintű leírás)

- A `next_eligible_at` mező és az aktuális idő (`now()`) határozza meg a tile állapotát.
- `available`: a user most jogosult (`next_eligible_at` hiányzik vagy `<= now()`), a claim gomb aktív.
- `claimed`: a napi bónuszt már igényelték, ezért a `next_eligible_at` jövőbeli (tipikusan a következő napi 00:00 UTC); a tile letilthatja a claim gombot.
- `offline`: nincs hálózati kapcsolat; az utolsó cache-elt `next_eligible_at` alapján becsülhető, melyik állapot valószínű (ha `<= now()` → `available`, egyébként `claimed`).
- A claimed állapotot **ne** az inbox `read_at` mezője alapján számítsuk, mert az csak az esemény olvasottságát jelzi, nem a grant tényét.

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
