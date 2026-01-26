# 🎯 Funkció

A SignUp wizard 2. lépése (Profil) legyen éles:
- Nickname megadás: kliens oldali validáció + normalizálás (trim + lowercase).
- Nickname foglaltság ellenőrzés: `public.check_nickname_available` RPC hívás **debounce**-szal.
- Avatar választás: preset alapú `avatar_key` (default: `neutral`), bottom sheet gridből választható.
- „Tovább” CTA csak akkor aktív, ha:
  - nickname format valid + szabad,
  - avatar_key be van állítva (default `neutral` már ok),
  - és nem offline (Supabase konfigurált).
- Step 3 maradhat placeholder (coming next), de a wizard navigáció maradjon stabil.

# 🧠 Fejlesztési részletek

## Releváns fájlok
- `app/lib/src/features/auth/presentation/screens/sign_up_wizard_screen.dart`
- `app/lib/src/features/auth/presentation/state/signup_wizard_provider.dart`
- `app/lib/src/core/clients/supabase_provider.dart`
- `app/lib/l10n/app_en.arb`
- `app/lib/l10n/app_hu.arb`
- `app/test/widget/` (új widget teszt Step 2-höz)

## Nickname szabályok (kötelező)
- Regex: `^[a-z0-9_.]{3,20}$`
- Kliens normalizál: `trim()` + `toLowerCase()`
- Minimum 3 karakter alatt **ne** menjen RPC check; UI jelezze, hogy min. 3 kell.

## Nickname availability (RPC)
- RPC: `public.check_nickname_available(text) -> bool`
- Supabase `rpc` param név: `p_nickname`
- Debounce: 400–500 ms
- Versenyhelyzetet kezeld: requestId/sequence védelem, hogy a később visszaérkező régi válasz ne írja felül az új állapotot.

## Javasolt állapotgép (provider state)
- mezők: `nickname`, `avatarKey`
- nickname check status: `idle | invalid | tooShort | checking | available | unavailable | error`
- `step2Valid`: nickname format valid + status==available + avatarKey nem üres

## Avatar picker (UI)
- Default: `neutral`
- „Módosítás” gomb / avatar tap -> bottom sheet
- Grid 3 oszlop, preset lista legalább:
  - `neutral`
  - `golden_mask`
  - `arcade`
- Kijelölés: highlight + pipa, „Mentés/Kész” zár.

## Tesztelhetőség (kötelező)
- Vezess be egy felülírható checker providert a nickname availabilityhez, hogy widget tesztben ne kelljen valódi Supabase:
  - pl. `nicknameAvailabilityCheckerProvider: Provider<Future<bool> Function(String nickname)>`
  - default implementáció: Supabase RPC hívás
  - teszt override: mindig `true` vagy `false`

## Minimális widget teszt (új)
- Lépj át Step 2-re (Step 1 kitölt + Next).
- Nickname beírás -> debounce után availability “available” állapot -> Next enged.
- Másik eset: checker false -> “foglalt” üzenet -> Next tilt.

# 🧪 Tesztállapot
- `./scripts/flutter.sh gen-l10n`
- `./scripts/flutter.sh format .` (legalább az érintett fájlokra)
- `./scripts/check.sh`

# 🌍 Lokalizáció
Új kulcsok (HU/EN, példák – a pontos szöveg legyen természetes):
- `auth_nickname_label`
- `auth_nickname_help` (regex + 3–20, kisbetű/szám/._)
- `auth_nickname_too_short`
- `auth_nickname_checking`
- `auth_nickname_available`
- `auth_nickname_unavailable`
- `auth_nickname_error`
- `auth_avatar_label`
- `auth_avatar_change`
- `auth_avatar_sheet_title`
- `common_done` (ha nincs még)

# 📎 Kapcsolódások
- `docs/core_logic/registration_flow.md` (Avatar + Step2 CTA szabály)
- `docs/data_model/profiles_table_doc.md` (nickname regex, normalizálás, RPC)
- `supabase/migrations/20260125000000_registration_v2_profiles_rls_trigger.sql` (RPC név/szignó)
