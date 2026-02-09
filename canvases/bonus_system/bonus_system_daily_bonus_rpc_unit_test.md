# FILE: canvases/bonus_system/bonus_system_daily_bonus_rpc_unit_test.md

# P1-6: daily_bonus_rpc célzott unit teszt (RPC wrapper viselkedés + mapping)

## 🎯 Funkció
Legyen célzott **unit teszt** a `daily_bonus_rpc` wrapperre, ami biztosítja, hogy:
- a wrapper a nyers RPC JSON-t stabilan **DailyBonusGrantResult**-té alakítja,
- a tipikus `reason` értékek (granted / disabled / already_claimed_today / not_verified / not_authenticated / profile_incomplete) jól mennek át,
- a `next_eligible_at` parse működik,
- és a teszt **CI-ben automatikusan fut** a meglévő gate-en keresztül (`scripts/check.sh` → `flutter test`).

## 🧠 Fejlesztési részletek

### Kiinduló állapot (repo bizonyíték)
- RPC wrapper:
  - `app/lib/src/features/rewards/data/daily_bonus_rpc.dart`
- Domain modell + parse:
  - `app/lib/src/features/rewards/domain/daily_bonus_grant_result.dart`
- Meglévő minimál unit teszt (főleg domain parse + unconfigured guard):
  - `app/test/unit/daily_bonus_grant_result_test.dart`
- CI / gate:
  - `scripts/check.sh` (pub get + analyze + test)
  - `.github/workflows/ci.yml` (check.sh futtatás)

### Probléma
A `daily_bonus_rpc.dart` jelenleg közvetlenül `SupabaseClient.rpc(...).maybeSingle()`-re épít.
A repo-ban nincs mocking lib (`app/pubspec.yaml`), így a Supabase kliens direkt mockolása nem realisztikus.

### Megoldás (tesztelhetőség minimál seam-mel, funkcióváltozás nélkül)
Vezessünk be egy nyers RPC “transport” providert, amit unit tesztben felül lehet írni:

- új típus + provider:
  - `DailyBonusRpcRawCaller = Future<Map<String, dynamic>?> Function();`
  - `dailyBonusRpcRawCallerProvider` a jelenlegi `.rpc('grant_daily_bonus_if_eligible').maybeSingle()` kódot tartalmazza
- a meglévő `dailyBonusRpcCallerProvider` csak:
  - meghívja a raw callert
  - `DailyBonusGrantResult.fromJson(...)`-t alkalmaz

Elvárt: az app viselkedése nem változik (unconfigured továbbra is `notConfigured` lesz a `fromJson(null)` miatt).

### Új unit teszt (célzott)
Új tesztfájl:
- `app/test/unit/daily_bonus_rpc_provider_test.dart`

Tesztesetek (provider override-dal, hálózat nélkül):
- raw → `{granted:true, amount:50, reason:'granted', next_eligible_at:'...Z'}` → `DailyBonusReason.granted`, amount=50, nextEligibleAt parse ok
- raw → `{granted:false, amount:0, reason:'already_claimed_today', next_eligible_at:'...Z'}` → `DailyBonusReason.alreadyClaimedToday`
- raw → `{granted:false, amount:0, reason:'disabled'}` → `DailyBonusReason.disabled`
- raw → `null` → `DailyBonusReason.notConfigured`
- + opcionális: raw hívásszámlálóval bizonyítani, hogy egyszer fut

### Dokumentáció (kicsi, konkrét)
- `docs/core_logic/daily_bonus.md` “Teszt DoD” részben rögzíteni:
  - konkrét fájlút: `app/test/unit/daily_bonus_rpc_provider_test.dart`

### DoD (pipálható)
- [ ] `app/lib/src/features/rewards/data/daily_bonus_rpc.dart` refaktor: `dailyBonusRpcRawCallerProvider` bevezetve, funkcionalitás változatlan
- [ ] Új unit teszt: `app/test/unit/daily_bonus_rpc_provider_test.dart` (a fenti cases)
- [ ] `docs/core_logic/daily_bonus.md` frissítve: teszt fájlút rögzítve
- [ ] Codex checklist + report:
  - `codex/codex_checklist/bonus_system/bonus_system_daily_bonus_rpc_unit_test.md`
  - `codex/reports/bonus_system/bonus_system_daily_bonus_rpc_unit_test.md`
- [ ] Záráskor verify:
  - `./scripts/verify.sh --report codex/reports/bonus_system/bonus_system_daily_bonus_rpc_unit_test.md`
  - log: `codex/reports/bonus_system/bonus_system_daily_bonus_rpc_unit_test.verify.log`

## 🧪 Tesztállapot
Kötelező zárás:
- `./scripts/verify.sh --report codex/reports/bonus_system/bonus_system_daily_bonus_rpc_unit_test.md`

CI-ben automatikusan fut:
- `scripts/check.sh` → `./scripts/flutter.sh test` → minden `app/test/**` teszt

## 🌍 Lokalizáció
Nem érintett.

## 📎 Kapcsolódások
- `app/lib/src/features/rewards/data/daily_bonus_rpc.dart`
- `app/lib/src/features/rewards/domain/daily_bonus_grant_result.dart`
- `app/test/unit/daily_bonus_grant_result_test.dart`
- `docs/core_logic/daily_bonus.md`
- `scripts/check.sh`
- `.github/workflows/ci.yml`
- `docs/codex/report_standard.md`
