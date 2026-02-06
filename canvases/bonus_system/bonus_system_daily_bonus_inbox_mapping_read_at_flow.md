# Inbox – daily bonus event megjelenítés + read_at flow

**TASK_SLUG:** `bonus_system_daily_bonus_inbox_mapping_read_at_flow`

## 🎯 Funkció

A `user_events` alapú Inbox-ban megjeleníteni a daily bonus jóváírás eseményt, és biztosítani a “megnyitás → read_at beállítás” flow-t:

- Ha `user_events.type='tippcoin_credit'` és `code='daily_bonus'`, akkor:
  - dedikált, lokalizált title/body jelenjen meg (amount paraméterrel)
- Ha a user rákattint egy unread eseményre:
  - kliensoldalon **csak** a `read_at` mezőt frissítjük (RLS/privilege contract szerint)
  - a listában azonnal “read” állapotba kerüljön

Nem cél ebben a taskban:
- új adatmodell bevezetése a DB-ben (csak UI/data layer)
- “mark all as read”
- daily bonus tile módosítások

## 🧠 Fejlesztési részletek

### Preflight (valós repo)
Keress rá és rögzítsd:
- hol van az Inbox képernyő (tipikusan `EventsInboxScreen` / `InboxScreen` névvel)
- hol történik a `user_events` lekérdezése (Supabase select)
- hol van a “read/unread” állapot kezelése (read_at alapján)
- van-e meglévő “mark as read” update logika; ha nincs, hozd létre minimalisan

**Kulcsszavak a kereséshez:** `user_events`, `read_at`, `Inbox`, `EventsInbox`, `markRead`, `tippcoin_credit`, `code`

### 1) Daily bonus event copy mapping

Megvalósítási elv:
- legyen egy egyértelmű mapping réteg, ami az event adatokból title/body szöveget állít elő
- daily bonus esetén:
  - title: lokalizált “Daily bonus” / “Napi bónusz”
  - body: amount paraméterrel (pl. “+50 TippCoins …” / “+50 TippCoin …”)

Ha már van event mapper (pl. switch type/code alapján), abba építsd be.
Ha nincs, hozz létre egy kicsi helper-t ugyanott, ahol a list item UI épül.

### 2) read_at flow (csak oszlop update)

Viselkedés:
- Inbox list item tap:
  - ha `read_at == null`: update `user_events` táblában `read_at = now().toUtc().toIso8601String()`
  - **csak** a read_at mezőt update-eld (ne küldj más mezőt)
- UI:
  - optimista frissítés megengedett (azonnal “read” megjelenítés), de hiba esetén rollback vagy snack/log

### 3) Lokalizáció (HU/EN) + generated dart frissítés

Új ARB kulcsok:

EN (`app/lib/l10n/app_en.arb`)
- `event_daily_bonus_title`: "Daily bonus"
- `event_daily_bonus_body`: "Daily bonus credited: +{amount} TippCoins."

HU (`app/lib/l10n/app_hu.arb`)
- `event_daily_bonus_title`: "Napi bónusz"
- `event_daily_bonus_body`: "Napi bónusz jóváírva: +{amount} TippCoin."

Frissítendő generated fájlok (mivel a repo-ban commitolva vannak):
- `app/lib/l10n/app_localizations.dart`
- `app/lib/l10n/app_localizations_en.dart`
- `app/lib/l10n/app_localizations_hu.dart`

### 4) Widget teszt (minimum, stabil)

Adj hozzá egy widget tesztet, ami:
- megjelenít egy Inbox list itemet daily bonus event adatokkal (`code='daily_bonus'`, `amount=50`)
- ellenőrzi, hogy a title/body a daily bonus kulcsokra épül (HU vagy EN locale)
- read_at flow: tap → meghívódik a “mark read” (ezt mock/override-old providerrel), és a UI read állapotba vált

Ha az Inbox architektúrája nem könnyen tesztelhető (pl. közvetlen Supabase hívás a widgetben), akkor:
- bontsd ki a “markRead” hívást providerbe / callbackbe, és a tesztben override-old.

## 🧪 Tesztállapot

Kötelező:
- `./scripts/check.sh`

## 🌍 Lokalizáció

- Új 2 kulcs HU/EN + generated dart frissítés

## 📎 Kapcsolódások

- DB event: `public.user_events` (`type='tippcoin_credit'`, `code='daily_bonus'`, `amount`, `read_at`)
- Daily bonus grant RPC mellékhatása már létrehozza a user_events sort (20260210000000)
- Privilege contract: authenticated csak `read_at`-ot update-elhet (ezt kliens oldalon is tartsuk)
