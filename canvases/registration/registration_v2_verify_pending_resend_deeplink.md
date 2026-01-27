# 🎯 Funkció

A Step 3 után megjelenő `VerifyEmailPendingScreen` legyen képes újraküldeni a megerősítő emailt, kezelni a cooldownt és a Supabase deep link callbacket egy dedikált `/auth/callback` route segítségével.

# 🧠 Fejlesztési részletek

## Pipálható feladatlista
- [ ] A nickname availability RPC közvetlen boolt ad vissza, és a signup submit `emailRedirectTo`-val a mobil deep linket célozza.
- [ ] Bevezetésre kerül egy `verify_email_pending_provider`, amely a resend cooldown-t, hibát és success állapotot kezeli, valamint a Supabase `auth.resend` metódusát használja.
- [ ] A `VerifyEmailPendingScreen` megjelenít egy „Újraküldés” gombot, inline hibaüzenetet és SnackBar visszajelzést, a `/auth/callback` route pedig egy új `AuthCallbackScreen`-et renderel, így a deep link nem dob elérhetetlen route-ot.
- [ ] A Supabase Auth „Redirect URLs” allowlistjén szerepelnia kell az `io.tipsterino://auth-callback/auth/callback` URI-nak (nincs új dependency).

# 🧪 Tesztállapot

- `./scripts/flutter.sh gen-l10n`
- `cd app && dart format .` *(engedély-probléma miatt nem futott le: `/home/muszy/flutter/bin/cache/engine.stamp` írása sikertelen)*
- `./scripts/check.sh` (analyze + widget tesztek)

# 🌍 Lokalizáció

Frissítendő kulcsok: `auth_verify_pending_resend`, `auth_verify_pending_resend_sent`, `auth_verify_pending_resend_cooldown`, `auth_callback_title`, `auth_callback_processing`, `auth_callback_error`, `auth_callback_back_to_login`.

# 📎 Kapcsolódások

- `supabase/migrations/20260125000000_registration_v2_profiles_rls_trigger.sql` (nickname metadata + trigger)
- `documents/registration/registration_flow_V2-md` (Step 3 flow és callback)
- `docs/localization/localization_logic.md` (új ARB kulcsok generálása)
